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
CSV Files (DOT / Kaggle)
        │
        ▼
  bronze schema       ← raw data, loaded via Python + COPY
        │
        ▼
  silver schema       ← cleaned, standardized, derived columns added
        │
        ▼
  gold schema         ← star schema, ready for reporting
        │
        ▼
  Metabase / Power BI ← dashboards and reports (planned)
```

---

## Current Status

| Layer | Status | Details |
|-------|--------|---------|
| Bronze | ✅ Complete | 3 tables — 5,819,415 rows loaded |
| ETL Logging | ✅ Complete | Connected to all Silver and Gold SPs |
| Silver | ✅ Complete | 3 tables — 5,819,415 rows |
| Gold | ✅ Complete | 5 tables — star schema operational |
| Reporting | ⏳ Planned | Metabase / Power BI |

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
│   └── raw/                         ← source CSV files (gitignored)
│       ├── airlines.csv
│       ├── airports.csv
│       ├── flights.csv
│       └── bts_airport_lookup/      ← DOT→IATA enrichment files (pending)
├── docs/
│   ├── naming_conventions.md
│   ├── data_catalog.md
│   ├── data_dictionary.md
│   ├── star_schema.md
│   ├── ingestion_architecture.md
│   └── eda_findings.md
├── migrations/
│   ├── V1__create_schemas.sql
│   ├── V2–V4   (bronze tables)
│   ├── V5–V8   (etl logging)
│   ├── V9–V11  (silver tables)
│   ├── V12–V14 (silver stored procedures)
│   ├── V15–V19 (gold tables)
│   └── V20–V24 (gold stored procedures)
├── sql/
│   ├── eda/
│   │   ├── eda_airlines_raw.sql
│   │   ├── eda_airports_raw.sql
│   │   └── eda_flights_raw.sql
│   └── analysis/
├── src/
│   ├── config/
│   │   ├── logging.py
│   │   └── settings.py
│   ├── database/
│   │   ├── base_repository.py
│   │   ├── bronze_repository.py
│   │   ├── airline_repository.py
│   │   ├── airport_repository.py
│   │   ├── flight_repository.py
│   │   └── engine.py
│   ├── pipelines/
│   │   ├── airlines_pipeline.py
│   │   ├── airports_pipeline.py
│   │   └── flights_pipeline.py
│   ├── readers/
│   │   └── csv_reader.py
│   ├── validators/
│   │   ├── airlines_schema.py
│   │   ├── airports_schema.py
│   │   └── flights_schema.py
│   └── main.py
├── tests/
├── .github/
│   ├── workflows/ci.yml
│   └── pull_request_template.md
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
# Edit .env with your local values

# 3. Install Python dependencies
uv sync

# 4. Download the dataset from Kaggle and place CSV files in data/raw/
# https://www.kaggle.com/datasets/usdot/flight-delays

# 5. Run Flyway migrations
docker compose run --rm flyway migrate

# 6. Run bronze ingestion pipeline
uv run python src/main.py

# 7. Load silver layer
CALL silver.usp_load_silver_airlines();
CALL silver.usp_load_silver_airport();
CALL silver.usp_load_silver_flight();

# 8. Load gold layer (order matters)
CALL gold.usp_load_gold_dim_date();
CALL gold.usp_load_gold_airline();
CALL gold.usp_load_gold_airport();
CALL gold.usp_load_gold_cancellation_reason();
CALL gold.usp_load_gold_fct_flights();
```

### Expected Pipeline Output

```
17:33:24 | INFO    | Loading airlines
17:33:24 | SUCCESS | Airlines loaded — 14 rows
17:33:24 | INFO    | Cumulative rows processed: 14
17:33:24 | INFO    | Loading airports
17:33:24 | SUCCESS | Airports loaded — 322 rows
17:33:24 | INFO    | Cumulative rows processed: 336
17:33:24 | INFO    | Starting flights ingestion from flights.csv
17:36:54 | SUCCESS | Flights loaded — 59 batches — 5,819,079 rows
17:36:54 | SUCCESS | Pipeline completed — 5,819,415 total rows processed
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

## Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production — protected, no direct commits |
| `dev` | Integration branch |
| `feature/*` | New features and enhancements |
| `fix/*` | Bug fixes |
| `doc/*` | Documentation updates |

---

## Known Technical Debt

| Issue | Impact | Priority |
|-------|--------|----------|
| 306 DOT numeric airport codes not in `dim_airport` | 486,165 flights with NULL airport IDs | Medium |
| No UNIQUE constraint on `fct_flights` | Duplicate flights possible on re-run | Medium |
| `etl_finish` uses NOW() instead of clock_timestamp() | Execution time not accurate | Low |
| No unit or integration tests | Pipeline correctness not automated | Medium |

---

## Dataset

**Source:** [2015 Flight Delays and Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays) — US Department of Transportation via Kaggle.

| File | Rows | Description |
|------|------|-------------|
| `flights.csv` | 5,819,079 | All US domestic flights in 2015 |
| `airlines.csv` | 14 | Airline codes and names |
| `airports.csv` | 322 | Airport codes, locations and coordinates |
