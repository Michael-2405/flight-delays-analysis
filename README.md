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
  silver schema       ← cleaned, typed, deduplicated (in progress)
        │
        ▼
  gold schema         ← star schema, ready for reporting (in progress)
        │
        ▼
  Metabase / Power BI ← dashboards and reports (planned)
```

---

## Current Status

| Layer | Status | Details |
|-------|--------|---------|
| Bronze | ✅ Complete | All 3 tables loaded — 5,819,415 rows |
| ETL Logging | ✅ Complete | etl_log table + start/success/error functions |
| Silver | 🔄 Pending | Tables not created, transformations pending EDA |
| Gold | 🔄 Pending | Star schema designed, SPs pending |
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
| Orchestration | Prefect (planned) |
| Reporting | Metabase / Power BI (planned) |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Version Control | Git, GitHub |

---

## Project Structure

```
flight-delays-analysis/
├── data/
│   └── raw/                         ← source CSV files (gitignored)
├── docs/
│   ├── naming_conventions.md
│   ├── data_catalog.md
│   ├── data_dictionary.md
│   ├── star_schema.md
│   └── ingestion_architecture.md
├── migrations/                      ← Flyway versioned SQL migrations
│   ├── V1__create_schemas.sql
│   ├── V2__create_airlines_raw_table.sql
│   ├── V3__create_airports_raw_table.sql
│   ├── V4__create_flights_raw_table.sql
│   ├── V5__create_etl_log_table.sql
│   ├── V6__create_ufn_log_start_etl.sql
│   ├── V7__create_usp_log_success_etl.sql
│   ├── V8__create_usp_log_error_etl.sql
│   └── V9–V24 (silver + gold — pending EDA)
├── src/
│   ├── config/
│   │   ├── logging.py               ← loguru configuration
│   │   └── settings.py              ← pydantic-settings env config
│   ├── database/
│   │   ├── base_repository.py       ← abstract base with truncate()
│   │   ├── bronze_repository.py     ← bronze schema base
│   │   ├── airline_repository.py
│   │   ├── airport_repository.py
│   │   ├── flight_repository.py     ← COPY FROM STDIN bulk insert
│   │   └── engine.py                ← SQLAlchemy engine
│   ├── pipelines/
│   │   ├── airlines_pipeline.py
│   │   ├── airports_pipeline.py
│   │   └── flights_pipeline.py      ← batch processing 100k rows
│   ├── readers/
│   │   └── csv_reader.py            ← Polars CSV reader
│   ├── validators/
│   │   ├── airlines_schema.py       ← Pandera schema
│   │   ├── airports_schema.py
│   │   └── flights_schema.py
│   └── main.py                      ← pipeline entry point
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   ├── etl/
│   └── seeds/
├── tests/
├── .github/
│   ├── workflows/
│   │   └── ci.yml                   ← lint, migrate, test
│   └── pull_request_template.md
├── docker-compose.yml               ← Flyway service
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

# 6. Run ingestion pipeline
uv run python src/main.py
```

### Expected Output

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

## Documentation

| Document | Description |
|----------|-------------|
| [Naming Conventions](docs/naming_conventions.md) | Rules for naming all database objects |
| [Data Catalog](docs/data_catalog.md) | Project overview, sources, architecture and glossary |
| [Data Dictionary](docs/data_dictionary.md) | Column-level description of all tables |
| [Star Schema](docs/star_schema.md) | Dimensional model diagram |
| [Ingestion Architecture](docs/ingestion_architecture.md) | Python pipeline design and patterns |

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

## Dataset

**Source:** [2015 Flight Delays and Cancellations](https://www.kaggle.com/datasets/usdot/flight-delays) — US Department of Transportation via Kaggle.

| File | Rows | Description |
|------|------|-------------|
| `flights.csv` | 5,819,079 | All US domestic flights in 2015 |
| `airlines.csv` | 14 | Airline codes and names |
| `airports.csv` | 322 | Airport codes, locations and coordinates |
