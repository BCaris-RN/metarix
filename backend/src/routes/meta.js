const express = require('express');
const { getSafeConfig } = require('../config');
const { createProviderRegistry } = require('../services/providerRegistry');
const { createOAuthStateService } = require('../services/oauthStateService');
const { buildProviderLoginUrl } = require('../services/oauthUrlBuilder');
const { createTokenStore } = require('../services/tokenStore');

function createMetaRouter() {
  const router = express.Router();
  const safeConfig = getSafeConfig();
  const providerRegistry = createProviderRegistry();
  const tokenStore = createTokenStore(safeConfig.tokenStorePath);
  const oauthStateService = createOAuthStateService(safeConfig.tokenStorePath);

  const readConnection = (workspaceId, provider) =>
    tokenStore.getConnection({ workspaceId, provider });

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
    const state = String(req.query.state || '').trim();
    if (!state) {
      return res.status(400).send('oauth.state_missing');
    }
    const pending = await oauthStateService.consumePendingState({ state });
    if (!pending) {
      return res.status(400).send('oauth.state_invalid');
    }
    if (pending.expired) {
      return res.status(400).send('oauth.state_expired');
    }
    return res.status(501).send('oauth.callback_not_implemented');
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
      return res.json({
        ok: true,
        provider,
        workspaceId,
        connected: false,
        summary: null,
      });
    }
    return res.json({
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
    return res.json({
      ok: true,
      provider: 'meta',
      workspaceId,
      connected: true,
      pages: connection.pages || [],
    });
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
    return res.json({
      ok: true,
      provider: 'meta',
      workspaceId,
      connected: true,
      summary: {
        provider: 'meta',
        displayName: connection.displayName || null,
        connectedAtIso: connection.connectedAtIso || null,
        updatedAtIso: connection.updatedAtIso || null,
        pageCount: Array.isArray(connection.pages) ? connection.pages.length : 0,
      },
    });
  });

  return router;
}

module.exports = {
  createMetaRouter,
};
