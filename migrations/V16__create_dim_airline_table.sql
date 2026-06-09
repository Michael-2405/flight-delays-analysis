-- =============================================================
-- Script Name: V16__create_dim_airline_table.sql
-- Description: Creates gold.dim_airline — airline dimension for
--              the star schema. Loaded from silver.airline_clean
--              via UPSERT (SCD Type 1). Surrogate key generated
--              by IDENTITY. UNIQUE constraint on iata_code.
-- Schema:      gold
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS gold.dim_airline (
  airline_id   INT          NOT NULL GENERATED ALWAYS AS IDENTITY,
  iata_code    VARCHAR(10)  NOT NULL,
  airline_name VARCHAR(100) NOT NULL,
  created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMP    NULL,

  CONSTRAINT pk_dim_airline PRIMARY KEY (airline_id),
  CONSTRAINT uq_dim_airline_iata_code UNIQUE (iata_code)
);

COMMENT ON TABLE gold.dim_airline IS
'Airlines operating US domestic flights in 2015. SCD Tipo 1.';
COMMENT ON COLUMN gold.dim_airline.airline_id IS
'Surrogate key — auto-generated identity.';
COMMENT ON COLUMN gold.dim_airline.iata_code IS
'IATA 2-letter code identifying the airline.';
COMMENT ON COLUMN gold.dim_airline.airline_name IS
'Full name of the airline.';
COMMENT ON COLUMN gold.dim_airline.created_at IS
'Timestamp when the record was created.';
COMMENT ON COLUMN gold.dim_airline.updated_at IS
'Timestamp of the last update to the record.';
