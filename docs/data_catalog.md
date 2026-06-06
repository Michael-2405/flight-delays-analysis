# Data Catalog — Flight Delays Analysis

**Version:** 1.2
**Last Updated:** 2026-06
**Architecture:** Medallion (Bronze → Silver → Gold)
**Database:** PostgreSQL 16

---

## Project Overview

| Field | Detail |
|-------|--------|
| **Project Name** | Flight Delays Analysis |
| **Objective** | Analyze flight delays and cancellations across US domestic flights in 2015, and build reports to understand patterns by airline, airport, route, and time |
| **Source** | US Department of Transportation (DOT) via Kaggle |
| **Dataset** | 2015 Flight Delays and Cancellations |
| **Volume** | ~5.8 million flights |
| **Period** | January 2015 – December 2015 |

---

## Source Files

| File | Description | Rows | Format |
|------|-------------|------|--------|
| `flights.csv` | All domestic US flights in 2015 with departure/arrival times, delays, and cancellations | 5,819,079 | CSV |
| `airlines.csv` | IATA codes and names of US airlines | 14 | CSV |
| `airports.csv` | IATA codes, names, locations, and coordinates of US airports | 322 | CSV |

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
│ 🔄 Pending  │  Pending Silver completion
└─────────────┘
      │
      ▼
┌─────────────┐
│   REPORTS   │  Metabase / Power BI (planned)
└─────────────┘

┌─────────────┐
│     ETL     │  Pipeline execution logs
│  ✅ Done    │  Connected to all Silver SPs
└─────────────┘
```

---

## Schemas

| Schema | Purpose | Status | Tables |
|--------|---------|--------|--------|
| `bronze` | Raw ingestion — data as-is from source files | ✅ Complete | `flights_raw`, `airlines_raw`, `airports_raw` |
| `silver` | Cleaned and standardized data | ✅ Complete | `flights_clean`, `airlines_clean`, `airports_clean` |
| `gold` | Star schema — dimensional model for analysis | 🔄 Pending | `dim_airline`, `dim_airport`, `dim_date`, `dim_cancellation_reason`, `fct_flights` |
| `etl` | Pipeline execution logs | ✅ Complete | `etl_log` |

---

## Bronze Layer

| Table | Rows Loaded | Load Strategy | Notes |
|-------|-------------|---------------|-------|
| `bronze.airlines_raw` | 14 | Truncate + full load | Clean — no issues found in EDA |
| `bronze.airports_raw` | 322 | Truncate + full load | 3 airports with NULL lat/lon (ECP, PBG, UST) |
| `bronze.flights_raw` | 5,819,079 | Truncate + COPY (100k batches) | 486,165 flights with DOT numeric airport codes |

---

## Silver Layer

| Table | Rows | Source | Key Transformations |
|-------|------|--------|---------------------|
| `silver.airline_clean` | 14 | `bronze.airlines_raw` | Rename `airline` → `airline_name` |
| `silver.airport_clean` | 322 | `bronze.airports_raw` | Rename `airport` → `airport_name` |
| `silver.flight_clean` | 5,819,079 | `bronze.flights_raw` | Add `full_date DATE`, add `date_id INT (YYYYMMDD)` |

### Silver Stored Procedures

| Procedure | Description | Rows Written |
|-----------|-------------|--------------|
| `silver.usp_load_silver_airlines` | Truncate + load airlines | 14 |
| `silver.usp_load_silver_airports` | Truncate + load airports | 322 |
| `silver.usp_load_silver_flights` | Truncate + load flights with derived columns | 5,819,079 |

---

## Gold Layer — Star Schema (Pending)

```
                    dim_date
                       │
         dim_airline   │   dim_airport (origin)
                 │     │     │
                 ▼     ▼     ▼
              ┌─────────────────┐
              │   fct_flights   │
              └─────────────────┘
                 ▲         ▲
                 │         │
     dim_airport │         │ dim_cancellation_reason
    (destination)│
```

| Table | Description | Source | Rows (expected) |
|-------|-------------|--------|-----------------|
| `dim_airline` | Airlines operating US domestic flights | `silver.airline_clean` | 14 |
| `dim_airport` | US airports — role-playing dimension | `silver.airport_clean` | 322 |
| `dim_date` | Calendar dimension for 2015 | Generated | 365 |
| `dim_cancellation_reason` | Cancellation reason codes | Seed data | 4 |
| `fct_flights` | One row per flight — grain of the model | `silver.flight_clean` | ~5.8M |

---

## ETL Logging

| Object | Type | Description |
|--------|------|-------------|
| `etl.etl_log` | Table | One record per SP execution |
| `etl.ufn_log_start_etl` | Function | Inserts start record, returns `etl_log_id` |
| `etl.usp_log_success_etl` | Procedure | Updates record with SUCCESS and row counts |
| `etl.usp_log_error_etl` | Procedure | Updates record with FAILED and error details |

### Sample ETL Log Output

| log_id | etl_name | status | rows_written | rows_read |
|--------|----------|--------|--------------|-----------|
| 5 | usp_load_silver_flight | SUCCESS | 5,819,079 | 5,819,079 |
| 4 | usp_load_silver_airport | SUCCESS | 322 | 322 |
| 3 | usp_load_silver_airline | SUCCESS | 14 | 14 |

---

## EDA Findings Summary

Full findings in `docs/eda_findings.md` and queries in `sql/eda/`.

| Table | Status | Key Findings |
|-------|--------|-------------|
| `airlines_raw` | ✅ Clean | No nulls, no duplicates, no whitespace |
| `airports_raw` | ✅ Clean | 3 airports with NULL coordinates (ECP, PBG, UST) |
| `flights_raw` | ⚠️ Issues found | See below |

**flights_raw key findings:**
- Business rules validated — 0 violations on cancellation logic
- `departure_delay` nulls correlate with `cancelled = 1`
- Delay ranges valid: dep [-82, 1988] avg=9.37 / arr [-87, 1971]
- Natural key requires `destination_airport` (AA803 case)
- ⚠️ 486,165 flights (8.4%) use DOT numeric airport codes not in `airports_raw`

---

## Known Technical Debt

| Issue | Impact | Priority | Resolution |
|-------|--------|----------|------------|
| 306 DOT numeric airport codes not in `airports_raw` | 486,165 flights (8.4%) won't join to `dim_airport` | Medium | Enrich from BTS: https://www.transtats.bts.gov |
| `etl_finish` same as `etl_start` | Execution time not tracked accurately | Low | Use `clock_timestamp()` in `usp_log_success_etl` |
| No unit or integration tests | Pipeline correctness not automated | Medium | Add pytest tests for validators and pipelines |

---

## Key Business Questions This Project Answers

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
| **Delay** | Difference in minutes between scheduled and actual time. Negative = early. |
| **Cancellation** | Flight that was scheduled but never operated |
| **Diversion** | Flight that landed at a different airport than scheduled destination |
| **IATA Code** | 2-letter airline code or 3-letter airport code |
| **Tail Number** | Unique registration number of a specific aircraft |
| **Wheels Off / On** | Actual time the aircraft left / touched the ground |
| **Taxi Out / In** | Time between gate departure and wheels off / wheels on and gate arrival |
| **Medallion Architecture** | Bronze → Silver → Gold layered data architecture |
| **Star Schema** | Dimensional model with one fact table surrounded by dimension tables |
| **Role-Playing Dimension** | A single dimension used in multiple contexts (origin and destination airport) |
| **Surrogate Key** | System-generated integer ID replacing the natural business key |
| **COPY FROM STDIN** | PostgreSQL bulk load command — 10-50x faster than INSERT for large datasets |
| **Truncate + Full Load** | Load strategy that deletes all rows before reloading from source |
| **date_id** | Integer representation of a date in YYYYMMDD format (e.g. 20150115) |
| **GET DIAGNOSTICS** | PostgreSQL command to capture row count after DML operations |
