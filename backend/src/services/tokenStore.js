const fs = require('fs/promises');
const path = require('path');
const { sanitize } = require('./safeLogger');

async function ensureDir(filePath) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
}

async function readJson(filePath, fallback) {
  try {
    const raw = await fs.readFile(filePath, 'utf8');
    if (!raw.trim()) {
      return fallback;
    }
    return JSON.parse(raw);
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      return fallback;
    }
    return fallback;
  }
}

async function atomicWrite(filePath, payload) {
  await ensureDir(filePath);
  const tempPath = `${filePath}.tmp`;
  await fs.writeFile(tempPath, JSON.stringify(payload, null, 2), 'utf8');
  await fs.rename(tempPath, filePath);
}

function createEmptyStore() {
  return {
    connections: {},
    pendingStates: {},
  };
}

function createTokenStore(filePath) {
  async function readStore() {
    return readJson(filePath, createEmptyStore());
  }

  async function writeStore(store) {
    await atomicWrite(filePath, sanitize(store));
  }

  async function getConnection({ workspaceId, provider }) {
    const store = await readStore();
    return store.connections?.[workspaceId]?.[provider] || null;
  }

  async function saveConnection({ workspaceId, provider, connection }) {
    const store = await readStore();
    store.connections ||= {};
    store.connections[workspaceId] ||= {};
    store.connections[workspaceId][provider] = {
      ...connection,
      createdAtIso: connection.createdAtIso || new Date().toISOString(),
      updatedAtIso: new Date().toISOString(),
    };
    await writeStore(store);
    return store.connections[workspaceId][provider];
  }

  async function deleteConnection({ workspaceId, provider }) {
    const store = await readStore();
    if (store.connections?.[workspaceId]?.[provider]) {
      delete store.connections[workspaceId][provider];
    }
    await writeStore(store);
  }

  async function savePendingState({ state, workspaceId, provider, createdAtIso }) {
    const store = await readStore();
    store.pendingStates ||= {};
    store.pendingStates[state] = {
      state,
      workspaceId,
      provider,
      createdAtIso: createdAtIso || new Date().toISOString(),
    };
    await writeStore(store);
    return store.pendingStates[state];
  }

  async function consumePendingState({ state }) {
    const store = await readStore();
    const pending = store.pendingStates?.[state] || null;
    if (pending) {
      delete store.pendingStates[state];
      await writeStore(store);
    }
    return pending;
  }

  return {
    readStore,
    writeStore,
    getConnection,
    saveConnection,
    deleteConnection,
    savePendingState,
    consumePendingState,
  };
}

module.exports = {
  createTokenStore,
};
