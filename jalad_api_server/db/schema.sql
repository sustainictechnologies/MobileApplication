-- ============================================================
--  JALAD DB  –  PostgreSQL Schema
--  Database: jalad_db
-- ============================================================

-- ── Users ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id                  VARCHAR(50)    PRIMARY KEY,
  name                VARCHAR(255)   NOT NULL,
  email               VARCHAR(255)   NOT NULL UNIQUE,
  password_hash       VARCHAR(255)   NOT NULL,
  avatar_url          TEXT,
  total_litres_saved  NUMERIC(10,2)  NOT NULL DEFAULT 0,
  total_refills       INTEGER        NOT NULL DEFAULT 0,
  wallet_balance      NUMERIC(10,2)  NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── Water Stations ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS water_stations (
  id                        VARCHAR(50)    PRIMARY KEY,
  name                      VARCHAR(255)   NOT NULL,
  address                   TEXT           NOT NULL,
  latitude                  NUMERIC(11,7)  NOT NULL,
  longitude                 NUMERIC(11,7)  NOT NULL,
  is_online                 BOOLEAN        NOT NULL DEFAULT TRUE,
  price_per_litre           NUMERIC(8,2)   NOT NULL DEFAULT 15.00,
  available_capacity_litres NUMERIC(10,2)  NOT NULL DEFAULT 0,
  rating                    NUMERIC(3,1)   NOT NULL DEFAULT 4.0,
  review_count              INTEGER        NOT NULL DEFAULT 0,
  amenities                 TEXT[]         NOT NULL DEFAULT '{}',
  created_at                TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── Water Quality (one row per station, updated in-place) ────
CREATE TABLE IF NOT EXISTS water_quality (
  id             UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  station_id     VARCHAR(50)    NOT NULL UNIQUE REFERENCES water_stations(id) ON DELETE CASCADE,
  label          VARCHAR(20)    NOT NULL DEFAULT 'Good',
  ph_level       NUMERIC(5,2)   NOT NULL DEFAULT 7.0,
  tds_level      NUMERIC(8,2)   NOT NULL DEFAULT 100,
  turbidity      NUMERIC(6,2)   NOT NULL DEFAULT 1.0,
  temperature    NUMERIC(5,2)   NOT NULL DEFAULT 25.0,
  last_tested_at TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── Refill Records ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS refill_records (
  id            VARCHAR(50)    PRIMARY KEY,
  user_id       VARCHAR(50)    NOT NULL REFERENCES users(id),
  station_id    VARCHAR(50)    NOT NULL REFERENCES water_stations(id),
  station_name  VARCHAR(255)   NOT NULL,
  litres_filled NUMERIC(10,2)  NOT NULL,
  amount_paid   NUMERIC(10,2)  NOT NULL,
  refill_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  created_at    TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── Indexes ──────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_refill_records_user_id    ON refill_records(user_id);
CREATE INDEX IF NOT EXISTS idx_refill_records_station_id ON refill_records(station_id);
CREATE INDEX IF NOT EXISTS idx_refill_records_refill_at  ON refill_records(refill_at DESC);
CREATE INDEX IF NOT EXISTS idx_water_stations_location   ON water_stations(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_users_email               ON users(email);
