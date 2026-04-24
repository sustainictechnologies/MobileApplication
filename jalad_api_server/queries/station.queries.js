'use strict';

const { v4: uuidv4 } = require('uuid');
const pool = require('../db');
const { formatStation } = require('../helpers');

const STATION_SELECT = `
  SELECT ws.id, ws.name, ws.address,
         ws.latitude, ws.longitude, ws.is_online,
         ws.price_per_litre, ws.available_capacity_litres,
         ws.rating, ws.review_count, ws.amenities,
         json_build_object(
           'label',          wq.label,
           'ph_level',       wq.ph_level,
           'tds_level',      wq.tds_level,
           'turbidity',      wq.turbidity,
           'temperature',    wq.temperature,
           'last_tested_at', wq.last_tested_at
         ) AS water_quality
  FROM water_stations ws
  LEFT JOIN water_quality wq ON wq.station_id = ws.id
`;

async function getAll(onlineFilter) {
  let query = STATION_SELECT;
  if      (onlineFilter === 'true')  query += ' WHERE ws.is_online = TRUE';
  else if (onlineFilter === 'false') query += ' WHERE ws.is_online = FALSE';
  query += ' ORDER BY ws.name';
  const { rows } = await pool.query(query);
  return rows.map(formatStation);
}

async function findById(id) {
  const { rows } = await pool.query(STATION_SELECT + ' WHERE ws.id = $1', [id]);
  return rows[0] ? formatStation(rows[0]) : null;
}

async function create(body) {
  const id = `ws_${uuidv4().slice(0, 6)}`;
  const wq = body.water_quality ?? {};
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `INSERT INTO water_stations
         (id, name, address, latitude, longitude, is_online, price_per_litre, available_capacity_litres, rating, review_count, amenities)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)`,
      [
        id,
        body.name    ?? 'New Station',
        body.address ?? '',
        Number(body.latitude)  || 0,
        Number(body.longitude) || 0,
        body.is_online ?? true,
        Number(body.price_per_litre)           || 15,
        Number(body.available_capacity_litres) || 100,
        Number(body.rating)       || 4.0,
        Number(body.review_count) || 0,
        body.amenities ?? [],
      ]
    );
    await client.query(
      `INSERT INTO water_quality (station_id, label, ph_level, tds_level, turbidity, temperature, last_tested_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [id, wq.label??'Good', Number(wq.ph_level)||7.0, Number(wq.tds_level)||100, Number(wq.turbidity)||1.0, Number(wq.temperature)||25.0, wq.last_tested_at??new Date().toISOString()]
    );
    await client.query('COMMIT');
    return findById(id);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function update(id, body) {
  const fields = [];
  const values = [id];
  let i = 2;
  const map = {
    name:                      body.name,
    address:                   body.address,
    latitude:                  body.latitude  != null ? Number(body.latitude)  : undefined,
    longitude:                 body.longitude != null ? Number(body.longitude) : undefined,
    is_online:                 body.is_online,
    price_per_litre:           body.price_per_litre           != null ? Number(body.price_per_litre)           : undefined,
    available_capacity_litres: body.available_capacity_litres != null ? Number(body.available_capacity_litres) : undefined,
    rating:                    body.rating       != null ? Number(body.rating)       : undefined,
    review_count:              body.review_count != null ? Number(body.review_count) : undefined,
    amenities:                 body.amenities,
  };
  for (const [col, val] of Object.entries(map)) {
    if (val !== undefined) { fields.push(`${col} = $${i++}`); values.push(val); }
  }
  if (fields.length) {
    fields.push('updated_at = NOW()');
    await pool.query(`UPDATE water_stations SET ${fields.join(', ')} WHERE id = $1`, values);
  }
  if (body.water_quality) {
    const wq = body.water_quality;
    await pool.query(
      `INSERT INTO water_quality (station_id, label, ph_level, tds_level, turbidity, temperature, last_tested_at)
       VALUES ($1,$2,$3,$4,$5,$6,NOW())
       ON CONFLICT (station_id) DO UPDATE SET
         label=EXCLUDED.label, ph_level=EXCLUDED.ph_level, tds_level=EXCLUDED.tds_level,
         turbidity=EXCLUDED.turbidity, temperature=EXCLUDED.temperature, last_tested_at=NOW()`,
      [id, wq.label??'Good', wq.ph_level??7.0, wq.tds_level??100, wq.turbidity??1.0, wq.temperature??25.0]
    );
  }
  return findById(id);
}

async function remove(id) {
  const { rowCount } = await pool.query('DELETE FROM water_stations WHERE id = $1', [id]);
  return rowCount > 0;
}

async function setStatus(id, isOnline) {
  const { rows, rowCount } = await pool.query(
    'UPDATE water_stations SET is_online=$2, updated_at=NOW() WHERE id=$1 RETURNING id, is_online',
    [id, isOnline]
  );
  return rowCount > 0 ? rows[0] : null;
}

async function setCapacity(id, capacity) {
  const { rows, rowCount } = await pool.query(
    'UPDATE water_stations SET available_capacity_litres=$2, updated_at=NOW() WHERE id=$1 RETURNING id, available_capacity_litres',
    [id, capacity]
  );
  return rowCount > 0
    ? { id: rows[0].id, available_capacity_litres: parseFloat(rows[0].available_capacity_litres) }
    : null;
}

async function setWaterQuality(id, { label, ph_level, tds_level, turbidity, temperature }) {
  const check = await pool.query('SELECT id FROM water_stations WHERE id=$1', [id]);
  if (!check.rows.length) return null;
  const { rows } = await pool.query(
    `INSERT INTO water_quality (station_id, label, ph_level, tds_level, turbidity, temperature, last_tested_at)
     VALUES ($1, COALESCE($2,'Good'), COALESCE($3,7.0), COALESCE($4,100), COALESCE($5,1.0), COALESCE($6,25.0), NOW())
     ON CONFLICT (station_id) DO UPDATE SET
       label          = COALESCE($2, water_quality.label),
       ph_level       = COALESCE($3, water_quality.ph_level),
       tds_level      = COALESCE($4, water_quality.tds_level),
       turbidity      = COALESCE($5, water_quality.turbidity),
       temperature    = COALESCE($6, water_quality.temperature),
       last_tested_at = NOW()
     RETURNING *`,
    [id, label??null, ph_level!=null?Number(ph_level):null, tds_level!=null?Number(tds_level):null, turbidity!=null?Number(turbidity):null, temperature!=null?Number(temperature):null]
  );
  return {
    label:          rows[0].label,
    ph_level:       parseFloat(rows[0].ph_level),
    tds_level:      parseFloat(rows[0].tds_level),
    turbidity:      parseFloat(rows[0].turbidity),
    temperature:    parseFloat(rows[0].temperature),
    last_tested_at: rows[0].last_tested_at,
  };
}

module.exports = { getAll, findById, create, update, remove, setStatus, setCapacity, setWaterQuality };
