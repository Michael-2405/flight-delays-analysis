# Data Catalog — Flight Delays Analysis

**Version:** 1.3
**Last Updated:** 2026-06
**Architecture:** Medallion (Bronze → Silver → Gold)
**Database:** PostgreSQL 16

---

## Project Overview

| Field | Detail |
|-------|--------|
| **Project Name** | Flight Delays Analysis |
| **Objective** | Analyze flight delays and cancellations across US domestic flights in 2015 |
| **Source** | US Department of Transportation (DOT) via Kaggle |
| **Dataset** | 2015 Flight Delays and Cancellations |
| **Volume** | ~5.8 million flights |
| **Period** | January 2015 – December 2015 |

---

## Architecture

```
Source Files (CSV)
      │
      ▼
┌─────────────┐
│   BRONZE    │  Raw data — loaded via Python (Polars + COPY)
│  ✅ Done    │  Truncate + full load, no transformations
└─────────────┘
      │
      ▼
┌─────────────┐
│   SILVER    │  Cleaned data — standardized, derived columns added
│  ✅ Done    │  Truncate + full load, ETL logging connected
└─────────────┘
      │
      ▼
┌─────────────┐
│    GOLD     │  Star schema — dimensions and fact table
│  ✅ Done    │  SCD1 for dims, incremental for fact
└─────────────┘
      │
      ▼
┌─────────────┐
│   REPORTS   │  Metabase / Power BI
│  ⏳ Planned │
└─────────────┘

┌─────────────┐
│     ETL     │  Pipeline execution logs
│  ✅ Done    │  Connected to all Silver and Gold SPs
└─────────────┘
```

---

## Schemas

| Schema | Purpose | Status | Tables |
|--------|---------|--------|--------|
| `bronze` | Raw ingestion | ✅ Complete | `flights_raw`, `airlines_raw`, `airports_raw` |
| `silver` | Cleaned data | ✅ Complete | `flights_clean`, `airlines_clean`, `airports_clean` |
| `gold` | Star schema | ✅ Complete | `dim_airline`, `dim_airport`, `dim_date`, `dim_cancellation_reason`, `fct_flights` |
| `etl` | Execution logs | ✅ Complete | `etl_log` |

---

## Bronze Layer

| Table | Rows | Load Strategy | Notes |
|-------|------|---------------|-------|
| `bronze.airlines_raw` | 14 | Truncate + full load | Clean |
| `bronze.airports_raw` | 322 | Truncate + full load | 3 airports with NULL lat/lon |
| `bronze.flights_raw` | 5,819,079 | Truncate + COPY (100k batches) | 486,165 flights with DOT numeric codes |

---

## Silver Layer

| Table | Rows | Key Transformations |
|-------|------|---------------------|
| `silver.airline_clean` | 14 | Rename `airline` → `airline_name` |
| `silver.airport_clean` | 322 | Rename `airport` → `airport_name` |
| `silver.flight_clean` | 5,819,079 | Add `full_date DATE`, add `date_id INT (YYYYMMDD)` |

---

## Gold Layer — Star Schema

| Table | Rows | Load Strategy | Notes |
|-------|------|---------------|-------|
| `gold.dim_date` | 1,096 | Idempotent INSERT | Pre-populated 2014-01-01 → 2016-12-31 |
| `gold.dim_airline` | 14 | UPSERT (SCD1) | UNIQUE on `iata_code` |
| `gold.dim_airport` | 322 | UPSERT (SCD1) | UNIQUE on `iata_code` |
| `gold.dim_cancellation_reason` | 4 | UPSERT seed data | Static — A, B, C, D |
| `gold.fct_flights` | 5,819,079 | Incremental INSERT | 486,165 with NULL airport IDs |

### Gold Stored Procedures

| Procedure | Source | Strategy | Duration |
|-----------|--------|----------|----------|
| `usp_load_gold_dim_date` | generate_series | Idempotent INSERT | <1s |
| `usp_load_gold_airline` | `silver.airline_clean` | UPSERT | <1s |
| `usp_load_gold_airport` | `silver.airport_clean` | UPSERT | <1s |
| `usp_load_gold_cancellation_reason` | Seed data | UPSERT | <1s |
| `usp_load_gold_fct_flights` | `silver.flight_clean` | Incremental INSERT | ~10 min |

### Execution Order

```sql
-- Dimensions first (no dependencies)
CALL gold.usp_load_gold_dim_date();
CALL gold.usp_load_gold_airline();
CALL gold.usp_load_gold_airport();
CALL gold.usp_load_gold_cancellation_reason();

-- Fact last (depends on all dimensions)
CALL gold.usp_load_gold_fct_flights();
```

---

## ETL Logging — Sample Output

| log_id | etl_name | status | rows_written | duration |
|--------|----------|--------|--------------|----------|
| 29 | usp_load_gold_fct_flights | SUCCESS | 5,819,079 | ~10 min |
| 27 | usp_load_gold_cancellation_reason | SUCCESS | 4 | <1s |
| 26 | usp_load_gold_airport | SUCCESS | 322 | <1s |
| 25 | usp_load_gold_airline | SUCCESS | 14 | <1s |
| 24 | usp_load_gold_dim_date | SUCCESS | 1,096 | <1s |

---

## Known Technical Debt

| Issue | Impact | Priority | Resolution |
|-------|--------|----------|------------|
| 306 DOT numeric airport codes not in `dim_airport` | 486,165 flights with NULL airport IDs (8.4%) | Medium | Enrich from BTS: https://www.transtats.bts.gov |
| No UNIQUE constraint on `fct_flights` | Duplicate flights possible on re-run | Medium | Add after airport enrichment |
| `etl_finish` uses NOW() instead of clock_timestamp() | Execution time not accurate | Low | Fix in usp_log_success_etl |
| No unit or integration tests | Pipeline correctness not automated | Medium | Add pytest tests |

---

## Key Business Questions

1. Which airlines have the highest average departure delay?
2. Which airports have the most cancellations?
3. What are the most common causes of cancellations?
4. Which routes have the worst on-time performance?
5. Are delays worse on weekends, holidays, or specific months?
6. How does weather delay compare to airline delay across carriers?
7. What is the cancellation rate by airline and month?

---

## Glossary

| Term | Definition |
|------|------------|
| **Delay** | Difference in minutes between scheduled and actual time. Negative = early |
| **Cancellation** | Flight that was scheduled but never operated |
| **Diversion** | Flight that landed at a different airport than scheduled |
| **IATA Code** | 2-letter airline or 3-letter airport code |
| **DOT Code** | Numeric airport identifier used by the US Dept. of Transportation |
| **Tail Number** | Unique registration number of a specific aircraft |
| **Medallion Architecture** | Bronze → Silver → Gold layered data architecture |
| **Star Schema** | One fact table surrounded by dimension tables |
| **Role-Playing Dimension** | Single dimension used in multiple contexts (origin/destination airport) |
| **Surrogate Key** | System-generated integer ID replacing the natural business key |
| **SCD Tipo 1** | Slowly Changing Dimension strategy — overwrite on change, no history |
| **UPSERT** | INSERT + UPDATE — insert if not exists, update if exists |
| **COPY FROM STDIN** | PostgreSQL bulk load — 10-50x faster than INSERT |
| **date_id** | Integer date in YYYYMMDD format (e.g. 20150115) |
| **GET DIAGNOSTICS** | PostgreSQL command to capture row count after DML |
| **generate_series** | PostgreSQL function that generates a sequence of values |
