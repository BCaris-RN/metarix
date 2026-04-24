const express = require('express');
const cors = require('cors');
const { getSafeConfig } = require('./config');
const { info, error } = require('./services/safeLogger');
const { createHealthRouter } = require('./routes/health');
const { createMetaRouter } = require('./routes/meta');

const config = getSafeConfig();
const app = express();

app.use(express.json({ limit: '1mb' }));
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || config.allowedOrigins.length === 0 || config.allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(new Error('Origin not allowed by local backend CORS policy'));
    },
  }),
);

app.use(createHealthRouter());
app.use(createMetaRouter());

app.use((err, _req, res, _next) => {
  error('Backend error', { message: err.message });
  res.status(500).json({ ok: false, error: 'internal_error' });
});

app.listen(config.port, () => {
  info('metarix-plus-backend started', {
    port: config.port,
    nodeEnv: config.nodeEnv,
    allowedOrigins: config.allowedOrigins,
  });
});
