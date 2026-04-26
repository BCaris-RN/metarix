const express = require('express');
const { getSafeConfig } = require('../config');
const { createProviderRegistry } = require('../services/providerRegistry');
const { createOAuthStateService } = require('../services/oauthStateService');
const { buildProviderLoginUrl } = require('../services/oauthUrlBuilder');
const { createTokenStore } = require('../services/tokenStore');
const { createMetaOAuthService } = require('../services/metaOAuthService');
const { info, error: logError, sanitize } = require('../services/safeLogger');

function createMetaRouter() {
  const router = express.Router();
  const safeConfig = getSafeConfig();
  const providerRegistry = createProviderRegistry();
  const tokenStore = createTokenStore(safeConfig.tokenStorePath);
  const oauthStateService = createOAuthStateService(safeConfig.tokenStorePath);
  const metaOAuthService = createMetaOAuthService(safeConfig.tokenStorePath);

  const readConnection = (workspaceId, provider) =>
    tokenStore.getConnection({ workspaceId, provider });

  const safeConnectionSummary = (workspaceId, connection) => ({
    ok: true,
    connected: true,
    provider: 'meta',
    workspaceId,
    displayName: connection.displayName || null,
    metaUserId: connection.metaUserId || null,
    pageCount: Array.isArray(connection.pages) ? connection.pages.length : 0,
    connectedAtIso: connection.connectedAtIso || null,
    updatedAtIso: connection.updatedAtIso || null,
  });

  const safePageList = (workspaceId, connection) => ({
    ok: true,
    provider: 'meta',
    workspaceId,
    pages: Array.isArray(connection.pages)
      ? connection.pages.map((page) => ({
          id: page.id || null,
          name: page.name || null,
          category: page.category || null,
          tasks: Array.isArray(page.tasks) ? page.tasks : [],
          hasPageAccessToken: Boolean(page.pageAccessToken),
        }))
      : [],
  });

  const renderSuccessPage = (displayName, pages) => {
    const pageItems = pages
      .map((page) => `<li>${escapeHtml(page.name || 'Unnamed page')}</li>`)
      .join('');
    return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Meta connection complete</title>
  </head>
  <body>
    <h1>Meta connection complete</h1>
    <p>${escapeHtml(displayName || 'Meta User')}</p>
    <ul>${pageItems}</ul>
  </body>
</html>`;
  };

  const escapeHtml = (value) =>
    String(value || '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  router.get('/api/providers/status', (_req, res) => {
    res.json({ ok: true, providers: providerRegistry.listProviderStatuses() });
  });

  router.get('/api/providers/:provider/status', (req, res) => {
    const provider = String(req.params.provider || '').toLowerCase();
    const status = providerRegistry.getProviderStatus(provider);
    if (!status) {
      return res.status(404).json({
        ok: false,
        errorCode: 'provider.unknown',
        message: 'Unknown provider.',
      });
    }
    return res.json({ ok: true, provider: status });
  });

  router.get('/api/oauth/:provider/login-url', async (req, res) => {
    try {
      const provider = String(req.params.provider || '').toLowerCase();
      const workspaceId = String(req.query.workspaceId || '').trim();
      if (!workspaceId) {
        return res.status(400).json({
          ok: false,
          errorCode: 'oauth.workspace_missing',
          message: 'workspaceId is required.',
        });
      }
      const providerStatus = providerRegistry.requireProviderConfigured(provider);
      const state = oauthStateService.createState();
      await oauthStateService.savePendingState({
        state,
        workspaceId,
        provider,
        createdAtIso: new Date().toISOString(),
      });
      const loginUrl = buildProviderLoginUrl(providerStatus, state);
      if (!loginUrl) {
        return res.status(501).json({
          ok: false,
          errorCode: 'oauth.callback_not_implemented',
          message: 'Provider login URL is not available.',
        });
      }
      return res.json({
        ok: true,
        loginUrl,
        statePreview: `${state.slice(0, 4)}...${state.slice(-4)}`,
      });
    } catch (error) {
      return res.status(error.code === 'provider.unknown' ? 404 : 503).json({
        ok: false,
        errorCode: error.code || 'provider.config_missing',
        message: error.code === 'provider.unknown' ? 'Unknown provider.' : 'Provider OAuth is not configured.',
      });
    }
  });

  router.get('/api/oauth/:provider/callback', async (req, res) => {
    const provider = String(req.params.provider || '').toLowerCase();
    if (provider !== 'meta') {
      return res.status(501).send('oauth.callback_not_implemented');
    }
    const state = String(req.query.state || '').trim();
    if (!state) {
      return res.status(400).send('meta.state_missing');
    }
    const pending = await oauthStateService.consumePendingState({ state });
    if (!pending) {
      return res.status(400).send('meta.state_invalid');
    }
    if (pending.expired) {
      return res.status(400).send('meta.state_expired');
    }
    const code = String(req.query.code || '').trim();
    if (!code) {
      return res.status(400).send('meta.code_missing');
    }

    try {
      const tokenResponse = await metaOAuthService.exchangeCodeForUserToken({ code });
      const longLivedTokenResponse = await metaOAuthService.exchangeForLongLivedToken({
        accessToken: tokenResponse.access_token,
      });
      const userAccessToken = longLivedTokenResponse?.access_token || tokenResponse.access_token;
      if (!userAccessToken) {
        return res.status(502).send('meta.token_exchange_failed');
      }
      const tokenRef = `meta-${pending.workspaceId}-${Date.now()}`;
      const me = await metaOAuthService.fetchMe({ accessToken: userAccessToken });
      const pagesResponse = await metaOAuthService.fetchPages({ accessToken: userAccessToken });
      const pages = Array.isArray(pagesResponse.data)
        ? pagesResponse.data.map((page, index) => ({
            id: page.id || `page-${index}`,
            name: page.name || 'Meta Page',
            category: page.category || null,
            tasks: Array.isArray(page.tasks) ? page.tasks : [],
            pageAccessToken: page.access_token || null,
          }))
        : [];
      const connection = metaOAuthService.buildSafeConnection({
        workspaceId: pending.workspaceId,
        me,
        pages,
        tokenRef,
        userAccessToken,
      });
      await metaOAuthService.saveMetaConnection({
        workspaceId: pending.workspaceId,
        connection,
      });
      info('Meta connection stored', {
        workspaceId: pending.workspaceId,
        provider: 'meta',
        displayName: connection.displayName,
        pageCount: connection.pages.length,
      });
      const safePages = pages.map((page) => ({
        id: page.id,
        name: page.name,
      }));
      return res
        .status(200)
        .type('html')
        .send(renderSuccessPage(connection.displayName, safePages));
    } catch (caughtError) {
      const err = sanitize({
        message: caughtError?.message,
        code: caughtError?.code,
      });
      logError('Meta callback failed', err);
      if (caughtError?.code === 'meta.token_exchange_failed') {
        return res.status(502).send('meta.token_exchange_failed');
      }
      if (caughtError?.code === 'meta.long_lived_token_failed') {
        return res.status(502).send('meta.long_lived_token_failed');
      }
      if (caughtError?.code === 'meta.me_fetch_failed') {
        return res.status(502).send('meta.me_fetch_failed');
      }
      if (caughtError?.code === 'meta.pages_fetch_failed') {
        return res.status(502).json({
          ok: false,
          errorCode: 'meta.pages_fetch_failed',
          diagnostic: caughtError.diagnostic || null,
        });
      }
      return res.status(500).send('meta.callback_failed');
    }
  });

  router.get('/api/oauth/:provider/connection', async (req, res) => {
    const provider = String(req.params.provider || '').toLowerCase();
    const workspaceId = String(req.query.workspaceId || '').trim();
    if (!workspaceId) {
      return res.status(400).json({
        ok: false,
        errorCode: 'oauth.workspace_missing',
        message: 'workspaceId is required.',
      });
    }
    const connection = await readConnection(workspaceId, provider);
    if (!connection) {
      if (provider === 'meta') {
        return res.status(404).json({
          ok: false,
          errorCode: 'meta.not_connected',
          message: 'Meta is not connected for this workspace.',
        });
      }
      return res.json({
        ok: true,
        provider,
        workspaceId,
        connected: false,
        summary: null,
      });
    }
    return provider === 'meta'
      ? res.json(safeConnectionSummary(workspaceId, connection))
      : res.json({
          ok: true,
          provider,
          workspaceId,
          connected: true,
          summary: {
            provider: connection.provider || provider,
            displayName: connection.displayName || null,
            connectedAtIso: connection.connectedAtIso || null,
            updatedAtIso: connection.updatedAtIso || null,
            pageCount: Array.isArray(connection.pages) ? connection.pages.length : 0,
          },
        });
  });

  router.delete('/api/oauth/:provider/connection', async (req, res) => {
    const provider = String(req.params.provider || '').toLowerCase();
    const workspaceId = String(req.query.workspaceId || '').trim();
    if (!workspaceId) {
      return res.status(400).json({
        ok: false,
        errorCode: 'oauth.workspace_missing',
        message: 'workspaceId is required.',
      });
    }
    await tokenStore.deleteConnection({ workspaceId, provider });
    return res.json({ ok: true, provider, workspaceId, disconnected: true });
  });

  router.get('/api/meta/status', (_req, res) => {
    const status = providerRegistry.getProviderStatus('meta');
    res.json({
      ok: true,
      provider: 'meta',
      configured: status?.configured || false,
      graphVersion: process.env.META_GRAPH_VERSION || 'v24.0',
      redirectUriConfigured: status?.redirectUriConfigured || false,
    });
  });

  router.get('/api/meta/login-url', (req, res) => {
    req.params = { provider: 'meta' };
    req.url = req.url.replace('/api/meta/login-url', '/api/oauth/meta/login-url');
    router.handle(req, res, () => {
      res.status(404).json({
        ok: false,
        errorCode: 'provider.unknown',
        message: 'Unknown provider.',
      });
    });
  });

  router.get('/api/meta/pages', async (req, res) => {
    const workspaceId = String(req.query.workspaceId || '').trim();
    if (!workspaceId) {
      return res.status(400).json({
        ok: false,
        errorCode: 'oauth.workspace_missing',
        message: 'workspaceId is required.',
      });
    }
    const connection = await readConnection(workspaceId, 'meta');
    if (!connection) {
      return res.status(404).json({
        ok: false,
        errorCode: 'oauth.not_connected',
        message: 'Meta is not connected for this workspace.',
      });
    }
    return res.json(safePageList(workspaceId, connection));
  });

  router.get('/api/oauth/meta/pages', async (req, res) => {
    const workspaceId = String(req.query.workspaceId || '').trim();
    if (!workspaceId) {
      return res.status(400).json({
        ok: false,
        errorCode: 'oauth.workspace_missing',
        message: 'workspaceId is required.',
      });
    }
    const connection = await readConnection(workspaceId, 'meta');
    if (!connection) {
      return res.status(404).json({
        ok: false,
        errorCode: 'meta.not_connected',
        message: 'Meta is not connected for this workspace.',
      });
    }
    return res.json(safePageList(workspaceId, connection));
  });

  router.get('/api/meta/connection', async (req, res) => {
    const workspaceId = String(req.query.workspaceId || '').trim();
    if (!workspaceId) {
      return res.status(400).json({
        ok: false,
        errorCode: 'oauth.workspace_missing',
        message: 'workspaceId is required.',
      });
    }
    const connection = await readConnection(workspaceId, 'meta');
    if (!connection) {
      return res.json({
        ok: true,
        provider: 'meta',
        workspaceId,
        connected: false,
        summary: null,
      });
    }
    return res.json(safeConnectionSummary(workspaceId, connection));
  });

  return router;
}

module.exports = {
  createMetaRouter,
};
