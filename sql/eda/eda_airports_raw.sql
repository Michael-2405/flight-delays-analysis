-- =============================================================
-- EDA — bronze.airports_raw
-- Author: Michael Espinosa
-- Date:   2026-06
-- =============================================================

-- ── 1. Row count ─────────────────────────────────────────────
SELECT COUNT(*) FROM bronze.airports_raw;

-- ── 2. Sample data ───────────────────────────────────────────
SELECT * FROM bronze.airports_raw LIMIT 10;

-- ── 3. Data types ────────────────────────────────────────────
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'bronze'
AND table_name = 'airports_raw'
ORDER BY ordinal_position;

-- ── 4. Nulls per column ──────────────────────────────────────
SELECT
    COUNT(*) FILTER (WHERE iata_code IS NULL)  AS iata_code_nulls,
    COUNT(*) FILTER (WHERE airport IS NULL)    AS airport_nulls,
    COUNT(*) FILTER (WHERE city IS NULL)       AS city_nulls,
    COUNT(*) FILTER (WHERE state IS NULL)      AS state_nulls,
    COUNT(*) FILTER (WHERE country IS NULL)    AS country_nulls,
    COUNT(*) FILTER (WHERE latitude IS NULL)   AS latitude_nulls,
    COUNT(*) FILTER (WHERE longitude IS NULL)  AS longitude_nulls
FROM bronze.airports_raw;

-- ── 5. Airports with missing coordinates ─────────────────────
SELECT iata_code, airport, city, state
FROM bronze.airports_raw
WHERE latitude IS NULL
   OR longitude IS NULL;

-- ── 6. Duplicates ────────────────────────────────────────────
SELECT
    iata_code,
    COUNT(*) AS occurrences
FROM bronze.airports_raw
GROUP BY iata_code
HAVING COUNT(*) > 1;

-- ── 7. Whitespace / trimming ─────────────────────────────────
SELECT *
FROM bronze.airports_raw
WHERE iata_code != TRIM(iata_code)
   OR airport  != TRIM(airport)
   OR city     != TRIM(city);

-- =============================================================
-- Findings:
-- - 322 rows (326 after airport enrichment in V27)
-- - No nulls in key columns
-- - 3 airports with NULL latitude/longitude: ECP, PBG, UST
--   Decision: keep NULLs in Silver — coordinates are optional
-- - No duplicates, no whitespace issues
-- - Ready for Silver with rename: airport → airport_name
-- =============================================================
