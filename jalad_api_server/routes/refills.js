'use strict';

const express  = require('express');
const { ok, fail, log, dbErr } = require('../helpers');
const refillQ  = require('../queries/refill.queries');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const refills = await refillQ.getAll(req.query.userId);
    log('GET', '/api/refills', 200);
    ok(res, refills);
  } catch (err) {
    dbErr(res, err, '/api/refills');
  }
});

router.get('/:id', async (req, res) => {
  try {
    const refill = await refillQ.findById(req.params.id);
    if (!refill) { log('GET', req.path, 404); return fail(res, 'Refill not found.', 404); }
    log('GET', req.path, 200);
    ok(res, refill);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.post('/', async (req, res) => {
  try {
    const refill = await refillQ.create(req.body ?? {});
    log('POST', '/api/refills', 201);
    ok(res, refill, 201);
  } catch (err) {
    dbErr(res, err, '/api/refills');
  }
});

router.put('/:id', async (req, res) => {
  try {
    const refill = await refillQ.update(req.params.id, req.body ?? {});
    if (!refill) { log('PUT', req.path, 404); return fail(res, 'Refill not found.', 404); }
    log('PUT', req.path, 200);
    ok(res, refill);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const deleted = await refillQ.remove(req.params.id);
    if (!deleted) { log('DELETE', req.path, 404); return fail(res, 'Refill not found.', 404); }
    log('DELETE', req.path, 200);
    ok(res, { message: 'Refill deleted.' });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

module.exports = router;
