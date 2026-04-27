'use strict';

const express   = require('express');
const bcrypt    = require('bcrypt');
const jwt       = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const { v4: uuidv4 } = require('uuid');
const { ok, fail, log, dbErr, formatUser } = require('../helpers');
const userQ = require('../queries/user.queries');

const router      = express.Router();
const SALT_ROUNDS = 10;
const JWT_EXPIRY  = '7d';

// 10 login attempts per IP per 15 minutes
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many login attempts. Please try again in 15 minutes.' },
});

// 5 register attempts per IP per hour
const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many accounts created from this IP. Please try again later.' },
});

function signToken(userId) {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET is not set in environment');
  return jwt.sign({ userId }, secret, { expiresIn: JWT_EXPIRY });
}

// POST /api/auth/login
router.post('/login', loginLimiter, async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) {
    return fail(res, 'email and password are required.', 400);
  }
  try {
    const raw = await userQ.findRawByEmail(email);
    if (!raw || !(await bcrypt.compare(password, raw.password_hash))) {
      log('POST', '/api/auth/login', 401);
      return fail(res, 'Invalid email or password.', 401);
    }
    const token = signToken(raw.id);
    log('POST', '/api/auth/login', 200);
    ok(res, { user: formatUser(raw), token });
  } catch (err) {
    dbErr(res, err, '/api/auth/login');
  }
});

// POST /api/auth/register
router.post('/register', registerLimiter, async (req, res) => {
  const { name, email, password, account_type } = req.body ?? {};
  if (!name || !email || !password) {
    log('POST', '/api/auth/register', 400);
    return fail(res, 'name, email, and password are required.', 400);
  }
  const validTypes = ['user', 'dealer', 'shopkeeper'];
  const accountType = validTypes.includes(account_type) ? account_type : 'user';
  try {
    const existing = await userQ.findRawByEmail(email);
    if (existing) {
      log('POST', '/api/auth/register', 409);
      return fail(res, 'Email is already in use.', 409);
    }
    const hash = await bcrypt.hash(password, SALT_ROUNDS);
    const id   = `u_${uuidv4().slice(0, 8)}`;
    const user = await userQ.create(id, name, email, hash, accountType);
    const token = signToken(id);
    log('POST', '/api/auth/register', 201);
    ok(res, { user, token }, 201);
  } catch (err) {
    dbErr(res, err, '/api/auth/register');
  }
});

// POST /api/auth/refresh
// Requires a valid (non-expired) token in Authorization header.
// Returns a fresh 7-day token — used after biometric login succeeds.
router.post('/refresh', (req, res) => {
  const header = req.headers['authorization'] ?? '';
  const token  = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return fail(res, 'No token provided.', 401);

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const newToken = signToken(payload.userId);
    log('POST', '/api/auth/refresh', 200);
    ok(res, { token: newToken });
  } catch {
    log('POST', '/api/auth/refresh', 401);
    fail(res, 'Token is invalid or expired. Please log in again.', 401);
  }
});

// POST /api/auth/logout
router.post('/logout', (_req, res) => {
  log('POST', '/api/auth/logout', 200);
  ok(res, { message: 'Logged out.' });
});

module.exports = router;