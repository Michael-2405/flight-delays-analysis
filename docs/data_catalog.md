# Data Catalog — Flight Delays Analysis

**Version:** 1.0
**Last Updated:** 2026-05
**Architecture:** Medallion (Bronze → Silver → Gold)
**Database:** PostgreSQL

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

| File | Description | Rows (approx) | Format |
|------|-------------|---------------|--------|
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
│   BRONZE    │  Raw data — exactly as received from source
│             │  No transformations applied
└─────────────┘
      │
      ▼
┌─────────────┐
│   SILVER    │  Cleaned data — typed, deduplicated, standardized
│             │  Nulls handled, formats normalized
└─────────────┘
      │
      ▼
┌─────────────┐
│    GOLD     │  Star schema — dimensions and fact table
│             │  Ready for analysis and reporting
└─────────────┘
      │
      ▼
┌─────────────┐
│   REPORTS   │  Metabase / Superset / Power BI
└─────────────┘

┌─────────────┐
│     ETL     │  Pipeline execution logs and error tracking
└─────────────┘
```

---

## Schemas

| Schema | Purpose | Tables |
|--------|---------|--------|
| `bronze` | Raw ingestion — data as-is from source files | `flights_raw`, `airlines_raw`, `airports_raw` |
| `silver` | Cleaned and standardized data | `flights_clean`, `airlines_clean`, `airports_clean` |
| `gold` | Star schema — dimensional model for analysis | `dim_airline`, `dim_airport`, `dim_date`, `dim_cancellation_reason`, `fct_flights` |
| `etl` | Pipeline execution logs | `etl_log`, `etl_error` |

---

## Gold Layer — Star Schema

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

| Table | Description | Source | Rows (approx) |
|-------|-------------|--------|---------------|
| `dim_airline` | Airlines operating US domestic flights | `airlines.csv` | 14 |
| `dim_airport` | US airports — used for both origin and destination (role-playing) | `airports.csv` | 322 |
| `dim_date` | Calendar dimension — one row per day in 2015 | Generated | 365 |
| `dim_cancellation_reason` | Cancellation reason codes and descriptions | Seed data | 4 |

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
1. Python reads CSV files from data/raw/
2. Loads raw data into bronze schema (no transformations)
3. Stored procedure usp_load_silver_* cleans and loads silver
4. Stored procedure usp_load_gold_* builds dimensions and fact
5. ETL log records each execution with status and row counts
```

---

## Glossary

| Term | Definition |
|------|------------|
| **Delay** | Difference in minutes between scheduled and actual time. Negative = early. |
| **Cancellation** | Flight that was scheduled but never operated |
| **Diversion** | Flight that landed at a different airport than scheduled destination |
| **IATA Code** | 2-letter airline code or 3-letter airport code assigned by the International Air Transport Association |
| **Tail Number** | Unique registration number of a specific aircraft |
| **Wheels Off / On** | Actual time the aircraft left / touched the ground |
| **Taxi Out / In** | Time between gate departure and wheels off / wheels on and gate arrival |
| **Medallion Architecture** | Bronze → Silver → Gold layered data architecture |
| **Star Schema** | Dimensional model with one fact table surrounded by dimension tables |
| **Role-Playing Dimension** | A single dimension table used in multiple contexts (e.g. dim_airport used as both origin and destination) |
| **Surrogate Key** | System-generated integer ID that replaces the natural business key |
