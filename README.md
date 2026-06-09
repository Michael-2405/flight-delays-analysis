# ✈️ Flight Delays Analysis

End-to-end data engineering project analyzing US domestic flight delays and cancellations in 2015.

Built on a Medallion architecture (Bronze → Silver → Gold) using PostgreSQL, Python, and SQL — with database as code, versioned migrations, and CI/CD from the first commit.

---

## Objective

Analyze ~5.8 million flights to answer questions like:

- Which airlines have the highest average delay?
- Which airports have the most cancellations?
- What causes most cancellations — weather, carrier, or NAS?
- Are delays worse on weekends, holidays, or specific months?
- Which routes have the worst on-time performance?

---

## Architecture

```
CSV Files (DOT / Kaggle) + BTS Lookup Tables
        │
        ▼
  bronze schema       ← raw data, loaded via Python + COPY
        │
        ▼
  silver schema       ← cleaned, standardized, DOT→IATA translation
        │
        ▼
  gold schema         ← star schema, ready for reporting
        │
        ▼
  Metabase            ← dashboards and reports (planned)
```

---

## Current Status

| Layer | Status | Details |
|-------|--------|---------|
| Bronze | ✅ Complete | 5 tables — includes BTS airport lookup tables |
| ETL Logging | ✅ Complete | Connected to all Silver and Gold SPs |
| Silver | ✅ Complete | 3 tables — DOT→IATA translation applied |
| Gold | ✅ Complete | 5 tables — 0 NULL airport IDs, no duplicates |
| Airport Enrichment | ✅ Complete | 486,165 flights resolved (100%) |
| Reporting | ⏳ Planned | Metabase |

---

## Stack

| Layer | Technology |
|-------|------------|
| Ingestion | Python 3.12, Polars, psycopg |
| Validation | Pandera |
| Storage | PostgreSQL 16 |
| Transformation | SQL, Stored Procedures |
| Migrations | Flyway |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Version Control | Git, GitHub |

---

## Project Structure

```
flight-delays-analysis/
├── data/
│   └── raw/
│       ├── airlines.csv
│       ├── airports.csv
│       ├── flights.csv
│       ├── L_AIRPORT_ID.csv     ← BTS DOT numeric codes lookup
│       └── L_AIRPORT.csv        ← BTS IATA codes lookup
├── docs/
│   ├── naming_conventions.md
│   ├── data_catalog.md
│   ├── data_dictionary.md
│   ├── star_schema.md
│   ├── ingestion_architecture.md
│   └── eda_findings.md
├── migrations/
│   ├── V1–V4   (schemas + bronze tables)
│   ├── V5–V8   (etl logging)
│   ├── V9–V11  (silver tables)
│   ├── V12–V14 (silver SPs — includes DOT→IATA translation)
│   ├── V15–V19 (gold tables)
│   ├── V20–V24 (gold SPs — includes ON CONFLICT DO NOTHING)
│   ├── V25–V26 (BTS lookup tables)
│   ├── V27     (airports_raw enrichment)
│   ├── V28     (etl.airport_dot_iata_map)
│   └── V29     (fct_flights UNIQUE constraint)
├── sql/
│   ├── eda/
│   └── analysis/
├── src/
│   ├── config/
│   ├── database/
│   ├── pipelines/
│   │   ├── airlines_pipeline.py
│   │   ├── airports_pipeline.py
│   │   ├── airport_id_pipeline.py
│   │   ├── airport_iata_pipeline.py
│   │   └── flights_pipeline.py
│   ├── readers/
│   ├── validators/
│   └── main.py
├── tests/
├── .github/
├── docker-compose.yml
├── .env.example
├── pyproject.toml
└── README.md
```

---

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Python 3.12+
- uv
- `central-postgres` running on port 5440

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/Michael-2405/flight-delays-analysis.git
cd flight-delays-analysis

# 2. Copy environment variables
cp .env.example .env

# 3. Install Python dependencies
uv sync

# 4. Download datasets and place in data/raw/
#    - Kaggle: https://www.kaggle.com/datasets/usdot/flight-delays
#    - BTS L_AIRPORT_ID.csv: https://www.transtats.bts.gov
#    - BTS L_AIRPORT.csv: https://www.transtats.bts.gov

# 5. Run Flyway migrations
docker compose run --rm flyway migrate

# 6. Run bronze ingestion pipeline
uv run python src/main.py

# 7. Load silver layer
CALL silver.usp_load_silver_airlines();
CALL silver.usp_load_silver_airport();
CALL silver.usp_load_silver_flight();

# 8. Load gold layer
CALL gold.usp_load_gold_dim_date();
CALL gold.usp_load_gold_airline();
CALL gold.usp_load_gold_airport();
CALL gold.usp_load_gold_cancellation_reason();
CALL gold.usp_load_gold_fct_flights();
```

---

## Star Schema

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
    (destination)
```

---

## Airport Enrichment

`flights_raw` uses DOT numeric airport codes (e.g. 10423) that are not standard IATA codes. This affected 486,165 flights (8.4%) with NULL airport IDs in Gold.

**Resolution:**

- Downloaded BTS lookup tables: `L_AIRPORT_ID.csv` (DOT codes) and `L_AIRPORT.csv` (IATA codes)
- Built `etl.airport_dot_iata_map` — 6,778 DOT→IATA mappings by description match
- 302 of 306 codes resolved automatically
- 4 civil/military shared airports resolved manually (ADQ, AUS, HNL, YUM)
- Updated `usp_load_silver_flight` to translate codes via `COALESCE`
- Result: **0 NULL airport IDs** in `fct_flights`

---

## Known Technical Debt

| Issue | Impact | Priority |
|-------|--------|----------|
| No indexes on fct_flights | Slow queries on large dataset | High |
| No unit or integration tests | Pipeline correctness not automated | Medium |
| `etl_finish` uses NOW() instead of clock_timestamp() | Execution time not accurate | Low |

---

## Documentation

| Document | Description |
|----------|-------------|
| [Naming Conventions](docs/naming_conventions.md) | Rules for naming all database objects |
| [Data Catalog](docs/data_catalog.md) | Project overview, sources, architecture and glossary |
| [Data Dictionary](docs/data_dictionary.md) | Column-level description of all tables |
| [Star Schema](docs/star_schema.md) | Dimensional model diagram |
| [Ingestion Architecture](docs/ingestion_architecture.md) | Python pipeline design and patterns |
| [EDA Findings](docs/eda_findings.md) | Bronze layer data quality analysis |

---

## Dataset

**Source:** [2015 Flight Delays and Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays) — US Department of Transportation via Kaggle.

| File | Rows | Description |
|------|------|-------------|
| `flights.csv` | 5,819,079 | All US domestic flights in 2015 |
| `airlines.csv` | 14 | Airline codes and names |
| `airports.csv` | 322 | Airport codes, locations and coordinates |
| `L_AIRPORT_ID.csv` | 6,884 | BTS DOT numeric airport codes |
| `L_AIRPORT.csv` | 6,910 | BTS IATA airport codes |
