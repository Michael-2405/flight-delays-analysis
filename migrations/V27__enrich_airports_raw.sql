-- Script Name: V27__enrich_airports_raw.sql
-- Description: Enriches bronze.airports_raw with 306 missing airports
--              identified during EDA. Crosses L_AIRPORT_ID.csv (DOT numeric
--              codes) with L_AIRPORT.csv (IATA codes) by description to
--              resolve DOT→IATA mapping. Inserts only airports not already
--              present in airports_raw.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version


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
