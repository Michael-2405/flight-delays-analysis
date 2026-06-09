# Ingestion Architecture — Bronze Layer

**Version:** 1.1
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
data/raw/airports.csv
data/raw/L_AIRPORT_ID.csv  →  CsvReader  →  Pandera  →  Repository  →  bronze schema
data/raw/L_AIRPORT.csv                       Validate     + Truncate
data/raw/flights.csv                                      + Insert/COPY
```

---

## Module Structure

```
src/
├── config/
│   ├── logging.py              ← Console + file logging via loguru
│   └── settings.py             ← Environment variables via pydantic-settings
├── database/
│   ├── engine.py               ← SQLAlchemy engine (postgresql+psycopg)
│   ├── base_repository.py      ← Abstract base: schema_name, table_name, truncate()
│   ├── bronze_repository.py    ← Implements schema_name = "bronze"
│   ├── airlines_repository.py  ← insert() via executemany
│   ├── airports_repository.py  ← insert() via executemany
│   ├── airport_id_repository.py   ← insert() via executemany
│   ├── airport_iata_repository.py ← insert() via executemany
│   └── flights_repository.py   ← insert_batch_copy() via COPY FROM STDIN
├── pipelines/
│   ├── airlines_pipeline.py    ← read → validate → truncate → insert
│   ├── airports_pipeline.py    ← read → validate → truncate → insert
│   ├── airport_id_pipeline.py  ← read (latin1) → validate → truncate → insert
│   ├── airport_iata_pipeline.py← read (latin1) → validate → truncate → insert
│   └── flights_pipeline.py     ← read batches → truncate → COPY
├── readers/
│   └── csv_reader.py           ← Polars read_csv wrapper with encoding support
├── validators/
│   ├── airlines_schema.py      ← Pandera DataFrameSchema
│   ├── airports_schema.py
│   ├── airport_id_schema.py
│   ├── airport_iata_schema.py
│   └── flights_schema.py
└── main.py                     ← Orchestrates all five pipelines
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

AirportIdRepository(BronzeRepository)
    ├── table_name = "airport_id_raw"
    └── insert(rows) → None

AirportIataRepository(BronzeRepository)
    ├── table_name = "airport_iata_raw"
    └── insert(rows) → None

FlightRepository(BronzeRepository)
    ├── table_name = "flights_raw"
    └── insert_batch_copy(rows, source_file) → None
```

---

## Load Strategy

### Airlines, Airports, Airport ID, Airport IATA — executemany

Small tables (14 to 6,910 rows). Standard SQLAlchemy `executemany` insert.

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

## Encoding

Most source files use UTF-8. BTS government files use latin1:

| File | Encoding |
|------|----------|
| `airlines.csv` | utf8 |
| `airports.csv` | utf8 |
| `flights.csv` | utf8 |
| `L_AIRPORT_ID.csv` | latin1 |
| `L_AIRPORT.csv` | latin1 |

`CsvReader.read()` defaults to `utf8`. Pass `encoding="latin1"` for BTS files.

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
- `LATITUDE`, `LONGITUDE` — float, **nullable** (ECP, PBG, UST have no coordinates)

**airport_id_schema** validates:
- `Code` — int, not null
- `Description` — string, not null

**airport_iata_schema** validates:
- `Code` — string, not null
- `Description` — string, not null

**flights_schema** validates key columns including types and nullability.

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTGRES_HOST` | Database host | `localhost` |
| `POSTGRES_PORT` | Database port | `5440` |
| `POSTGRES_USER` | Database user | `postgres` |
| `POSTGRES_PASSWORD` | Database password | `secret` |
| `POSTGRES_DB` | Database name | `flight_delays` |
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
17:33:24 | SUCCESS | Airlines loaded
17:33:24 | INFO    | Cumulative rows processed: 14
17:33:24 | INFO    | Loading airports
17:33:24 | SUCCESS | Airports loaded
17:33:24 | INFO    | Cumulative rows processed: 336
17:33:24 | INFO    | Loading L_AIRPORT_ID
17:33:24 | SUCCESS | L_AIRPORT_ID loaded
17:33:24 | INFO    | Cumulative rows processed: 7,220
17:33:24 | INFO    | Loading L_AIRPORT
17:33:24 | SUCCESS | L_AIRPORT loaded
17:33:24 | INFO    | Cumulative rows processed: 14,130
17:33:24 | INFO    | Starting flights ingestion from flights.csv
17:33:25 | INFO    | Batch 1 — 100,000 rows — 100,000 total
...
17:36:54 | SUCCESS | Flights loaded — 59 batches — 5,819,079 rows
17:36:54 | SUCCESS | Pipeline completed — 5,833,209 total rows processed
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
