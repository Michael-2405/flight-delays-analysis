# Data Catalog — Flight Delays Analysis

**Version:** 1.5
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

```text
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
│   REPORTS   │  Apache Superset (planned)
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
| `silver` | Cleaned data | ✅ Complete | `flight_clean`, `airline_clean`, `airport_clean` |
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
| `etl.airport_dot_iata_map` | 6,778 | DOT→IATA mapping — 302 automatic + 4 manual |

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
| `silver.flight_clean` | 5,819,079 | Add `full_date`, `date_id`, DOT→IATA translation via `etl.airport_dot_iata_map` |

---

## Gold Layer

| Table | Rows | Load Strategy | Notes |
|-------|------|---------------|-------|
| `gold.dim_date` | 1,096 | Idempotent INSERT | 2014-01-01 → 2016-12-31 |
| `gold.dim_airline` | 14 | UPSERT SCD1 | UNIQUE on `iata_code` |
| `gold.dim_airport` | 326 | UPSERT SCD1 | UNIQUE on `iata_code` |
| `gold.dim_cancellation_reason` | 4 | UPSERT seed | A=Carrier, B=Weather, C=NAS, D=Security |
| `gold.fct_flights` | 5,819,079 | Incremental + ON CONFLICT DO NOTHING | 0 NULL airport IDs |

### Gold Stored Procedures

| Procedure | Source | Strategy | Approx. Duration |
|-----------|--------|----------|-----------------|
| `usp_load_gold_dim_date` | `generate_series` | Idempotent INSERT | <1s |
| `usp_load_gold_dim_airline` | `silver.airline_clean` | UPSERT SCD1 | <1s |
| `usp_load_gold_dim_airport` | `silver.airport_clean` | UPSERT SCD1 | <1s |
| `usp_load_gold_dim_cancellation_reason` | Seed data | UPSERT | <1s |
| `usp_load_gold_fct_flights` | `silver.flight_clean` | Incremental INSERT | ~13 min |

### fct_flights Quality Metrics

| Metric | Value |
|--------|-------|
| Total rows | 5,819,079 |
| NULL origin_airport_id | 0 (0%) |
| NULL destination_airport_id | 0 (0%) |
| Duplicate protection | UNIQUE NULLS NOT DISTINCT on natural key |
| Indexes | 7 BTREE indexes on frequently filtered columns |

---

## Airport Enrichment Summary

| Stage | Codes | Flights |
|-------|-------|---------|
| Before enrichment | 306 unresolved DOT codes | 486,165 NULL airport IDs |
| Automatic resolution | 302 codes via description match | ~478,156 flights |
| Manual resolution | 4 codes (civil/military shared airports) | ~8,009 flights |
| After enrichment | 0 unresolved | 0 NULL airport IDs |

---

## Tests

| Suite | Tests | Coverage |
|-------|-------|----------|
| Unit (`tests/unit/`) | 22 | Pandera validators — airlines, airports, flights |
| Integration (`tests/integration/`) | 33 | Bronze/Silver/Gold counts, business rules, referential integrity |

---

## Glossary

| Term | Definition |
|------|------------|
| **DOT Code** | Numeric airport identifier used by the US Dept. of Transportation |
| **IATA Code** | 2-letter airline or 3-letter airport code assigned by the International Air Transport Association |
| **BTS** | Bureau of Transportation Statistics — source of the DOT→IATA lookup tables |
| **SCD Tipo 1** | Slowly Changing Dimension strategy — overwrite on change, no history kept |
| **UPSERT** | INSERT + UPDATE — insert if the record does not exist, update if it does |
| **ON CONFLICT DO NOTHING** | Skip an INSERT if it would violate a unique constraint |
| **NULLS NOT DISTINCT** | Treat two NULL values as equal for UNIQUE constraint purposes |
| **Medallion Architecture** | Bronze → Silver → Gold layered data architecture |
| **Star Schema** | One central fact table surrounded by dimension tables |
| **Role-Playing Dimension** | A single dimension used in multiple contexts (e.g. dim_airport as origin and destination) |
| **Surrogate Key** | System-generated integer ID that replaces the natural business key |
| **generate_series** | PostgreSQL set-returning function that generates a sequence of values |
| **COPY FROM STDIN** | PostgreSQL bulk load mechanism — 10–50x faster than row-by-row INSERT |
| **Idempotent** | Operation that produces the same result regardless of how many times it is executed |
