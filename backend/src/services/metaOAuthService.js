const crypto = require('crypto');
const { getMetaConfig } = require('../config');
const { createTokenStore } = require('./tokenStore');

function createMetaOAuthService(tokenStorePath) {
  const tokenStore = createTokenStore(tokenStorePath);

  function requireMetaConfig() {
    const config = getMetaConfig();
    const metaAppId = process.env.META_APP_ID || '';
    const metaAppSecret = process.env.META_APP_SECRET || '';
    const metaRedirectUri = process.env.META_REDIRECT_URI || '';
    if (!metaAppId || !metaAppSecret || !metaRedirectUri) {
      const error = new Error('Meta configuration missing.');
      error.code = 'meta.config_missing';
      throw error;
    }
    return {
      ...config,
      appId: metaAppId,
      appSecret: metaAppSecret,
      redirectUri: metaRedirectUri,
    };
  }

  function safeError(message, code) {
    const error = new Error(message);
    error.code = code;
    return error;
  }

  async function readJsonOrThrow(response, code, message) {
    const raw = await response.text();
    if (!raw.trim()) {
      throw safeError(message, code);
    }
    try {
      return JSON.parse(raw);
    } catch (_) {
      throw safeError(message, code);
    }
  }

  function redactTokenishText(value) {
    if (typeof value !== 'string') {
      return null;
    }
    return value
      .replace(/access_token=[^&\s]+/gi, 'access_token=[REDACTED]')
      .replace(/app_secret=[^&\s]+/gi, 'app_secret=[REDACTED]')
      .replace(/client_secret=[^&\s]+/gi, 'client_secret=[REDACTED]')
      .replace(/\bEAA[A-Za-z0-9_-]+/g, '[REDACTED]');
  }

  async function readMetaErrorPayload(response) {
    const raw = await response.text();
    if (!raw.trim()) {
      return null;
    }
    try {
      const decoded = JSON.parse(raw);
      const error = decoded && decoded.error ? decoded.error : null;
      if (!error || typeof error !== 'object') {
        return null;
      }
      return {
        message: redactTokenishText(error.message),
        type: typeof error.type === 'string' ? error.type : null,
        code: typeof error.code === 'number' ? error.code : null,
        error_subcode:
          typeof error.error_subcode === 'number' ? error.error_subcode : null,
        fbtrace_id: typeof error.fbtrace_id === 'string' ? error.fbtrace_id : null,
      };
    } catch (_) {
      return null;
    }
  }

  function buildLoginUrl({ workspaceId }) {
    const config = requireMetaConfig();
    if (!workspaceId || !String(workspaceId).trim()) {
      const error = new Error('Workspace is required.');
      error.code = 'meta.workspace_missing';
      throw error;
    }
    const state = crypto.randomBytes(24).toString('hex');
    const loginUrl = new URL(`https://www.facebook.com/${config.graphVersion}/dialog/oauth`);
    loginUrl.searchParams.set('client_id', config.appId);
    loginUrl.searchParams.set('redirect_uri', config.redirectUri);
    loginUrl.searchParams.set('state', state);
    loginUrl.searchParams.set('response_type', 'code');
    loginUrl.searchParams.set('scope', config.metaScopes.join(','));
    tokenStore.savePendingState({
      state,
      workspaceId,
      provider: 'meta',
      createdAtIso: new Date().toISOString(),
    });
    return {
      loginUrl: loginUrl.toString(),
      state,
      statePreview: `${state.slice(0, 4)}...${state.slice(-4)}`,
    };
  }

  async function exchangeCodeForUserToken({ code }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/oauth/access_token`);
    endpoint.searchParams.set('client_id', config.appId);
    endpoint.searchParams.set('client_secret', config.appSecret);
    endpoint.searchParams.set('redirect_uri', config.redirectUri);
    endpoint.searchParams.set('code', code);
    const response = await fetch(endpoint.toString());
    if (!response.ok) {
      throw safeError('Meta token exchange failed.', 'meta.token_exchange_failed');
    }
    return readJsonOrThrow(
      response,
      'meta.token_exchange_failed',
      'Meta token exchange failed.',
    );
  }

  async function exchangeForLongLivedToken({ accessToken }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/oauth/access_token`);
    endpoint.searchParams.set('grant_type', 'fb_exchange_token');
    endpoint.searchParams.set('client_id', config.appId);
    endpoint.searchParams.set('client_secret', config.appSecret);
    endpoint.searchParams.set('fb_exchange_token', accessToken);
    const response = await fetch(endpoint.toString());
    if (!response.ok) {
      throw safeError('Meta long-lived token exchange failed.', 'meta.long_lived_token_failed');
    }
    return readJsonOrThrow(
      response,
      'meta.long_lived_token_failed',
      'Meta long-lived token exchange failed.',
    );
  }

  async function fetchMe({ accessToken }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/me`);
    endpoint.searchParams.set('fields', 'id,name');
    endpoint.searchParams.set('access_token', accessToken);
    const response = await fetch(endpoint.toString());
    if (!response.ok) {
      throw safeError('Meta /me fetch failed.', 'meta.me_fetch_failed');
    }
    return readJsonOrThrow(response, 'meta.me_fetch_failed', 'Meta /me fetch failed.');
  }

  async function fetchPages({ accessToken }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/me/accounts`);
    endpoint.searchParams.set('fields', 'id,name,category,tasks,access_token');
    endpoint.searchParams.set('access_token', accessToken);
    const response = await fetch(endpoint.toString());
    if (!response.ok) {
      const diagnostic = await readMetaErrorPayload(response);
      const error = safeError('Meta pages fetch failed.', 'meta.pages_fetch_failed');
      if (diagnostic) {
        error.diagnostic = diagnostic;
        error.message = `${error.message}: ${[
          diagnostic.message,
          diagnostic.type,
          diagnostic.code !== null ? `code=${diagnostic.code}` : null,
          diagnostic.error_subcode !== null ? `subcode=${diagnostic.error_subcode}` : null,
          diagnostic.fbtrace_id ? `fbtrace_id=${diagnostic.fbtrace_id}` : null,
        ]
          .filter(Boolean)
          .join(' | ')}`;
      }
      throw error;
    }
    return readJsonOrThrow(response, 'meta.pages_fetch_failed', 'Meta pages fetch failed.');
  }

  async function publishTextToPage({ pageId, pageAccessToken, message }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/${pageId}/feed`);
    const body = new URLSearchParams();
    body.set('message', message);
    body.set('access_token', pageAccessToken);
    const response = await fetch(endpoint.toString(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body.toString(),
    });
    if (!response.ok) {
      const diagnostic = await readMetaErrorPayload(response);
      const error = safeError('Meta page publish failed.', 'meta.publish_failed');
      error.status = response.status;
      if (diagnostic) {
        error.diagnostic = diagnostic;
        error.message = `${error.message}: ${[
          diagnostic.message,
          diagnostic.type,
          diagnostic.code !== null ? `code=${diagnostic.code}` : null,
          diagnostic.error_subcode !== null ? `subcode=${diagnostic.error_subcode}` : null,
          diagnostic.fbtrace_id ? `fbtrace_id=${diagnostic.fbtrace_id}` : null,
        ]
          .filter(Boolean)
          .join(' | ')}`;
      }
      throw error;
    }
    return readJsonOrThrow(response, 'meta.publish_failed', 'Meta page publish failed.');
  }

  function buildSafeConnection({ workspaceId, me, pages, tokenRef, userAccessToken }) {
    return {
      provider: 'meta',
      workspaceId,
      metaUserId: me?.id || '',
      displayName: me?.name || 'Meta User',
      pages: Array.isArray(pages)
        ? pages.map((page) => ({
            id: page.id,
            name: page.name,
            category: page.category || null,
            tasks: Array.isArray(page.tasks) ? page.tasks : [],
            pageAccessToken: page.pageAccessToken || null,
          }))
        : [],
      tokenRef,
      userAccessToken,
      scopesRequested: getMetaConfig().metaScopes,
      connectedAtIso: new Date().toISOString(),
      updatedAtIso: new Date().toISOString(),
    };
  }

  async function saveConnectionRecord({ workspaceId, connection }) {
    const saved = await tokenStore.saveConnection({
      workspaceId,
      provider: 'meta',
      connection,
    });
    return saved;
  }

  async function getConnectionRecord(workspaceId) {
    return tokenStore.getConnection({ workspaceId, provider: 'meta' });
  }

  async function savePendingState(stateRecord) {
    return tokenStore.savePendingState({
      ...stateRecord,
      provider: 'meta',
    });
  }

  async function consumePendingState(state) {
    return tokenStore.consumePendingState({ state });
  }

  async function saveMetaConnection({
    workspaceId,
    connection,
  }) {
    return tokenStore.saveConnection({
      workspaceId,
      provider: 'meta',
      connection,
    });
  }

  async function fetchPagesFromConnection({ connection }) {
    const pages = Array.isArray(connection.pages) ? connection.pages : [];
    return pages.map((page) => ({
      id: page.id,
      name: page.name,
      category: page.category || null,
      tasks: Array.isArray(page.tasks) ? page.tasks : [],
      hasPageAccessToken: Boolean(page.pageAccessToken),
    }));
  }

  return {
    buildLoginUrl,
    exchangeCodeForUserToken,
    exchangeForLongLivedToken,
    fetchMe,
    fetchPages,
    publishTextToPage,
    buildSafeConnection,
    saveConnectionRecord,
    getConnectionRecord,
    savePendingState,
    consumePendingState,
    saveMetaConnection,
    fetchPagesFromConnection,
  };
}

module.exports = {
  createMetaOAuthService,
};
