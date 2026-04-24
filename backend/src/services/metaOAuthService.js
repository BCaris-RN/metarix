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
      const error = new Error('Meta token exchange failed.');
      error.code = 'meta.token_exchange_failed';
      throw error;
    }
    return response.json();
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
      return null;
    }
    return response.json();
  }

  async function fetchMe({ accessToken }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/me`);
    endpoint.searchParams.set('fields', 'id,name');
    endpoint.searchParams.set('access_token', accessToken);
    const response = await fetch(endpoint.toString());
    if (!response.ok) {
      const error = new Error('Meta /me fetch failed.');
      error.code = 'meta.me_fetch_failed';
      throw error;
    }
    return response.json();
  }

  async function fetchPages({ accessToken }) {
    const config = requireMetaConfig();
    const endpoint = new URL(`https://graph.facebook.com/${config.graphVersion}/me/accounts`);
    endpoint.searchParams.set('fields', 'id,name,access_token,category,perms');
    endpoint.searchParams.set('access_token', accessToken);
    const response = await fetch(endpoint.toString());
    if (!response.ok) {
      const error = new Error('Meta pages fetch failed.');
      error.code = 'meta.pages_fetch_failed';
      throw error;
    }
    return response.json();
  }

  async function buildSafeConnection({ workspaceId, me, pages, tokenRef }) {
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
            perms: Array.isArray(page.perms) ? page.perms : [],
          }))
        : [],
      tokenRef,
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

  return {
    buildLoginUrl,
    exchangeCodeForUserToken,
    exchangeForLongLivedToken,
    fetchMe,
    fetchPages,
    buildSafeConnection,
    saveConnectionRecord,
    getConnectionRecord,
    savePendingState,
    consumePendingState,
  };
}

module.exports = {
  createMetaOAuthService,
};
