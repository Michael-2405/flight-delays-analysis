-- =============================================================
-- Script Name: V27__enrich_airports_raw.sql
-- Description: Enriches bronze.airports_raw with missing airports
--              identified during EDA. Crosses airport_id_raw (DOT
--              codes) with airport_iata_raw (IATA codes) by description
--              match. Inserts only airports not already present.
--              Parses city, state and airport_name from description
--              format: "City, ST: Airport Name".
-- Schema:      bronze
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
-- =============================================================

INSERT INTO bronze.airports_raw (
    iata_code, airport, city, state, country, source_file, loaded_at
)
SELECT
    air.code                                                      AS iata_code,
    TRIM(SPLIT_PART(aid.description, ': ', 2))                    AS airport,
    SPLIT_PART(aid.description, ',', 1)                           AS city,
    TRIM(SPLIT_PART(SPLIT_PART(aid.description, ',', 2), ':', 1)) AS state,
    'USA'                                                         AS country,
    'L_AIRPORT_ID.csv'                                            AS source_file,
    NOW()                                                         AS loaded_at
FROM bronze.airport_id_raw aid
INNER JOIN bronze.airport_iata_raw air
    ON aid.description = air.description
LEFT JOIN bronze.airports_raw a
    ON air.code = a.iata_code
WHERE a.iata_code IS NULL
AND aid.code::VARCHAR IN (
    SELECT DISTINCT origin_airport
    FROM bronze.flights_raw f
    LEFT JOIN bronze.airports_raw ar ON f.origin_airport = ar.iata_code
    WHERE ar.iata_code IS NULL
);
