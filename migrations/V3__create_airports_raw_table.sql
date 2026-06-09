-- =============================================================
-- Script Name: V3__create_airports_raw_table.sql
-- Description: Creates bronze.airports_raw — raw airport data
--              loaded from airports.csv via Python ingestion pipeline.
--              Latitude and longitude are nullable (ECP, PBG, UST
--              have no coordinates in the source file).
--              Load strategy: truncate + full load.
-- Schema:      bronze
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS bronze.airports_raw (
  iata_code   VARCHAR(10)    NOT NULL,
  airport     VARCHAR(200)   NOT NULL,
  city        VARCHAR(100)   NULL,
  state       VARCHAR(100)   NULL,
  country     VARCHAR(100)   NULL,
  latitude    DECIMAL(10, 6) NULL,
  longitude   DECIMAL(10, 6) NULL,
  source_file VARCHAR(100)   NOT NULL,
  loaded_at   TIMESTAMP      NOT NULL DEFAULT NOW()
);
