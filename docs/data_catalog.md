# Data Catalog — Flight Delays Analysis

**Version:** 1.1
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
│   SILVER    │  Cleaned data — typed, deduplicated, standardized
│ 🔄 Pending  │  Pending EDA results
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
│  ✅ Done    │  etl_log + start/success/error functions
└─────────────┘
```

---

## Schemas

| Schema | Purpose | Status | Tables |
|--------|---------|--------|--------|
| `bronze` | Raw ingestion — data as-is from source files | ✅ Complete | `flights_raw`, `airlines_raw`, `airports_raw` |
| `silver` | Cleaned and standardized data | 🔄 Pending EDA | `flights_clean`, `airlines_clean`, `airports_clean` |
| `gold` | Star schema — dimensional model for analysis | 🔄 Pending Silver | `dim_airline`, `dim_airport`, `dim_date`, `dim_cancellation_reason`, `fct_flights` |
| `etl` | Pipeline execution logs | ✅ Complete | `etl_log` |

---

## Bronze Layer — Current State

| Table | Rows Loaded | Load Strategy | Last Updated |
|-------|-------------|---------------|--------------|
| `bronze.airlines_raw` | 14 | Truncate + full load | 2026-06 |
| `bronze.airports_raw` | 322 | Truncate + full load | 2026-06 |
| `bronze.flights_raw` | 5,819,079 | Truncate + COPY (100k batches) | 2026-06 |

---

## Gold Layer — Star Schema (Designed, Pending Implementation)

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

### Fact Table

| Table | Description | Grain |
|-------|-------------|-------|
| `fct_flights` | One row per flight operated | One flight = one row |

### Dimension Tables

| Table | Description | Source | Rows |
|-------|-------------|--------|------|
| `dim_airline` | Airlines operating US domestic flights | `airlines_raw` | 14 |
| `dim_airport` | US airports — role-playing dimension | `airports_raw` | 322 |
| `dim_date` | Calendar dimension for 2015 | Generated | 365 |
| `dim_cancellation_reason` | Cancellation reason codes | Seed data | 4 |

---

## ETL Logging

| Object | Type | Description |
|--------|------|-------------|
| `etl.etl_log` | Table | Stores one record per pipeline execution |
| `etl.ufn_log_start_etl` | Function | Inserts execution start record, returns `etl_log_id` |
| `etl.usp_log_success_etl` | Procedure | Updates record with SUCCESS status and row counts |
| `etl.usp_log_error_etl` | Procedure | Updates record with FAILED status and error details |

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

## Pipeline Flow

```
1. Python reads CSV files from data/raw/ using Polars
2. Pandera validates CSV schema before any insert
3. Truncate bronze table
4. Load raw data into bronze schema
   - airlines + airports: SQLAlchemy executemany
   - flights: PostgreSQL COPY FROM STDIN (100k rows/batch)
5. ETL log records execution (pending connection to pipeline)
6. Silver transformations (pending EDA)
7. Gold dimensional model (pending Silver)
```

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
