'use strict';

const express  = require('express');
const { ok, fail, log, dbErr } = require('../helpers');
const stationQ = require('../queries/station.queries');
const userQ    = require('../queries/user.queries');
const refillQ  = require('../queries/refill.queries');

const router = express.Router();

router.get('/station/:id', async (req, res) => {
  try {
    const station = await stationQ.findById(req.params.id);
    if (!station) { log('GET', req.path, 404); return fail(res, 'Station not found.', 404); }
    log('GET', req.path, 200);
    ok(res, {
      confirmed: true,
      station: {
        id:                        station.id,
        name:                      station.name,
        address:                   station.address,
        is_online:                 station.is_online,
        available_capacity_litres: station.available_capacity_litres,
        price_per_litre:           station.price_per_litre,
        water_quality_label:       station.water_quality?.label ?? null,
      },
    });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.get('/user/:id', async (req, res) => {
  try {
    const user = await userQ.findById(req.params.id);
    if (!user) { log('GET', req.path, 404); return fail(res, 'User not found.', 404); }
    log('GET', req.path, 200);
    ok(res, {
      confirmed: true,
      user: {
        id:                 user.id,
        name:               user.name,
        email:              user.email,
        wallet_balance:     user.wallet_balance,
        total_refills:      user.total_refills,
        total_litres_saved: user.total_litres_saved,
      },
    });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.get('/refill/:id', async (req, res) => {
  try {
    const refill = await refillQ.findById(req.params.id);
    if (!refill) { log('GET', req.path, 404); return fail(res, 'Refill not found.', 404); }
    const [user, station] = await Promise.all([
      userQ.findById(refill.user_id),
      stationQ.findById(refill.station_id),
    ]);
    log('GET', req.path, 200);
    ok(res, {
      confirmed:      true,
      refill,
      user_name:      user?.name      ?? null,
      station_online: station?.is_online ?? null,
    });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

router.post('/refill', async (req, res) => {
  const { user_id, station_id, litres_filled, amount_paid } = req.body ?? {};
  const litres = Number(litres_filled);
  const amount = Number(amount_paid);
  const errors = [];
  try {
    const [user, station] = await Promise.all([
      userQ.findById(user_id),
      stationQ.findById(station_id),
    ]);
    if (!user)                                                          errors.push('user_id not found');
    if (!station)                                                       errors.push('station_id not found');
    if (station && !station.is_online)                                  errors.push('station is offline');
    if (isNaN(litres) || litres <= 0)                                   errors.push('litres_filled must be a positive number');
    if (isNaN(amount) || amount < 0)                                    errors.push('amount_paid must be a non-negative number');
    if (user    && amount > user.wallet_balance)                        errors.push('insufficient wallet balance');
    if (station && litres > station.available_capacity_litres)          errors.push('requested litres exceed station capacity');
    if (errors.length) { log('POST', req.path, 422); return fail(res, errors.join('; '), 422); }
    log('POST', req.path, 200);
    ok(res, {
      confirmed: true,
      preview: {
        user_id,
        user_name:            user.name,
        station_id,
        station_name:         station.name,
        litres_filled:        litres,
        amount_paid:          amount,
        wallet_balance_after: +(user.wallet_balance - amount).toFixed(2),
        capacity_after:       +(station.available_capacity_litres - litres).toFixed(2),
      },
    });
  } catch (err) {
    dbErr(res, err, req.path);
  }
});

module.exports = router;
