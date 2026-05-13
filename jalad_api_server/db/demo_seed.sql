-- ============================================================
--  JALAD Demo Seed Data
--  Login: jalad@jalad.com / jalad
-- ============================================================

-- ── Demo User ────────────────────────────────────────────────
INSERT INTO users (id, name, email, password_hash, account_type, total_litres_saved, total_refills, wallet_balance)
VALUES (
  'demo-jalad-001',
  'JALAD Demo',
  'jalad@jalad.com',
  '$2b$10$Qmp5/GxZ.tvJqlBZFGICEuWiWKoB918rMr4G1r5pXxwk4RSuyGQVS',
  'user',
  47.50,
  8,
  250.00
)
ON CONFLICT (id) DO NOTHING;

-- ── Water Stations (Kolhapur, Maharashtra) ───────────────────
INSERT INTO water_stations (id, name, address, latitude, longitude, is_online, price_per_litre, available_capacity_litres, rating, review_count, amenities)
VALUES
  ('ws-kol-001', 'JALAD Station – Rajaram Road',       'Near Rajaram College Gate, Rajaram Road, Kolhapur',      16.7054320, 74.2432870, TRUE,  12.00, 200.00, 4.5, 38, ARRAY['Filtered','Cold Water','24/7']),
  ('ws-kol-002', 'JALAD Station – Shivaji University', 'Main Gate, Shivaji University Campus, Kolhapur',          16.6897500, 74.2589600, TRUE,  10.00, 150.00, 4.7, 52, ARRAY['Filtered','UV Purified','Student Friendly']),
  ('ws-kol-003', 'JALAD Station – Mahadwar Road',      'Opp. Mahalaxmi Temple, Mahadwar Road, Kolhapur',          16.7028900, 74.2318500, TRUE,  12.00, 180.00, 4.3, 29, ARRAY['Filtered','Minerals Added']),
  ('ws-kol-004', 'JALAD Station – Tarabai Park',       'Near Tarabai Park Entrance, Kolhapur',                    16.6952100, 74.2201700, FALSE,  8.00,   0.00, 4.1, 17, ARRAY['Filtered','Eco Friendly']),
  ('ws-kol-005', 'JALAD Station – Shahupuri',          'Sahupuri 5th Lane, Opp. Bus Stand, Kolhapur',             16.7101300, 74.2497400, TRUE,  10.00, 220.00, 4.6, 44, ARRAY['Filtered','Cold Water','Hot Water','24/7'])
ON CONFLICT (id) DO NOTHING;

-- ── Water Quality ────────────────────────────────────────────
INSERT INTO water_quality (station_id, label, ph_level, tds_level, turbidity, temperature, last_tested_at)
VALUES
  ('ws-kol-001', 'Excellent', 7.20, 85.00,  0.80, 24.5, NOW() - INTERVAL '1 day'),
  ('ws-kol-002', 'Excellent', 7.10, 72.00,  0.60, 23.0, NOW() - INTERVAL '2 hours'),
  ('ws-kol-003', 'Good',      7.35, 110.00, 1.10, 25.5, NOW() - INTERVAL '3 days'),
  ('ws-kol-004', 'Good',      7.25, 98.00,  0.95, 26.0, NOW() - INTERVAL '5 days'),
  ('ws-kol-005', 'Excellent', 7.15, 80.00,  0.70, 24.0, NOW() - INTERVAL '6 hours')
ON CONFLICT (station_id) DO NOTHING;

-- ── Refill Records (8 refills for demo user) ─────────────────
INSERT INTO refill_records (id, user_id, station_id, station_name, litres_filled, amount_paid, refill_at)
VALUES
  ('rr-001', 'demo-jalad-001', 'ws-kol-001', 'JALAD Station – Rajaram Road',       5.00,  60.00, NOW() - INTERVAL '45 days'),
  ('rr-002', 'demo-jalad-001', 'ws-kol-002', 'JALAD Station – Shivaji University', 7.00,  70.00, NOW() - INTERVAL '38 days'),
  ('rr-003', 'demo-jalad-001', 'ws-kol-005', 'JALAD Station – Shahupuri',          3.00,  30.00, NOW() - INTERVAL '30 days'),
  ('rr-004', 'demo-jalad-001', 'ws-kol-001', 'JALAD Station – Rajaram Road',       8.00,  96.00, NOW() - INTERVAL '22 days'),
  ('rr-005', 'demo-jalad-001', 'ws-kol-003', 'JALAD Station – Mahadwar Road',      6.00,  72.00, NOW() - INTERVAL '15 days'),
  ('rr-006', 'demo-jalad-001', 'ws-kol-002', 'JALAD Station – Shivaji University', 4.50,  45.00, NOW() - INTERVAL '10 days'),
  ('rr-007', 'demo-jalad-001', 'ws-kol-005', 'JALAD Station – Shahupuri',          5.00,  50.00, NOW() - INTERVAL '4 days'),
  ('rr-008', 'demo-jalad-001', 'ws-kol-001', 'JALAD Station – Rajaram Road',       9.00, 108.00, NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;
