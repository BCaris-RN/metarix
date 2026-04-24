const express = require('express');

function createHealthRouter() {
  const router = express.Router();
  router.get('/health', (_req, res) => {
    res.json({
      ok: true,
      service: 'metarix-plus-backend',
      mode: 'local',
    });
  });
  return router;
}

module.exports = {
  createHealthRouter,
};
