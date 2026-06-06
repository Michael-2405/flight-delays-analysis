-- ============================================================
-- EDA — bronze.flights_raw
-- Author: Michael Espinosa
-- Date: 2026-06
-- ============================================================

-- ── 1. Row count ─────────────────────────────────────────────
SELECT COUNT(*) FROM bronze.flights_raw;

-- ── 2. Sample data ───────────────────────────────────────────
SELECT * FROM bronze.flights_raw LIMIT 5;

-- ── 3. Data types ────────────────────────────────────────────
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'bronze'
AND table_name = 'flights_raw'
ORDER BY ordinal_position;

-- ── 4. Nulls per column ──────────────────────────────────────
SELECT
    COUNT(*) FILTER (WHERE year IS NULL)                AS year_nulls,
    COUNT(*) FILTER (WHERE month IS NULL)               AS month_nulls,
    COUNT(*) FILTER (WHERE day IS NULL)                 AS day_nulls,
    COUNT(*) FILTER (WHERE airline IS NULL)             AS airline_nulls,
    COUNT(*) FILTER (WHERE flight_number IS NULL)       AS flight_number_nulls,
    COUNT(*) FILTER (WHERE tail_number IS NULL)         AS tail_number_nulls,
    COUNT(*) FILTER (WHERE origin_airport IS NULL)      AS origin_airport_nulls,
    COUNT(*) FILTER (WHERE destination_airport IS NULL) AS destination_airport_nulls,
    COUNT(*) FILTER (WHERE departure_delay IS NULL)     AS departure_delay_nulls,
    COUNT(*) FILTER (WHERE arrival_delay IS NULL)       AS arrival_delay_nulls,
    COUNT(*) FILTER (WHERE cancelled IS NULL)           AS cancelled_nulls,
    COUNT(*) FILTER (WHERE diverted IS NULL)            AS diverted_nulls,
    COUNT(*) FILTER (WHERE cancellation_reason IS NULL) AS cancellation_reason_nulls,
    COUNT(*) FILTER (WHERE air_system_delay IS NULL)    AS air_system_delay_nulls,
    COUNT(*) FILTER (WHERE weather_delay IS NULL)       AS weather_delay_nulls,
    COUNT(*) FILTER (WHERE distance IS NULL)            AS distance_nulls,
    COUNT(*) FILTER (WHERE air_time IS NULL)            AS air_time_nulls
FROM bronze.flights_raw;

-- ── 5. Nulls in delay columns vs cancelled flights ────────────
-- departure_delay nulls should correlate with cancelled = 1
SELECT
    cancelled,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE departure_delay IS NULL) AS departure_delay_nulls
FROM bronze.flights_raw
GROUP BY cancelled;

-- ── 6. Business rule validation ──────────────────────────────
-- Rule 1: cancelled = 1 must have cancellation_reason
SELECT COUNT(*)
FROM bronze.flights_raw
WHERE cancelled = 1
AND cancellation_reason IS NULL;
-- Expected: 0

-- Rule 2: cancelled = 0 must NOT have cancellation_reason
SELECT COUNT(*)
FROM bronze.flights_raw
WHERE cancelled = 0
AND cancellation_reason IS NOT NULL;
-- Expected: 0

-- ── 7. Duplicates ────────────────────────────────────────────
-- Natural key: year + month + day + airline + flight_number
--              + origin_airport + destination_airport
SELECT
    year, month, day, airline, flight_number,
    origin_airport, destination_airport,
    COUNT(*) AS occurrences
FROM bronze.flights_raw
GROUP BY year, month, day, airline, flight_number,
         origin_airport, destination_airport
HAVING COUNT(*) > 1
LIMIT 10;

-- Investigate the AA803 case (same flight number, different destinations)
SELECT *
FROM bronze.flights_raw
WHERE year = 2015
AND month = 8
AND day = 29
AND airline = 'AA'
AND flight_number = 803
AND origin_airport = 'STT';

-- ── 8. Date range validation ─────────────────────────────────
-- Should only have 2015 data, all 12 months
SELECT
    year, month,
    COUNT(*) AS flights
FROM bronze.flights_raw
GROUP BY year, month
ORDER BY year, month;

-- ── 9. Delay range analysis ──────────────────────────────────
SELECT
    MIN(departure_delay) AS min_dep_delay,
    MAX(departure_delay) AS max_dep_delay,
    AVG(departure_delay) AS avg_dep_delay,
    MIN(arrival_delay)   AS min_arr_delay,
    MAX(arrival_delay)   AS max_arr_delay,
    AVG(arrival_delay)   AS avg_arr_delay
FROM bronze.flights_raw;

-- ── 10. Referential integrity — airlines ─────────────────────
-- Are there airline codes in flights not in airlines_raw?
SELECT DISTINCT f.airline
FROM bronze.flights_raw f
LEFT JOIN bronze.airlines_raw a ON f.airline = a.iata_code
WHERE a.iata_code IS NULL;

-- ── 11. Referential integrity — airports ─────────────────────
-- Are there airport codes in flights not in airports_raw?
SELECT DISTINCT f.origin_airport
FROM bronze.flights_raw f
LEFT JOIN bronze.airports_raw a ON f.origin_airport = a.iata_code
WHERE a.iata_code IS NULL;

-- How many flights are affected?
SELECT COUNT(*)
FROM bronze.flights_raw f
LEFT JOIN bronze.airports_raw a ON f.origin_airport = a.iata_code
WHERE a.iata_code IS NULL;

-- Same for destination?
SELECT COUNT(*)
FROM bronze.flights_raw f
LEFT JOIN bronze.airports_raw a ON f.destination_airport = a.iata_code
WHERE a.iata_code IS NULL;

-- Are origin and destination affected simultaneously?
SELECT COUNT(*)
FROM bronze.flights_raw f
LEFT JOIN bronze.airports_raw a_orig ON f.origin_airport = a_orig.iata_code
LEFT JOIN bronze.airports_raw a_dest ON f.destination_airport = a_dest.iata_code
WHERE a_orig.iata_code IS NULL
AND a_dest.iata_code IS NULL;

-- Which airlines have flights with unknown airports?
SELECT
    f.airline,
    COUNT(*) AS affected_flights
FROM bronze.flights_raw f
LEFT JOIN bronze.airports_raw a ON f.origin_airport = a.iata_code
WHERE a.iata_code IS NULL
GROUP BY f.airline
ORDER BY affected_flights DESC;

-- How many unique numeric airport codes?
SELECT COUNT(DISTINCT f.origin_airport)
FROM bronze.flights_raw f
LEFT JOIN bronze.airports_raw a ON f.origin_airport = a.iata_code
WHERE a.iata_code IS NULL;

-- ============================================================
-- Findings:
-- - 5,819,079 rows, all from 2015 (all 12 months)
-- - tail_number: 14,721 nulls — acceptable, no dim_aircraft
-- - departure_delay: 86,153 nulls — correlate with cancelled=1
-- - arrival_delay: 105,071 nulls — correlate with cancelled=1
-- - cancellation_reason: 5,729,195 nulls — expected (not cancelled)
-- - delay breakdown columns: 4,755,640 nulls — no delay recorded
-- - Business rules: 0 violations on both cancellation rules
-- - No true duplicates (AA803 case = same number, diff destinations)
-- - Natural key must include destination_airport
-- - Delay ranges valid: dep [-82, 1988] avg=9.37 / arr [-87, 1971]
--
-- ⚠️ Technical Debt — Airport Code Mismatch:
-- - 486,165 flights (8.4%) use DOT numeric codes not in airports_raw
-- - 306 unique numeric airport codes
-- - All major airlines affected
-- - Decision: proceed with Silver using known 322 airports
-- - Future: enrich airports_raw with DOT→IATA mapping from BTS
--   Source: https://www.transtats.bts.gov
-- ============================================================
