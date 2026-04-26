'use strict';

const express = require('express');
const cors    = require('cors');
const path    = require('path');
require('dotenv').config();

const { fail }        = require('./helpers');
const { requireAuth } = require('./middleware/auth');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ─── Public routes (no token needed) ─────────────────────────────────────────
app.use('/api/auth',  require('./routes/auth'));
app.use('/api',       require('./routes/health'));

// ─── Protected routes (valid JWT required) ────────────────────────────────────
app.use('/api/stations', requireAuth, require('./routes/stations'));
app.use('/api/users',    requireAuth, require('./routes/users'));
app.use('/api/refills',  requireAuth, require('./routes/refills'));
app.use('/api/confirm',  requireAuth, require('./routes/confirm'));

// ─── Fallback ─────────────────────────────────────────────────────────────────
app.use((req, res) => {
  if (req.path.startsWith('/api/')) return fail(res, `Unknown route: ${req.method} ${req.path}`, 404);
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ─── Start ────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log('');
  console.log('  ╔══════════════════════════════════════════╗');
  console.log('  ║   JALAD API Server  (PostgreSQL)          ║');
  console.log(`  ║   http://localhost:${PORT}                ║`);
  console.log('  ╚══════════════════════════════════════════╝');
  console.log('');
  console.log('  Dashboard → http://localhost:' + PORT);
  console.log('  API base  → http://localhost:' + PORT + '/api');
  console.log('  Health    → http://localhost:' + PORT + '/api/health');
  console.log('');
});