-- =============================================================
-- Script Name: V26__create_airport_iata_raw.sql
-- Description: Creates bronze.airport_iata_raw — BTS IATA airport
--              code lookup table. Loaded from L_AIRPORT.csv via
--              Python AirportIataPipeline (latin1 encoding).
--              Used with airport_id_raw to build the DOT→IATA
--              mapping table in V28.
-- Schema:      bronze
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS bronze.airport_iata_raw (
  code        VARCHAR(10)  NOT NULL,
  description VARCHAR(300) NOT NULL,
  source_file VARCHAR(100) NOT NULL,
  loaded_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);
