'use strict';

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const bcrypt = require('bcrypt');
const pool   = require('../db');

async function seed() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    await client.query(
      'TRUNCATE refill_records, water_quality, water_stations, users RESTART IDENTITY CASCADE'
    );

    const hash = await bcrypt.hash('password123', 10);

    await client.query(
      `INSERT INTO users (id, name, email, password_hash, total_litres_saved, total_refills, wallet_balance, created_at) VALUES
       ('u_001', 'Sameer Powar',  'sameer@example.com', $1, 48.5, 32, 120.0, '2025-09-15T00:00:00Z'),
       ('u_002', 'Suraj Valanju', 'suraj@example.com',  $1, 22.0, 14,  55.5, '2025-11-01T00:00:00Z')`,
      [hash]
    );

    await client.query(
      `INSERT INTO water_stations (id, name, address, latitude, longitude, is_online, price_per_litre, available_capacity_litres, rating, review_count, amenities) VALUES
       ('ws_001', 'GreenDrop Station – Bandra', 'Hill Road, Bandra West, Mumbai 400050',    19.0596, 72.8295, true,  15.0, 120.0, 4.7, 234, ARRAY['24/7','UPI Payment','App Controlled']),
       ('ws_002', 'AquaPoint – Linking Road',   'Linking Road, Bandra West, Mumbai 400052', 19.0616, 72.8352, true,  15.0,  60.0, 4.3, 118, ARRAY['UPI Payment','App Controlled']),
       ('ws_003', 'JALAD Hub – SV Road',        'S.V. Road, Bandra West, Mumbai 400050',    19.0540, 72.8350, false, 15.0,   0.0, 4.5,  89, ARRAY['24/7','UPI Payment'])`
    );

    await client.query(
      `INSERT INTO water_quality (station_id, label, ph_level, tds_level, turbidity, temperature, last_tested_at) VALUES
       ('ws_001', 'Excellent', 7.2,  85, 0.4, 24.5, '2026-04-01T00:00:00Z'),
       ('ws_002', 'Good',      7.0, 110, 1.2, 25.8, '2026-03-30T00:00:00Z'),
       ('ws_003', 'Good',      7.1,  95, 0.8, 26.1, '2026-03-28T00:00:00Z')`
    );

    await client.query(
      `INSERT INTO refill_records (id, user_id, station_id, station_name, litres_filled, amount_paid, refill_at) VALUES
       ('r_001', 'u_001', 'ws_001', 'GreenDrop Station – Bandra', 1.0, 0.50, '2026-03-28T11:00:00Z'),
       ('r_002', 'u_001', 'ws_002', 'AquaPoint – Linking Road',   1.5, 1.13, '2026-03-31T17:45:00Z'),
       ('r_003', 'u_001', 'ws_001', 'GreenDrop Station – Bandra', 2.0, 1.00, '2026-04-02T08:30:00Z'),
       ('r_004', 'u_002', 'ws_002', 'AquaPoint – Linking Road',   1.0, 0.50, '2026-04-01T10:00:00Z')`
    );

    await client.query('COMMIT');
    console.log('✓ Seed data inserted successfully.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('✗ Seed failed:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

seed().catch(() => process.exit(1));
