const express = require('express');
const { getMetaConfig } = require('../config');

function createMetaRouter() {
  const router = express.Router();
  router.get('/api/meta/status', (_req, res) => {
    const config = getMetaConfig();
    res.json({
      ok: true,
      provider: 'meta',
      configured: config.configured,
      graphVersion: config.graphVersion,
      redirectUriConfigured: config.redirectUriConfigured,
    });
  });
  return router;
}

module.exports = {
  createMetaRouter,
};
