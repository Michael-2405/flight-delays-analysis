-- =============================================================
-- Script Name: V2__create_airlines_raw_table.sql
-- Description: Creates bronze.airlines_raw — raw airline data
--              loaded from airlines.csv via Python ingestion pipeline.
--              Stores IATA code and airline name exactly as received.
--              Load strategy: truncate + full load.
-- Schema:      bronze
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS bronze.airlines_raw (
  iata_code   VARCHAR(10)  NOT NULL,
  airline     VARCHAR(100) NOT NULL,
  source_file VARCHAR(100) NOT NULL,
  loaded_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);
