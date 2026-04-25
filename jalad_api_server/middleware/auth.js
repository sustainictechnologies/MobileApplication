'use strict';

const jwt  = require('jsonwebtoken');
const { fail } = require('../helpers');

/**
 * Verifies the Bearer token in Authorization header.
 * On success attaches req.userId and calls next().
 * On failure returns 401.
 */
function requireAuth(req, res, next) {
  const header = req.headers['authorization'] ?? '';
  const token  = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return fail(res, 'Authentication required.', 401);
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = payload.userId;
    next();
  } catch (err) {
    const message = err.name === 'TokenExpiredError'
      ? 'Session expired. Please log in again.'
      : 'Invalid token.';
    fail(res, message, 401);
  }
}

module.exports = { requireAuth };