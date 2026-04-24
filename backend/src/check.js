const fs = require('fs/promises');
const path = require('path');
const os = require('os');
const { createProviderRegistry } = require('./services/providerRegistry');
const { createTokenStore } = require('./services/tokenStore');

async function main() {
  const registry = createProviderRegistry();
  const statuses = registry.listProviderStatuses();
  if (!Array.isArray(statuses) || statuses.length < 4) {
    throw new Error('Expected provider statuses for Meta, LinkedIn, YouTube, and TikTok.');
  }

  const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'metarix-backend-check-'));
  const tokenStore = createTokenStore(path.join(tempDir, 'token-store.json'));
  await tokenStore.saveConnection({
    workspaceId: 'workspace-demo',
    provider: 'meta',
    connection: {
      provider: 'meta',
      workspaceId: 'workspace-demo',
      displayName: 'Demo',
      pages: [{ id: 'page-1', name: 'Demo Page' }],
      tokenRef: 'ref-1',
      connectedAtIso: new Date().toISOString(),
      updatedAtIso: new Date().toISOString(),
    },
  });
  const saved = await tokenStore.getConnection({
    workspaceId: 'workspace-demo',
    provider: 'meta',
  });
  if (!saved || saved.displayName !== 'Demo') {
    throw new Error('Token store read/write check failed.');
  }
  console.log('backend check ok');
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
