-- Script Name: V26__create_airport_iata_raw_table.sql
-- Description: Creates the airport_iata_raw table in the bronze schema.
--              Loaded from L_AIRPORT.csv (BTS IATA lookup table).
--              Contains IATA airport codes and descriptions.
--              Used for DOT→IATA enrichment of airports_raw.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

CREATE TABLE If NOT EXISTS bronze.airport_iata_raw (
  code          VARCHAR(10)             NOT NULL,
  description   VARCHAR(300)    NOT NULL,
  source_file   VARCHAR(100)    NOT NULL,
  loaded_at     TIMESTAMP       NOT NULL DEFAULT NOW()
);
