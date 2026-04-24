const crypto = require('crypto');
const { createTokenStore } = require('./tokenStore');

function createOAuthStateService(tokenStorePath) {
  const tokenStore = createTokenStore(tokenStorePath);
  const ttlMs = 15 * 60 * 1000;

  function createState() {
    return crypto.randomBytes(24).toString('hex');
  }

  async function savePendingState({ state, workspaceId, provider, createdAtIso }) {
    return tokenStore.savePendingState({
      state,
      workspaceId,
      provider,
      createdAtIso,
    });
  }

  async function consumePendingState({ state }) {
    const pending = await tokenStore.consumePendingState({ state });
    if (!pending) {
      return null;
    }
    const createdAt = Date.parse(pending.createdAtIso || '');
    if (!Number.isFinite(createdAt)) {
      return { ...pending, expired: true };
    }
    if (Date.now() - createdAt > ttlMs) {
      return { ...pending, expired: true };
    }
    return pending;
  }

  return {
    createState,
    savePendingState,
    consumePendingState,
  };
}

module.exports = {
  createOAuthStateService,
};
