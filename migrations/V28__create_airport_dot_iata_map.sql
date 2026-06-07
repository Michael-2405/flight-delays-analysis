-- Script Name: V28__create_airport_dot_iata_map.sql
-- Description: Creates and populates etl.airport_dot_iata_map — a reference
--              table that maps DOT numeric airport codes to IATA codes.
--              Built by crossing L_AIRPORT_ID.csv (DOT codes) with
--              L_AIRPORT.csv (IATA codes) on description match.
--              Only includes unambiguous mappings (1 DOT → 1 IATA).
--              Ambiguous cases (civil/military shared airports) resolved
--              manually using the civil IATA code.
--              Used by usp_load_silver_flight to translate numeric airport
--              codes in flights_raw before loading silver.flight_clean.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
--   2026-06-06 | Michael Espinosa | Add manual mappings for civil/military shared airports

CREATE TABLE IF NOT EXISTS etl.airport_dot_iata_map(
  dot_code    INT,
  iata_code   VARCHAR(10),

  CONSTRAINT pk_airport_dot_iata_map PRIMARY KEY (dot_code)
);

TRUNCATE TABLE etl.airport_dot_iata_map;

INSERT INTO etl.airport_dot_iata_map (dot_code, iata_code)
SELECT
    aid.code        AS dot_code,
    MIN(air.code)   AS iata_code
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
    (10423, 'AUS'),  -- Austin, TX: Austin - Bergstrom International
    (12173, 'HNL'),  -- Honolulu, HI: Daniel K Inouye International
    (16218, 'YUM');  -- Yuma, AZ: Yuma MCAS/Yuma International
