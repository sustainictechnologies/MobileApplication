'use strict';

const express  = require('express');
const { ok, fail, log, dbErr } = require('../helpers');
const stationQ = require('../queries/station.queries');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const stations = await stationQ.getAll(req.query.online);
    log('GET', '/api/stations', 200);
    ok(res, stations);
  } catch (err) {
    dbErr(res, err, '/api/stations');
  }
});

router.get('/:id', async (req, res) => {
  try {
    const station = await stationQ.findById(req.params.id);
    if (!station) { log('GET', req.path, 404); return fail(res, 'Station not found.', 404); }
    log('GET', req.path, 200);
    ok(res, station);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.post('/', async (req, res) => {
  try {
    const station = await stationQ.create(req.body ?? {});
    log('POST', '/api/stations', 201);
    ok(res, station, 201);
  } catch (err) {
    dbErr(res, err, '/api/stations');
  }
});

router.put('/:id', async (req, res) => {
  try {
    const existing = await stationQ.findById(req.params.id);
    if (!existing) { log('PUT', req.path, 404); return fail(res, 'Station not found.', 404); }
    const station = await stationQ.update(req.params.id, req.body ?? {});
    log('PUT', req.path, 200);
    ok(res, station);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const deleted = await stationQ.remove(req.params.id);
    if (!deleted) { log('DELETE', req.path, 404); return fail(res, 'Station not found.', 404); }
    log('DELETE', req.path, 200);
    ok(res, { message: 'Station deleted.' });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.patch('/:id/status', async (req, res) => {
  if (typeof req.body.is_online !== 'boolean') {
    log('PATCH', req.path, 400);
    return fail(res, '`is_online` (boolean) is required.');
  }
  try {
    const result = await stationQ.setStatus(req.params.id, req.body.is_online);
    if (!result) { log('PATCH', req.path, 404); return fail(res, 'Station not found.', 404); }
    log('PATCH', req.path, 200);
    ok(res, result);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.patch('/:id/capacity', async (req, res) => {
  const cap = Number(req.body.available_capacity_litres);
  if (isNaN(cap) || cap < 0) {
    log('PATCH', req.path, 400);
    return fail(res, '`available_capacity_litres` must be a non-negative number.');
  }
  try {
    const result = await stationQ.setCapacity(req.params.id, cap);
    if (!result) { log('PATCH', req.path, 404); return fail(res, 'Station not found.', 404); }
    log('PATCH', req.path, 200);
    ok(res, result);
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.patch('/:id/water-quality', async (req, res) => {
  try {
    const result = await stationQ.setWaterQuality(req.params.id, req.body ?? {});
    if (!result) { log('PATCH', req.path, 404); return fail(res, 'Station not found.', 404); }
    log('PATCH', req.path, 200);
    ok(res, { id: req.params.id, water_quality: result });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

module.exports = router;
