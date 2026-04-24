const path = require('path');
const dotenv = require('dotenv');

dotenv.config();

function parsePort(value) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 8787;
}

function parseAllowedOrigins(value) {
  return String(value || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

function getSafeConfig() {
  return {
    port: parsePort(process.env.PORT),
    nodeEnv: process.env.NODE_ENV || 'development',
    allowedOrigins: parseAllowedOrigins(process.env.ALLOWED_ORIGINS),
    tokenStorePath: path.resolve(
      process.cwd(),
      process.env.LOCAL_TOKEN_STORE_PATH || '.local/token-store.json',
    ),
  };
}

function getMetaConfig() {
  const metaAppId = process.env.META_APP_ID || '';
  const metaAppSecret = process.env.META_APP_SECRET || '';
  const metaRedirectUri = process.env.META_REDIRECT_URI || '';
  const metaGraphVersion = process.env.META_GRAPH_VERSION || 'v24.0';

  return {
    configured: Boolean(metaAppId && metaAppSecret && metaRedirectUri),
    redirectUriConfigured: Boolean(metaRedirectUri),
    graphVersion: metaGraphVersion,
    appId: metaAppId,
    appSecret: metaAppSecret,
    redirectUri: metaRedirectUri,
  };
}

module.exports = {
  getSafeConfig,
  getMetaConfig,
};
