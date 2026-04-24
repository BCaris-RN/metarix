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

function parseScopes(value) {
  return String(value || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

function parseMissingEnvKeys(entries) {
  return entries.filter((entry) => !entry.value).map((entry) => entry.key);
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
  const metaScopes = parseScopes(process.env.META_SCOPES || '');

  return {
    provider: 'meta',
    displayName: 'Meta / Facebook / Instagram',
    configured: Boolean(metaAppId && metaAppSecret && metaRedirectUri),
    redirectUriConfigured: Boolean(metaRedirectUri),
    graphVersion: metaGraphVersion,
    metaScopes,
    scopes: metaScopes,
    redirectUri: metaRedirectUri,
    missingEnvKeys: parseMissingEnvKeys([
      { key: 'META_APP_ID', value: metaAppId },
      { key: 'META_APP_SECRET', value: metaAppSecret },
      { key: 'META_REDIRECT_URI', value: metaRedirectUri },
    ]),
    authBaseUrl: `https://www.facebook.com/${metaGraphVersion}/dialog/oauth`,
    tokenUrl: `https://graph.facebook.com/${metaGraphVersion}/oauth/access_token`,
    docsHint: 'Create a Meta app, add Facebook Login, and use the local callback route.',
  };
}

function getProviderConfigs() {
  const linkedinClientId = process.env.LINKEDIN_CLIENT_ID || '';
  const linkedinClientSecret = process.env.LINKEDIN_CLIENT_SECRET || '';
  const linkedinRedirectUri = process.env.LINKEDIN_REDIRECT_URI || '';
  const linkedinScopes = parseScopes(
    process.env.LINKEDIN_SCOPES || 'openid,profile,email,w_member_social',
  );
  const googleClientId = process.env.GOOGLE_CLIENT_ID || '';
  const googleClientSecret = process.env.GOOGLE_CLIENT_SECRET || '';
  const googleRedirectUri = process.env.GOOGLE_REDIRECT_URI || '';
  const googleScopes = parseScopes(
    process.env.GOOGLE_SCOPES ||
      'https://www.googleapis.com/auth/youtube.upload,https://www.googleapis.com/auth/youtube.readonly',
  );
  const tiktokClientKey = process.env.TIKTOK_CLIENT_KEY || '';
  const tiktokClientSecret = process.env.TIKTOK_CLIENT_SECRET || '';
  const tiktokRedirectUri = process.env.TIKTOK_REDIRECT_URI || '';
  const tiktokScopes = parseScopes(
    process.env.TIKTOK_SCOPES || 'user.info.basic,video.upload,video.publish',
  );

  return {
    meta: getMetaConfig(),
    linkedin: {
      provider: 'linkedin',
      displayName: 'LinkedIn',
      configured: Boolean(linkedinClientId && linkedinClientSecret && linkedinRedirectUri),
      redirectUriConfigured: Boolean(linkedinRedirectUri),
      redirectUri: linkedinRedirectUri,
      scopes: linkedinScopes,
      missingEnvKeys: parseMissingEnvKeys([
        { key: 'LINKEDIN_CLIENT_ID', value: linkedinClientId },
        { key: 'LINKEDIN_CLIENT_SECRET', value: linkedinClientSecret },
        { key: 'LINKEDIN_REDIRECT_URI', value: linkedinRedirectUri },
      ]),
      authBaseUrl: 'https://www.linkedin.com/oauth/v2/authorization',
      tokenUrl: 'https://www.linkedin.com/oauth/v2/accessToken',
      docsHint: 'Use LinkedIn OAuth with the local callback route.',
    },
    youtube: {
      provider: 'youtube',
      displayName: 'YouTube',
      configured: Boolean(googleClientId && googleClientSecret && googleRedirectUri),
      redirectUriConfigured: Boolean(googleRedirectUri),
      redirectUri: googleRedirectUri,
      scopes: googleScopes,
      missingEnvKeys: parseMissingEnvKeys([
        { key: 'GOOGLE_CLIENT_ID', value: googleClientId },
        { key: 'GOOGLE_CLIENT_SECRET', value: googleClientSecret },
        { key: 'GOOGLE_REDIRECT_URI', value: googleRedirectUri },
      ]),
      authBaseUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
      tokenUrl: 'https://oauth2.googleapis.com/token',
      docsHint: 'Use Google OAuth with offline access for YouTube upload readiness.',
    },
    tiktok: {
      provider: 'tiktok',
      displayName: 'TikTok',
      configured: Boolean(tiktokClientKey && tiktokClientSecret && tiktokRedirectUri),
      redirectUriConfigured: Boolean(tiktokRedirectUri),
      redirectUri: tiktokRedirectUri,
      scopes: tiktokScopes,
      missingEnvKeys: parseMissingEnvKeys([
        { key: 'TIKTOK_CLIENT_KEY', value: tiktokClientKey },
        { key: 'TIKTOK_CLIENT_SECRET', value: tiktokClientSecret },
        { key: 'TIKTOK_REDIRECT_URI', value: tiktokRedirectUri },
      ]),
      authBaseUrl: 'https://www.tiktok.com/v2/auth/authorize/',
      tokenUrl: 'https://open.tiktokapis.com/v2/oauth/token/',
      docsHint: 'Use TikTok OAuth with the local callback route.',
    },
  };
}

module.exports = {
  getSafeConfig,
  getMetaConfig,
  getProviderConfigs,
};
