'use strict';

const express = require('express');
const bcrypt  = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const { ok, fail, log, dbErr, formatUser } = require('../helpers');
const userQ = require('../queries/user.queries');

const router      = express.Router();
const SALT_ROUNDS = 10;

router.post('/login', async (req, res) => {
  const { email, password } = req.body ?? {};
  try {
    const raw = await userQ.findRawByEmail(email);
    if (!raw || !(await bcrypt.compare(password ?? '', raw.password_hash))) {
      log('POST', '/api/auth/login', 401);
      return fail(res, 'Invalid email or password.', 401);
    }
    log('POST', '/api/auth/login', 200);
    ok(res, { user: formatUser(raw), token: `jwt-${raw.id}-${Date.now()}` });
  } catch (err) {
    dbErr(res, err, '/api/auth/login');
  }
});

router.post('/logout', (_req, res) => {
  log('POST', '/api/auth/logout', 200);
  ok(res, { message: 'Logged out.' });
});

router.post('/register', async (req, res) => {
  const { name, email, password } = req.body ?? {};
  if (!name || !email || !password) {
    log('POST', '/api/auth/register', 400);
    return fail(res, 'name, email, and password are required.');
  }
  try {
    const existing = await userQ.findRawByEmail(email);
    if (existing) {
      log('POST', '/api/auth/register', 409);
      return fail(res, 'Email is already in use.', 409);
    }
    const hash = await bcrypt.hash(password, SALT_ROUNDS);
    const id   = `u_${uuidv4().slice(0, 8)}`;
    const user = await userQ.create(id, name, email, hash);
    log('POST', '/api/auth/register', 201);
    ok(res, { user, token: `jwt-${id}-${Date.now()}` }, 201);
  } catch (err) {
    dbErr(res, err, '/api/auth/register');
  }
});

module.exports = router;
