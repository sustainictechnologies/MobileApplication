'use strict';

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

pool.on('error', (err) => {
  console.error('Unexpected DB client error:', err.message);
  process.exit(-1);
});

module.exports = pool;
