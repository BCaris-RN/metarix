const SECRET_PATTERNS = [
  /access[_-]?token/i,
  /refresh[_-]?token/i,
  /id[_-]?token/i,
  /secret/i,
  /password/i,
];

function redactValue(key, value) {
  if (typeof key === 'string' && SECRET_PATTERNS.some((pattern) => pattern.test(key))) {
    return '[REDACTED]';
  }
  if (typeof value === 'string' && value.length > 8) {
    if (value.includes('Bearer ') || value.startsWith('EAAG') || value.startsWith('EAA')) {
      return '[REDACTED]';
    }
  }
  return value;
}

function sanitize(input) {
  if (Array.isArray(input)) {
    return input.map((item) => sanitize(item));
  }
  if (input && typeof input === 'object') {
    const output = {};
    for (const [key, value] of Object.entries(input)) {
      output[key] = redactValue(key, sanitize(value));
    }
    return output;
  }
  return input;
}

function info(message, meta) {
  console.log(message, meta ? sanitize(meta) : '');
}

function warn(message, meta) {
  console.warn(message, meta ? sanitize(meta) : '');
}

function error(message, meta) {
  console.error(message, meta ? sanitize(meta) : '');
}

module.exports = {
  info,
  warn,
  error,
  sanitize,
};
