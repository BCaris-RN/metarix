function buildProviderLoginUrl(providerStatus, state) {
  const redirectUri = providerStatus.redirectUri;
  const scope = Array.isArray(providerStatus.scopes)
    ? providerStatus.scopes.join(',')
    : '';

  switch (providerStatus.provider) {
    case 'meta': {
      const url = new URL(providerStatus.authBaseUrl);
      url.searchParams.set('client_id', process.env.META_APP_ID || '');
      url.searchParams.set('redirect_uri', redirectUri);
      url.searchParams.set('state', state);
      url.searchParams.set('scope', scope);
      url.searchParams.set('response_type', 'code');
      return url.toString();
    }
    case 'linkedin': {
      const url = new URL(providerStatus.authBaseUrl);
      url.searchParams.set('response_type', 'code');
      url.searchParams.set('client_id', process.env.LINKEDIN_CLIENT_ID || '');
      url.searchParams.set('redirect_uri', redirectUri);
      url.searchParams.set('state', state);
      url.searchParams.set('scope', scope);
      return url.toString();
    }
    case 'youtube': {
      const url = new URL(providerStatus.authBaseUrl);
      url.searchParams.set('response_type', 'code');
      url.searchParams.set('client_id', process.env.GOOGLE_CLIENT_ID || '');
      url.searchParams.set('redirect_uri', redirectUri);
      url.searchParams.set('scope', scope);
      url.searchParams.set('access_type', 'offline');
      url.searchParams.set('prompt', 'consent');
      url.searchParams.set('state', state);
      return url.toString();
    }
    case 'tiktok': {
      const url = new URL(providerStatus.authBaseUrl);
      url.searchParams.set('client_key', process.env.TIKTOK_CLIENT_KEY || '');
      url.searchParams.set('redirect_uri', redirectUri);
      url.searchParams.set('response_type', 'code');
      url.searchParams.set('scope', scope);
      url.searchParams.set('state', state);
      return url.toString();
    }
    default:
      return null;
  }
}

module.exports = {
  buildProviderLoginUrl,
};
