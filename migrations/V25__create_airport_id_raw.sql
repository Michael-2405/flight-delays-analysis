-- =============================================================
-- Script Name: V25__create_airport_id_raw.sql
-- Description: Creates bronze.airport_id_raw — BTS DOT numeric
--              airport code lookup table. Loaded from L_AIRPORT_ID.csv
--              via Python AirportIdPipeline (latin1 encoding).
--              Used with airport_iata_raw to build the DOT→IATA
--              mapping table in V28.
-- Schema:      bronze
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS bronze.airport_id_raw (
  code        INT          NOT NULL,
  description VARCHAR(300) NOT NULL,
  source_file VARCHAR(100) NOT NULL,
  loaded_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);
