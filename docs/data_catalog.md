# Data Catalog — Flight Delays Analysis

**Version:** 1.4
**Last Updated:** 2026-06
**Architecture:** Medallion (Bronze → Silver → Gold)
**Database:** PostgreSQL 16

---

## Project Overview

| Field | Detail |
|-------|--------|
| **Project Name** | Flight Delays Analysis |
| **Objective** | Analyze flight delays and cancellations across US domestic flights in 2015 |
| **Source** | US Department of Transportation (DOT) via Kaggle + BTS lookup tables |
| **Volume** | ~5.8 million flights |
| **Period** | January 2015 – December 2015 |

---

## Architecture

```
Source Files (CSV + BTS)
      │
      ▼
┌─────────────┐
│   BRONZE    │  Raw data — 5 tables including BTS lookup tables
│  ✅ Done    │
└─────────────┘
      │
      ▼
┌─────────────┐
│   SILVER    │  Cleaned — DOT→IATA translation applied
│  ✅ Done    │
└─────────────┘
      │
      ▼
┌─────────────┐
│    GOLD     │  Star schema — 0 NULL airport IDs
│  ✅ Done    │  UNIQUE constraint on fct_flights
└─────────────┘
      │
      ▼
┌─────────────┐
│   REPORTS   │  Metabase (planned)
│  ⏳ Planned │
└─────────────┘

┌─────────────┐
│     ETL     │  Logs + DOT→IATA mapping
│  ✅ Done    │
└─────────────┘
```

---

## Schemas

| Schema | Purpose | Status | Tables |
|--------|---------|--------|--------|
| `bronze` | Raw ingestion | ✅ Complete | `flights_raw`, `airlines_raw`, `airports_raw`, `airport_id_raw`, `airport_iata_raw` |
| `silver` | Cleaned data | ✅ Complete | `flights_clean`, `airlines_clean`, `airports_clean` |
| `gold` | Star schema | ✅ Complete | `dim_airline`, `dim_airport`, `dim_date`, `dim_cancellation_reason`, `fct_flights` |
| `etl` | Infrastructure | ✅ Complete | `etl_log`, `airport_dot_iata_map` |

---

## Bronze Layer

| Table | Rows | Source | Notes |
|-------|------|--------|-------|
| `bronze.airlines_raw` | 14 | airlines.csv | Clean |
| `bronze.airports_raw` | 326 | airports.csv + V27 | 322 original + 4 enriched |
| `bronze.flights_raw` | 5,819,079 | flights.csv | DOT codes translated in Silver |
| `bronze.airport_id_raw` | 6,884 | L_AIRPORT_ID.csv | BTS DOT numeric codes |
| `bronze.airport_iata_raw` | 6,910 | L_AIRPORT.csv | BTS IATA codes |

---

## ETL Reference Tables

| Table | Rows | Description |
|-------|------|-------------|
| `etl.airport_dot_iata_map` | 6,778 | DOT→IATA mapping. 302 automatic + 4 manual |

### Manual Mappings (civil/military shared airports)

| dot_code | iata_code | Airport |
|----------|-----------|---------|
| 10170 | ADQ | Kodiak, AK |
| 10423 | AUS | Austin, TX — Bergstrom International |
| 12173 | HNL | Honolulu, HI — Daniel K Inouye International |
| 16218 | YUM | Yuma, AZ — MCAS/Yuma International |

---

## Silver Layer

| Table | Rows | Key Transformations |
|-------|------|---------------------|
| `silver.airline_clean` | 14 | Rename `airline` → `airline_name` |
| `silver.airport_clean` | 326 | Rename `airport` → `airport_name` |
| `silver.flight_clean` | 5,819,079 | Add `full_date`, `date_id`, DOT→IATA translation |

---

## Gold Layer

| Table | Rows | Load Strategy | Notes |
|-------|------|---------------|-------|
| `gold.dim_date` | 1,096 | Idempotent INSERT | 2014-01-01 → 2016-12-31 |
| `gold.dim_airline` | 14 | UPSERT SCD1 | |
| `gold.dim_airport` | 326 | UPSERT SCD1 | Includes enriched airports |
| `gold.dim_cancellation_reason` | 4 | UPSERT seed | A, B, C, D |
| `gold.fct_flights` | 5,819,079 | Incremental + ON CONFLICT | 0 NULL airport IDs |

### fct_flights Quality Metrics

| Metric | Value |
|--------|-------|
| Total rows | 5,819,079 |
| NULL origin_airport_id | 0 (0%) |
| NULL destination_airport_id | 0 (0%) |
| Duplicate protection | UNIQUE constraint on natural key |

---

## Airport Enrichment Summary

| Stage | Codes | Flights |
|-------|-------|---------|
| Before enrichment | 306 unresolved DOT codes | 486,165 NULL airport IDs |
| Automatic resolution | 302 codes (description match) | ~482,000 flights |
| Manual resolution | 4 codes (civil/military) | ~8,009 flights |
| After enrichment | 0 unresolved | 0 NULL airport IDs |

---

## Known Technical Debt

| Issue | Impact | Priority |
|-------|--------|----------|
| No indexes on `fct_flights` | Slow queries on 5.8M rows | High |
| No unit or integration tests | Pipeline correctness not automated | Medium |
| `etl_finish` uses NOW() instead of clock_timestamp() | Execution time not accurate | Low |

---

## Glossary

| Term | Definition |
|------|------------|
| **DOT Code** | Numeric airport identifier used by the US Dept. of Transportation |
| **IATA Code** | 2-letter airline or 3-letter airport code |
| **BTS** | Bureau of Transportation Statistics — source of DOT→IATA mapping |
| **SCD Tipo 1** | Slowly Changing Dimension — overwrite on change, no history |
| **UPSERT** | INSERT + UPDATE — insert if not exists, update if exists |
| **ON CONFLICT DO NOTHING** | Skip INSERT if unique constraint would be violated |
| **NULLS NOT DISTINCT** | Treat NULL as equal for UNIQUE constraint purposes |
| **Medallion Architecture** | Bronze → Silver → Gold layered data architecture |
| **Star Schema** | One fact table surrounded by dimension tables |
| **Surrogate Key** | System-generated integer ID replacing the natural business key |
| **generate_series** | PostgreSQL function that generates a sequence of values |
| **COPY FROM STDIN** | PostgreSQL bulk load — 10-50x faster than INSERT |
