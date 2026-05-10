'use strict';

const ok   = (res, data, status = 200) => res.status(status).json({ success: true,  data });
const fail = (res, msg,  status = 400) => res.status(status).json({ success: false, error: msg });

function log(method, p, status) {
  const stamp = new Date().toTimeString().slice(0, 8);
  console.log(`[${stamp}]  ${method.padEnd(6)} ${p.padEnd(35)} → ${status}`);
}

function dbErr(res, err, p) {
  console.error(`DB error [${p}]:`, err.message);
  return fail(res, 'Database error.', 500);
}

// pg returns NUMERIC as strings — parse back to numbers
function formatStation(row) {
  return {
    id:                        row.id,
    name:                      row.name,
    address:                   row.address,
    latitude:                  parseFloat(row.latitude),
    longitude:                 parseFloat(row.longitude),
    is_online:                 row.is_online,
    price_per_litre:           parseFloat(row.price_per_litre),
    available_capacity_litres: parseFloat(row.available_capacity_litres),
    rating:                    parseFloat(row.rating),
    review_count:              parseInt(row.review_count),
    amenities:                 row.amenities || [],
    water_quality: row.water_quality ? {
      label:          row.water_quality.label,
      ph_level:       parseFloat(row.water_quality.ph_level),
      tds_level:      parseFloat(row.water_quality.tds_level),
      turbidity:      parseFloat(row.water_quality.turbidity),
      temperature:    parseFloat(row.water_quality.temperature),
      last_tested_at: row.water_quality.last_tested_at,
    } : null,
  };
}

function formatUser(row) {
  return {
    id:                 row.id,
    name:               row.name,
    email:              row.email,
    account_type:       row.account_type ?? 'user',
    qr_code:            row.qr_code,
    avatar_url:         row.avatar_url,
    total_litres_saved: parseFloat(row.total_litres_saved),
    total_refills:      parseInt(row.total_refills),
    wallet_balance:     parseFloat(row.wallet_balance),
    created_at:         row.created_at,
  };
}

function formatRefill(row) {
  return {
    id:            row.id,
    user_id:       row.user_id,
    station_id:    row.station_id,
    station_name:  row.station_name,
    litres_filled: parseFloat(row.litres_filled),
    amount_paid:   parseFloat(row.amount_paid),
    refill_at:     row.refill_at,
  };
}

module.exports = { ok, fail, log, dbErr, formatStation, formatUser, formatRefill };
