-- =============================================================
-- Script Name: V28__create_airport_dot_iata_map.sql
-- Description: Creates and populates etl.airport_dot_iata_map —
--              reference table mapping DOT numeric codes to IATA.
--              Built by crossing airport_id_raw with airport_iata_raw
--              on description match. Only unambiguous mappings included
--              (1 DOT → 1 IATA). Four civil/military shared airports
--              resolved manually using the civil IATA code.
--              Used by usp_load_silver_flight via COALESCE to translate
--              DOT codes in flights_raw before loading silver.flight_clean.
-- Schema:      etl
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
--   2026-06-06 | Michael Espinosa | Add manual mappings for civil/military airports
-- =============================================================

CREATE TABLE IF NOT EXISTS etl.airport_dot_iata_map (
  dot_code  INT         NOT NULL,
  iata_code VARCHAR(10) NOT NULL,

  CONSTRAINT pk_airport_dot_iata_map PRIMARY KEY (dot_code)
);

TRUNCATE TABLE etl.airport_dot_iata_map;

INSERT INTO etl.airport_dot_iata_map (dot_code, iata_code)
SELECT
    aid.code      AS dot_code,
    MIN(air.code) AS iata_code
FROM bronze.airport_id_raw aid
INNER JOIN bronze.airport_iata_raw air
    ON aid.description = air.description
GROUP BY aid.code
HAVING COUNT(DISTINCT air.code) = 1;

-- Manual mappings for civil/military shared airports
-- Using civil IATA code in all cases
INSERT INTO etl.airport_dot_iata_map (dot_code, iata_code)
VALUES
    (10170, 'ADQ'),  -- Kodiak, AK: Kodiak Airport
    (10423, 'AUS'),  -- Austin, TX: Austin-Bergstrom International
    (12173, 'HNL'),  -- Honolulu, HI: Daniel K Inouye International
    (16218, 'YUM');  -- Yuma, AZ: Yuma MCAS/Yuma International
