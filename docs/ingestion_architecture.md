# Ingestion Architecture — Bronze Layer

**Version:** 1.0
**Last Updated:** 2026-06
**Layer:** Bronze
**Status:** Complete

---

## Overview

The bronze ingestion pipeline reads raw CSV files from `data/raw/` and loads them into the `bronze` schema in PostgreSQL without any transformations. Data is stored exactly as received from the source.

---

## Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Raw data preservation** | No transformations applied in bronze |
| **Idempotency** | Truncate + full load on every execution |
| **Traceability** | `source_file` and `loaded_at` added to every row |
| **Validation before load** | Pandera schema validation before any insert |
| **Fail fast** | Pipeline stops on validation error |

---

## Pipeline Flow

```
data/raw/airlines.csv
data/raw/airports.csv     →  CsvReader  →  Pandera  →  Repository  →  bronze schema
data/raw/flights.csv                       Validate     + Truncate
                                                        + Insert/COPY
```

---

## Module Structure

```
src/
├── config/
│   ├── logging.py         ← Console + file logging via loguru
│   └── settings.py        ← Environment variables via pydantic-settings
├── database/
│   ├── engine.py          ← SQLAlchemy engine (postgresql+psycopg)
│   ├── base_repository.py ← Abstract base: schema_name, table_name, truncate()
│   ├── bronze_repository.py ← Implements schema_name = "bronze"
│   ├── airline_repository.py  ← insert() via executemany
│   ├── airport_repository.py  ← insert() via executemany
│   └── flight_repository.py   ← insert_batch_copy() via COPY FROM STDIN
├── pipelines/
│   ├── airlines_pipeline.py   ← read → validate → truncate → insert
│   ├── airports_pipeline.py   ← read → validate → truncate → insert
│   └── flights_pipeline.py    ← read batches → truncate → COPY
├── readers/
│   └── csv_reader.py          ← Polars read_csv wrapper
├── validators/
│   ├── airlines_schema.py     ← Pandera DataFrameSchema
│   ├── airports_schema.py
│   └── flights_schema.py
└── main.py                    ← Orchestrates all three pipelines
```

---

## Repository Pattern

```
BaseRepository (ABC)
    ├── schema_name: str (abstract property)
    ├── table_name: str (abstract property)
    └── truncate(session?) → None

BronzeRepository(BaseRepository)
    └── schema_name = "bronze"

AirlineRepository(BronzeRepository)
    ├── table_name = "airlines_raw"
    └── insert(rows) → None

AirportRepository(BronzeRepository)
    ├── table_name = "airports_raw"
    └── insert(rows) → None

FlightRepository(BronzeRepository)
    ├── table_name = "flights_raw"
    └── insert_batch_copy(rows, source_file) → None
```

---

## Load Strategy

### Airlines and Airports — executemany

Small tables (14 and 322 rows). Standard SQLAlchemy `executemany` insert.

```python
with engine.begin() as conn:
    conn.execute(table.insert(), rows)
```

### Flights — PostgreSQL COPY FROM STDIN

5.8 million rows. COPY is 10-50x faster than INSERT for bulk loads.

```python
with psycopg.connect(conn_string) as conn:
    with conn.cursor() as cur:
        with cur.copy(copy_sql) as copy:
            for row in rows:
                copy.write_row(tuple(row.get(col) for col in columns))
```

**Batch size:** 100,000 rows per batch
**Total batches:** 59
**Total rows:** 5,819,079

---

## Metadata Columns

Every bronze table receives two additional columns not present in the source CSV:

| Column | Type | Value |
|--------|------|-------|
| `source_file` | VARCHAR(500) | Name of the CSV file (e.g. `flights.csv`) |
| `loaded_at` | TIMESTAMP | Timestamp of when the row was loaded |

---

## Schema Validation

Pandera validates the CSV structure before any data is loaded into the database. If validation fails, the pipeline raises an exception and stops.

**airlines_schema** validates:
- `IATA_CODE` — string, not null
- `AIRLINE` — string, not null

**airports_schema** validates:
- `IATA_CODE`, `AIRPORT`, `CITY`, `STATE`, `COUNTRY` — string, not null
- `LATITUDE`, `LONGITUDE` — float, not null

**flights_schema** validates key columns including types and nullability.

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTGRES_HOST` | Database host | `localhost` |
| `POSTGRES_PORT` | Database port | `port` |
| `POSTGRES_USER` | Database user | `user` |
| `POSTGRES_PASSWORD` | Database password | `password` |
| `POSTGRES_DB` | Database name | `db_name` |
| `RAW_DATA_PATH` | Path to CSV files | `data/raw/` |

---

## Running the Pipeline

```bash
# From project root
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
17:33:25 | INFO    | Batch 1 — 100,000 rows — 100,000 total
...
17:36:54 | SUCCESS | Flights loaded — 59 batches — 5,819,079 rows
17:36:54 | SUCCESS | Pipeline completed — 5,819,415 total rows processed
```

---

## Logs

Pipeline logs are written to two sinks:

| Sink | Location | Rotation | Retention |
|------|----------|----------|-----------|
| Console | stdout | — | — |
| File | `logs/pipeline.log` | 10 MB | 30 days |

---

## Known Limitations

- No incremental load — every run truncates and reloads all data
- `flights_schema` validates only key columns, not all 31
- ETL logging (etl_log table) is not yet connected to pipeline execution
