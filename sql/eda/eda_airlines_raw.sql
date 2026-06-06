-- ============================================================
-- EDA — bronze.airlines_raw
-- Author: Michael Espinosa
-- Date: 2026-06
-- ============================================================

-- ── 1. Row count ─────────────────────────────────────────────
SELECT COUNT(*) FROM bronze.airlines_raw;

-- ── 2. Sample data ───────────────────────────────────────────
SELECT * FROM bronze.airlines_raw LIMIT 10;

-- ── 3. Data types ────────────────────────────────────────────
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'bronze'
AND table_name = 'airlines_raw'
ORDER BY ordinal_position;

-- ── 4. Nulls per column ──────────────────────────────────────
SELECT
    COUNT(*) FILTER (WHERE iata_code IS NULL) AS iata_code_nulls,
    COUNT(*) FILTER (WHERE airline IS NULL)   AS airline_nulls
FROM bronze.airlines_raw;

-- ── 5. Duplicates ────────────────────────────────────────────
SELECT
    iata_code,
    COUNT(*) AS occurrences
FROM bronze.airlines_raw
GROUP BY iata_code
HAVING COUNT(*) > 1;

-- ── 6. Whitespace / trimming ─────────────────────────────────
SELECT *
FROM bronze.airlines_raw
WHERE iata_code != TRIM(iata_code)
   OR airline != TRIM(airline);

-- ============================================================
-- Findings:
-- - 14 rows as expected
-- - No nulls, no duplicates, no whitespace issues
-- - Ready for Silver with rename: airline → airline_name
-- ============================================================
