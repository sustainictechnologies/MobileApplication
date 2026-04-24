'use strict';

const express = require('express');
const { ok, dbErr } = require('../helpers');
const pool = require('../db');

const router = express.Router();

router.get('/health', async (_req, res) => {
  try {
    const [s, u, r] = await Promise.all([
      pool.query('SELECT COUNT(*) FROM water_stations'),
      pool.query('SELECT COUNT(*) FROM users'),
      pool.query('SELECT COUNT(*) FROM refill_records'),
    ]);
    ok(res, {
      status: 'ok',
      counts: {
        stations: parseInt(s.rows[0].count),
        users:    parseInt(u.rows[0].count),
        refills:  parseInt(r.rows[0].count),
      },
      uptime: process.uptime().toFixed(1) + 's',
    });
  } catch (err) {
    dbErr(res, err, '/api/health');
  }
});

module.exports = router;
