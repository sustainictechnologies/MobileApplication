'use strict';

const { v4: uuidv4 } = require('uuid');
const pool = require('../db');
const { formatRefill } = require('../helpers');

async function getAll(userId) {
  let query  = 'SELECT * FROM refill_records';
  const params = [];
  if (userId) { query += ' WHERE user_id=$1'; params.push(userId); }
  query += ' ORDER BY refill_at DESC';
  const { rows } = await pool.query(query, params);
  return rows.map(formatRefill);
}

async function findById(id) {
  const { rows } = await pool.query('SELECT * FROM refill_records WHERE id=$1', [id]);
  return rows[0] ? formatRefill(rows[0]) : null;
}

async function create(body) {
  const id     = `r_${uuidv4().slice(0, 6)}`;
  const litres = Number(body.litres_filled) || 1;
  const amount = Number(body.amount_paid)   || 0;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { rows } = await client.query(
      `INSERT INTO refill_records (id, user_id, station_id, station_name, litres_filled, amount_paid, refill_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [id, body.user_id??'', body.station_id??'', body.station_name??'', litres, amount, body.refill_at??new Date().toISOString()]
    );
    if (body.user_id) {
      await client.query(
        `UPDATE users SET
           total_litres_saved = total_litres_saved + $2,
           total_refills      = total_refills + 1,
           wallet_balance     = wallet_balance - $3,
           updated_at         = NOW()
         WHERE id=$1`,
        [body.user_id, litres, amount]
      );
    }
    await client.query('COMMIT');
    return formatRefill(rows[0]);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function update(id, body) {
  const { rows, rowCount } = await pool.query(
    `UPDATE refill_records SET
       station_name  = COALESCE($2, station_name),
       litres_filled = COALESCE($3, litres_filled),
       amount_paid   = COALESCE($4, amount_paid),
       refill_at     = COALESCE($5, refill_at)
     WHERE id=$1 RETURNING *`,
    [id, body.station_name??null, body.litres_filled!=null?Number(body.litres_filled):null, body.amount_paid!=null?Number(body.amount_paid):null, body.refill_at??null]
  );
  return rowCount > 0 ? formatRefill(rows[0]) : null;
}

async function remove(id) {
  const { rowCount } = await pool.query('DELETE FROM refill_records WHERE id=$1', [id]);
  return rowCount > 0;
}

module.exports = { getAll, findById, create, update, remove };
