const { getProviderConfigs } = require('../config');

function createProviderRegistry() {
  function getProviderStatus(provider) {
    const normalized = String(provider || '').toLowerCase();
    const configs = getProviderConfigs();
    return configs[normalized] || null;
  }

  function listProviderStatuses() {
    return Object.values(getProviderConfigs());
  }

  function requireProviderConfigured(provider) {
    const status = getProviderStatus(provider);
    if (!status) {
      const error = new Error(`Unknown provider: ${provider}`);
      error.code = 'provider.unknown';
      throw error;
    }
    if (!status.configured) {
      const error = new Error(`Provider not configured: ${provider}`);
      error.code = 'provider.config_missing';
      throw error;
    }
    return status;
  }

  return {
    getProviderStatus,
    listProviderStatuses,
    requireProviderConfigured,
  };
}

module.exports = {
  createProviderRegistry,
};
