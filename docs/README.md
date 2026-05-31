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
  bronze schema       ← raw data, no transformations
        │
        ▼
  silver schema       ← cleaned, typed, deduplicated
        │
        ▼
  gold schema         ← star schema, ready for reporting
        │
        ▼
  Metabase / Power BI ← dashboards and reports
```

---

## Stack

| Layer | Technology |
|-------|------------|
| Ingestion | Python 3.12, Polars |
| Storage | PostgreSQL 16 |
| Transformation | SQL, Stored Procedures |
| Orchestration | Prefect |
| Migrations | Flyway |
| Reporting | Metabase / Power BI |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Version Control | Git, GitHub |

---

## Project Structure

```
flight-delays-analysis/
├── data/
│   └── raw/                    ← source CSV files (gitignored)
├── sql/
│   ├── bronze/                 ← DDL for bronze tables
│   ├── silver/                 ← DDL + stored procedures for silver
│   ├── gold/                   ← DDL + stored procedures for gold
│   ├── etl/                    ← ETL log tables
│   └── seeds/                  ← seed data (dim_cancellation_reason)
├── migrations/                 ← versioned Flyway migrations
├── src/
│   └── ingestion/              ← Python scripts for bronze load
├── tests/                      ← data quality tests
├── docs/
│   ├── naming_conventions.md
│   ├── data_catalog.md
│   ├── data_dictionary.md
│   └── star_schema.md
├── .github/
│   └── workflows/              ← CI/CD pipelines
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

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-username/flight-delays-analysis.git
cd flight-delays-analysis

# 2. Copy environment variables
cp .env.example .env

# 3. Start the database
docker compose up -d

# 4. Install Python dependencies
uv venv
uv sync

# 5. Download the dataset from Kaggle and place in data/raw/
# https://www.kaggle.com/datasets/usdot/flight-delays

# 6. Run migrations
flyway migrate

# 7. Run ingestion
uv run python src/ingestion/load_bronze.py
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Naming Conventions](docs/naming_conventions.md) | Rules for naming all database objects |
| [Data Catalog](docs/data_catalog.md) | Project overview, sources, architecture, and glossary |
| [Data Dictionary](docs/data_dictionary.md) | Column-level description of all tables |
| [Star Schema](docs/star_schema.md) | Dimensional model diagram |

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
| `airports.csv` | 322 | Airport codes, locations, and coordinates |
