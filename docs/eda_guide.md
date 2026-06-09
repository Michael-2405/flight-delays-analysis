# EDA Guide — Exploratory Data Analysis

**Version:** 1.0
**Author:** Michael Espinosa
**Scope:** General-purpose EDA process for data engineering and analytics projects

---

## What is EDA?

Exploratory Data Analysis is the process of understanding a dataset before transforming or modeling it. The goal is not to answer business questions — that comes later. The goal is to understand the shape, quality, and limitations of the data so that transformation decisions are informed and documented.

---

## When to Do EDA

- After loading raw data into Bronze
- Before designing Silver transformations
- When receiving a new data source
- When data quality issues are suspected

---

## EDA Checklist

### 1. Row Count

```sql
SELECT COUNT(*) FROM schema.table;
```

**Ask:** Does the count match the expected number from the source? Is the table empty? Is it larger than expected?

---

### 2. Sample Data

```sql
SELECT * FROM schema.table LIMIT 10;
```

**Ask:** Does the data look right? Are there obvious encoding issues, garbage values, or unexpected formats?

---

### 3. Schema and Data Types

```sql
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_schema = 'schema_name'
AND table_name = 'table_name'
ORDER BY ordinal_position;
```

**Ask:** Are the types correct? Were numbers loaded as strings? Are dates stored as text?

---

### 4. Null Analysis

```sql
SELECT
    COUNT(*) FILTER (WHERE column_1 IS NULL) AS column_1_nulls,
    COUNT(*) FILTER (WHERE column_2 IS NULL) AS column_2_nulls
    -- repeat for all columns
FROM schema.table;
```

**Ask:** Which columns have nulls? Is that expected? Are nulls in key columns acceptable?

Classify each nullable column:
- **Expected null** — e.g. cancellation_reason is null when flight is not cancelled
- **Unexpected null** — signals a data quality issue
- **Acceptable null** — e.g. optional coordinates

---

### 5. Duplicate Analysis

```sql
SELECT <natural_key_columns>, COUNT(*) AS occurrences
FROM schema.table
GROUP BY <natural_key_columns>
HAVING COUNT(*) > 1
LIMIT 10;
```

**Ask:** Are there true duplicates or just records that share a partial key? What is the natural key for this table?

---

### 6. Value Distribution

```sql
SELECT column_name, COUNT(*) AS occurrences
FROM schema.table
GROUP BY column_name
ORDER BY occurrences DESC;
```

**Ask:** Are there unexpected values? Are there values that should be in a lookup table? Are there typos or inconsistent casing?

---

### 7. Range and Outlier Analysis

For numeric and date columns:

```sql
SELECT
    MIN(column_name)  AS min_value,
    MAX(column_name)  AS max_value,
    AVG(column_name)  AS avg_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY column_name) AS median
FROM schema.table;
```

**Ask:** Are the min/max values plausible? Are there extreme outliers? Do negative values make sense?

---

### 8. Business Rule Validation

Define and validate the rules that must hold for the data to be correct:

```sql
-- Example: a cancelled flight must have a cancellation reason
SELECT COUNT(*)
FROM schema.table
WHERE is_cancelled = 1
AND cancellation_reason IS NULL;
-- Expected: 0
```

**Ask:** Which business rules apply to this dataset? Are any rules violated? What is the business impact of violations?

---

### 9. Referential Integrity

When the table references another table via a code or key:

```sql
SELECT DISTINCT f.foreign_key
FROM schema.fact_table f
LEFT JOIN schema.lookup_table l ON f.foreign_key = l.primary_key
WHERE l.primary_key IS NULL;
```

**Ask:** Are there orphaned records? Are all foreign keys resolvable? What percentage of records are affected?

---

### 10. Whitespace and Encoding

```sql
SELECT *
FROM schema.table
WHERE column_name != TRIM(column_name);
```

**Ask:** Are there leading/trailing spaces? Are there non-printable characters? Does the file encoding match what was expected?

---

### 11. Date Range Validation

```sql
SELECT MIN(date_column), MAX(date_column)
FROM schema.table;

-- Or by period
SELECT EXTRACT(YEAR FROM date_column) AS year,
       EXTRACT(MONTH FROM date_column) AS month,
       COUNT(*) AS rows
FROM schema.table
GROUP BY year, month
ORDER BY year, month;
```

**Ask:** Does the date range match the expected period? Are there records outside the expected window? Are all expected months/years present?

---

## Documenting Findings

For each check, document:

1. **Result** — what the data showed
2. **Decision** — what to do about it (keep, clean, reject, flag)
3. **Rationale** — why that decision was made

Use a findings document (`eda_findings.md`) to record decisions that affect downstream transformations. Findings become the audit trail for design decisions in Silver and Gold.

---

## Common Findings and Responses

| Finding | Typical Response |
|---------|-----------------|
| NULLs in optional columns | Keep — mark as nullable in Silver |
| NULLs in required columns | Investigate source — may need to filter or reject |
| True duplicates | Deduplicate in Silver — document natural key |
| Foreign key mismatches | Enrich lookup table or translate codes |
| Unexpected value types | Cast in Silver — document in data dictionary |
| Business rule violations | Raise with data owner — do not silently ignore |
| Outliers | Validate against source — keep unless confirmed bad |
| Encoding issues | Fix at read time — specify correct encoding in pipeline |
| Date range gaps | Investigate source — document in findings |

---

## EDA SQL File Convention

Each EDA file should follow this structure:

```sql
-- =============================================================
-- EDA — schema.table_name
-- Author: <name>
-- Date:   YYYY-MM
-- =============================================================

-- ── 1. Row count ─────────────────────────────────────────────
-- ── 2. Sample data ───────────────────────────────────────────
-- ── 3. Data types ────────────────────────────────────────────
-- ── 4. Nulls per column ──────────────────────────────────────
-- ── 5. Duplicates ────────────────────────────────────────────
-- ── 6. Value distribution (key columns) ──────────────────────
-- ── 7. Range analysis (numeric/date columns) ─────────────────
-- ── 8. Business rule validation ──────────────────────────────
-- ── 9. Referential integrity ─────────────────────────────────
-- ── 10. Whitespace / encoding ────────────────────────────────

-- =============================================================
-- Findings:
-- - <summary of key findings>
-- - <decisions made>
-- =============================================================
```

Not every section applies to every table — skip sections that are not relevant and document why.

---

## Output of EDA

EDA should produce:

1. **Findings document** — decisions and rationale per table
2. **Updated data dictionary** — nullable columns, constraints, business rules
3. **Transformation requirements** — what Silver needs to fix or derive
4. **Technical debt log** — issues identified but deferred
