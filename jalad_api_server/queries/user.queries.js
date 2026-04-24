'use strict';

const pool = require('../db');
const { formatUser } = require('../helpers');

async function getAll() {
  const { rows } = await pool.query('SELECT * FROM users ORDER BY created_at');
  return rows.map(formatUser);
}

async function findById(id) {
  const { rows } = await pool.query('SELECT * FROM users WHERE id=$1', [id]);
  return rows[0] ? formatUser(rows[0]) : null;
}

// Returns raw row including password_hash — only used for login comparison
async function findRawByEmail(email) {
  const { rows } = await pool.query('SELECT * FROM users WHERE email=$1', [email]);
  return rows[0] ?? null;
}

async function create(id, name, email, passwordHash) {
  const { rows } = await pool.query(
    `INSERT INTO users (id, name, email, password_hash) VALUES ($1,$2,$3,$4) RETURNING *`,
    [id, name, email, passwordHash]
  );
  return formatUser(rows[0]);
}

async function update(id, { name, email, avatar_url }) {
  const { rows, rowCount } = await pool.query(
    `UPDATE users SET
       name       = COALESCE($2, name),
       email      = COALESCE($3, email),
       avatar_url = COALESCE($4, avatar_url),
       updated_at = NOW()
     WHERE id=$1 RETURNING *`,
    [id, name??null, email??null, avatar_url??null]
  );
  return rowCount > 0 ? formatUser(rows[0]) : null;
}

async function updateWallet(id, operation, amount) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { rows } = await client.query('SELECT * FROM users WHERE id=$1 FOR UPDATE', [id]);
    if (!rows.length) {
      await client.query('ROLLBACK');
      return { error: 'not_found' };
    }
    const balance = parseFloat(rows[0].wallet_balance);
    if (operation === 'deduct' && balance < amount) {
      await client.query('ROLLBACK');
      return { error: 'insufficient' };
    }
    const newBalance = +(operation === 'topup' ? balance + amount : balance - amount).toFixed(2);
    const updated = await client.query(
      'UPDATE users SET wallet_balance=$2, updated_at=NOW() WHERE id=$1 RETURNING id, wallet_balance',
      [id, newBalance]
    );
    await client.query('COMMIT');
    return { id: updated.rows[0].id, wallet_balance: parseFloat(updated.rows[0].wallet_balance) };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { getAll, findById, findRawByEmail, create, update, updateWallet };
