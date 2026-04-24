'use strict';

const express = require('express');
const { ok, fail, log, dbErr } = require('../helpers');
const userQ = require('../queries/user.queries');

const router = express.Router();

router.get('/', async (_req, res) => {
  try {
    const users = await userQ.getAll();
    log('GET', '/api/users', 200);
    ok(res, users);
  } catch (err) {
    dbErr(res, err, '/api/users');
  }
});

router.get('/:id', async (req, res) => {
  try {
    const user = await userQ.findById(req.params.id);
    if (!user) { log('GET', req.path, 404); return fail(res, 'User not found.', 404); }
    log('GET', req.path, 200);
    ok(res, user);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.put('/:id', async (req, res) => {
  const { id: _id, password: _pw, password_hash: _ph, ...fields } = req.body ?? {};
  try {
    const user = await userQ.update(req.params.id, fields);
    if (!user) { log('PUT', req.path, 404); return fail(res, 'User not found.', 404); }
    log('PUT', req.path, 200);
    ok(res, user);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.patch('/:id/wallet', async (req, res) => {
  const { operation, amount } = req.body ?? {};
  const amt = Number(amount);
  if (!['topup', 'deduct'].includes(operation)) {
    log('PATCH', req.path, 400);
    return fail(res, '`operation` must be "topup" or "deduct".');
  }
  if (isNaN(amt) || amt <= 0) {
    log('PATCH', req.path, 400);
    return fail(res, '`amount` must be a positive number.');
  }
  try {
    const result = await userQ.updateWallet(req.params.id, operation, amt);
    if (result.error === 'not_found')   { log('PATCH', req.path, 404); return fail(res, 'User not found.', 404); }
    if (result.error === 'insufficient'){ log('PATCH', req.path, 422); return fail(res, 'Insufficient wallet balance.', 422); }
    log('PATCH', req.path, 200);
    ok(res, result);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

module.exports = router;
