# Data Dictionary — Flight Delays Analysis

**Version:** 1.2
**Last Updated:** 2026-06
**Database:** PostgreSQL 16

---

## bronze.airlines_raw

Raw airline data loaded directly from `airlines.csv`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `iata_code` | VARCHAR(10) | NO | IATA 2-letter code identifying the airline |
| `airline` | VARCHAR(100) | NO | Full name of the airline |
| `source_file` | VARCHAR(500) | NO | Name of the source file this record was loaded from |
| `loaded_at` | TIMESTAMP | NO | Timestamp when the record was loaded into bronze |

---

## bronze.airports_raw

Raw airport data loaded directly from `airports.csv` and enriched via V27.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `iata_code` | VARCHAR(10) | NO | IATA 3-letter code identifying the airport |
| `airport` | VARCHAR(200) | NO | Full name of the airport |
| `city` | VARCHAR(100) | YES | City where the airport is located |
| `state` | VARCHAR(100) | YES | US state where the airport is located |
| `country` | VARCHAR(100) | YES | Country where the airport is located |
| `latitude` | DECIMAL(10,6) | YES | Geographic latitude coordinate. NULL for ECP, PBG, UST |
| `longitude` | DECIMAL(10,6) | YES | Geographic longitude coordinate. NULL for ECP, PBG, UST |
| `source_file` | VARCHAR(500) | NO | Name of the source file this record was loaded from |
| `loaded_at` | TIMESTAMP | NO | Timestamp when the record was loaded into bronze |

---

## bronze.flights_raw

Raw flight data loaded directly from `flights.csv`. One row per flight.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `year` | SMALLINT | YES | Year the flight operated |
| `month` | SMALLINT | YES | Month the flight operated (1–12) |
| `day` | SMALLINT | YES | Day of the month the flight operated |
| `day_of_week` | SMALLINT | YES | Day of the week (1=Monday, 7=Sunday) |
| `airline` | VARCHAR(10) | YES | IATA 2-letter code of the operating airline |
| `flight_number` | SMALLINT | YES | Flight number assigned by the airline |
| `tail_number` | VARCHAR(10) | YES | Unique registration number of the aircraft. 14,721 NULLs |
| `origin_airport` | VARCHAR(10) | YES | IATA code or DOT numeric code of the departure airport |
| `destination_airport` | VARCHAR(10) | YES | IATA code or DOT numeric code of the arrival airport |
| `scheduled_departure` | SMALLINT | YES | Scheduled departure time in HHMM format |
| `departure_time` | SMALLINT | YES | Actual departure time in HHMM format |
| `departure_delay` | SMALLINT | YES | Departure delay in minutes. Negative = early. NULL when cancelled |
| `taxi_out` | SMALLINT | YES | Time in minutes between gate departure and wheels off |
| `wheels_off` | SMALLINT | YES | Actual time wheels left the ground in HHMM format |
| `scheduled_time` | SMALLINT | YES | Scheduled flight duration in minutes |
| `elapsed_time` | SMALLINT | YES | Actual total flight duration in minutes |
| `air_time` | SMALLINT | YES | Time in minutes the aircraft was airborne |
| `distance` | INT | YES | Distance between origin and destination airports in miles |
| `wheels_on` | SMALLINT | YES | Actual time wheels touched the ground in HHMM format |
| `taxi_in` | SMALLINT | YES | Time in minutes between wheels on and gate arrival |
| `scheduled_arrival` | SMALLINT | YES | Scheduled arrival time in HHMM format |
| `arrival_time` | SMALLINT | YES | Actual arrival time in HHMM format |
| `arrival_delay` | SMALLINT | YES | Arrival delay in minutes. Negative = early. NULL when cancelled |
| `diverted` | SMALLINT | YES | 1 if the flight was diverted to a different airport, 0 otherwise |
| `cancelled` | SMALLINT | YES | 1 if the flight was cancelled, 0 otherwise |
| `cancellation_reason` | CHAR(1) | YES | A=Carrier, B=Weather, C=NAS, D=Security. NULL when not cancelled |
| `air_system_delay` | SMALLINT | YES | Minutes of delay caused by the National Air System |
| `security_delay` | SMALLINT | YES | Minutes of delay caused by security issues |
| `airline_delay` | SMALLINT | YES | Minutes of delay caused by the airline |
| `late_aircraft_delay` | SMALLINT | YES | Minutes of delay caused by a late arriving aircraft |
| `weather_delay` | SMALLINT | YES | Minutes of delay caused by weather conditions |
| `source_file` | VARCHAR(500) | NO | Name of the source file this record was loaded from |
| `loaded_at` | TIMESTAMP | NO | Timestamp when the record was loaded into bronze |

---

## bronze.airport_id_raw

BTS DOT numeric airport code lookup table. Loaded from `L_AIRPORT_ID.csv`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `code` | INT | NO | DOT numeric airport identifier |
| `description` | VARCHAR(300) | NO | Airport description in format "City, ST: Airport Name" |
| `source_file` | VARCHAR(100) | NO | Name of the source file this record was loaded from |
| `loaded_at` | TIMESTAMP | NO | Timestamp when the record was loaded into bronze |

---

## bronze.airport_iata_raw

BTS IATA airport code lookup table. Loaded from `L_AIRPORT.csv`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `code` | VARCHAR(10) | NO | IATA or FAA airport code |
| `description` | VARCHAR(300) | NO | Airport description in format "City, ST: Airport Name" |
| `source_file` | VARCHAR(100) | NO | Name of the source file this record was loaded from |
| `loaded_at` | TIMESTAMP | NO | Timestamp when the record was loaded into bronze |

---

## silver.airline_clean

Cleaned airline data loaded from `bronze.airlines_raw`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `iata_code` | VARCHAR(10) | NO | IATA 2-letter code identifying the airline |
| `airline_name` | VARCHAR(100) | NO | Full name of the airline (renamed from `airline` in bronze) |
| `created_at` | TIMESTAMP | NO | Timestamp when the record was created in silver |
| `updated_at` | TIMESTAMP | YES | Timestamp of the last update to the record |

---

## silver.airport_clean

Cleaned airport data loaded from `bronze.airports_raw`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `iata_code` | VARCHAR(10) | NO | IATA 3-letter code identifying the airport |
| `airport_name` | VARCHAR(200) | NO | Full name of the airport (renamed from `airport` in bronze) |
| `city` | VARCHAR(100) | YES | City where the airport is located |
| `state` | VARCHAR(100) | YES | US state where the airport is located |
| `country` | VARCHAR(100) | YES | Country where the airport is located |
| `latitude` | DECIMAL(10,6) | YES | Geographic latitude. NULL for ECP, PBG, UST |
| `longitude` | DECIMAL(10,6) | YES | Geographic longitude. NULL for ECP, PBG, UST |
| `created_at` | TIMESTAMP | NO | Timestamp when the record was created in silver |
| `updated_at` | TIMESTAMP | YES | Timestamp of the last update to the record |

---

## silver.flight_clean

Cleaned flight data loaded from `bronze.flights_raw`. One row per flight.
DOT numeric airport codes translated to IATA via `etl.airport_dot_iata_map`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `year` | SMALLINT | YES | Year the flight operated |
| `month` | SMALLINT | YES | Month the flight operated (1–12) |
| `day` | SMALLINT | YES | Day of the month the flight operated |
| `day_of_week` | SMALLINT | YES | Day of the week (1=Monday, 7=Sunday) |
| `full_date` | DATE | YES | Full date derived from year, month, day (e.g. 2015-01-15) |
| `date_id` | INT | YES | Date in YYYYMMDD format for joining with dim_date (e.g. 20150115) |
| `airline` | VARCHAR(10) | YES | IATA 2-letter code of the operating airline |
| `flight_number` | SMALLINT | YES | Flight number assigned by the airline |
| `tail_number` | VARCHAR(10) | YES | Unique registration number of the aircraft. 14,721 NULLs |
| `origin_airport` | VARCHAR(10) | YES | IATA code of the departure airport (DOT codes translated) |
| `destination_airport` | VARCHAR(10) | YES | IATA code of the arrival airport (DOT codes translated) |
| `scheduled_departure` | SMALLINT | YES | Scheduled departure time in HHMM format |
| `departure_time` | SMALLINT | YES | Actual departure time in HHMM format |
| `departure_delay` | SMALLINT | YES | Departure delay in minutes. Negative = early. NULL when cancelled |
| `taxi_out` | SMALLINT | YES | Time in minutes between gate departure and wheels off |
| `wheels_off` | SMALLINT | YES | Actual time wheels left the ground in HHMM format |
| `scheduled_time` | SMALLINT | YES | Scheduled flight duration in minutes |
| `elapsed_time` | SMALLINT | YES | Actual total flight duration in minutes |
| `air_time` | SMALLINT | YES | Time in minutes the aircraft was airborne |
| `distance` | INT | YES | Distance between origin and destination airports in miles |
| `wheels_on` | SMALLINT | YES | Actual time wheels touched the ground in HHMM format |
| `taxi_in` | SMALLINT | YES | Time in minutes between wheels on and gate arrival |
| `scheduled_arrival` | SMALLINT | YES | Scheduled arrival time in HHMM format |
| `arrival_time` | SMALLINT | YES | Actual arrival time in HHMM format |
| `arrival_delay` | SMALLINT | YES | Arrival delay in minutes. Negative = early. NULL when cancelled |
| `diverted` | SMALLINT | NO | 1 if the flight was diverted, 0 otherwise |
| `cancelled` | SMALLINT | NO | 1 if the flight was cancelled, 0 otherwise |
| `cancellation_reason` | CHAR(1) | YES | A=Carrier, B=Weather, C=NAS, D=Security. NULL when not cancelled |
| `air_system_delay` | SMALLINT | YES | Minutes of delay caused by the National Air System |
| `security_delay` | SMALLINT | YES | Minutes of delay caused by security issues |
| `airline_delay` | SMALLINT | YES | Minutes of delay caused by the airline |
| `late_aircraft_delay` | SMALLINT | YES | Minutes of delay caused by a late arriving aircraft |
| `weather_delay` | SMALLINT | YES | Minutes of delay caused by weather conditions |
| `created_at` | TIMESTAMP | NO | Timestamp when the record was created in silver |
| `updated_at` | TIMESTAMP | YES | Timestamp of the last update to the record |

---

## etl.etl_log

Pipeline execution log. One row per stored procedure execution.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `etl_log_id` | INT | NO | Surrogate key — auto-generated identity |
| `etl_name` | VARCHAR(100) | NO | Name of the stored procedure that was executed |
| `etl_start` | TIMESTAMP | NO | Timestamp when the execution started |
| `etl_finish` | TIMESTAMP | YES | Timestamp when the execution finished |
| `etl_rows_written` | INT | YES | Number of rows inserted or updated |
| `etl_rows_updated` | INT | YES | Number of rows updated specifically |
| `etl_rows_read` | INT | YES | Number of rows read from source |
| `etl_rows_deleted` | INT | YES | Number of rows deleted |
| `etl_status` | VARCHAR(50) | YES | Execution status: RUNNING, SUCCESS, FAILED |
| `etl_error_code` | INT | YES | Error code if execution failed |
| `etl_error_message` | TEXT | YES | Error message if execution failed |
| `etl_ran_by` | TEXT | NO | Database user that executed the SP |

---

## etl.airport_dot_iata_map

Reference table mapping DOT numeric airport codes to IATA codes.
Built by crossing `airport_id_raw` with `airport_iata_raw` on description match.

| Column | Type | Nullable | PK | Description |
|--------|------|----------|----|-------------|
| `dot_code` | INT | NO | PK | DOT numeric airport identifier |
| `iata_code` | VARCHAR(10) | NO | — | Corresponding IATA airport code |

---

## gold.dim_airline

Airline dimension. Loaded from `silver.airline_clean` via UPSERT (SCD Tipo 1).

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `airline_id` | INT | NO | PK | Surrogate key — auto-generated identity |
| `iata_code` | VARCHAR(10) | NO | UNIQUE | IATA 2-letter airline code |
| `airline_name` | VARCHAR(100) | NO | — | Full name of the airline |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update |

---

## gold.dim_airport

Airport dimension. Role-playing — used as both origin and destination in `fct_flights`.
Loaded from `silver.airport_clean` via UPSERT (SCD Tipo 1).

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `airport_id` | INT | NO | PK | Surrogate key — auto-generated identity |
| `iata_code` | VARCHAR(10) | NO | UNIQUE | IATA 3-letter airport code |
| `airport_name` | VARCHAR(200) | NO | — | Full name of the airport |
| `city` | VARCHAR(100) | YES | — | City where the airport is located |
| `state` | VARCHAR(100) | YES | — | US state where the airport is located |
| `country` | VARCHAR(100) | YES | — | Country where the airport is located |
| `latitude` | DECIMAL(10,6) | YES | — | Geographic latitude coordinate |
| `longitude` | DECIMAL(10,6) | YES | — | Geographic longitude coordinate |
| `timezone` | TEXT | YES | — | IANA timezone identifier (e.g. America/New_York) |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update |

---

## gold.dim_cancellation_reason

Static cancellation reason dimension. Loaded via seed data UPSERT.

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `cancellation_reason_id` | INT | NO | PK | Surrogate key — auto-generated identity |
| `cancellation_code` | CHAR(1) | NO | UNIQUE | Single-letter code: A, B, C, or D |
| `code_description` | VARCHAR(50) | NO | — | Full description of the cancellation reason |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update |

**Seed data:**

| cancellation_code | code_description |
|-------------------|-----------------|
| A | Carrier |
| B | Weather |
| C | National Air System (NAS) |
| D | Security |

---

## gold.dim_date

Calendar dimension. Pre-populated via `generate_series` from 2014-01-01 to 2016-12-31.
Idempotent INSERT — safe to re-run.

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `date_id` | INT | NO | PK | Date in YYYYMMDD format (e.g. 20150115) |
| `full_date` | DATE | NO | — | Full date value (e.g. 2015-01-15) |
| `year` | SMALLINT | NO | — | Calendar year |
| `month` | SMALLINT | NO | — | Calendar month (1–12) |
| `month_name` | VARCHAR(20) | NO | — | Full month name (e.g. January) |
| `month_name_short` | CHAR(3) | NO | — | Abbreviated month name (e.g. Jan) |
| `day` | SMALLINT | NO | — | Day of the month (1–31) |
| `day_of_week` | SMALLINT | NO | — | Day of the week (1=Monday, 7=Sunday) |
| `day_of_week_name` | VARCHAR(20) | NO | — | Full day name (e.g. Monday) |
| `day_of_week_short` | CHAR(3) | NO | — | Abbreviated day name (e.g. Mon) |
| `quarter` | SMALLINT | NO | — | Quarter of the year (1–4) |
| `semester` | SMALLINT | NO | — | Semester of the year (1–2) |
| `is_weekend` | SMALLINT | NO | — | 1 if Saturday or Sunday, 0 otherwise |
| `is_holiday` | SMALLINT | NO | — | 1 if US federal holiday, 0 otherwise |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update |

---

## gold.fct_flights

Central fact table. One row per US domestic flight operated in 2015.
Natural key: `date_id + airline_id + flight_number + origin_airport_id + destination_airport_id`.

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `flight_id` | INT | NO | PK | Surrogate key — auto-generated identity |
| `date_id` | INT | NO | FK → dim_date | Date the flight operated in YYYYMMDD format |
| `airline_id` | INT | NO | FK → dim_airline | Surrogate key of the operating airline |
| `origin_airport_id` | INT | YES | FK → dim_airport | Surrogate key of the departure airport. Nullable |
| `destination_airport_id` | INT | YES | FK → dim_airport | Surrogate key of the arrival airport. Nullable |
| `cancellation_reason_id` | INT | YES | FK → dim_cancellation_reason | NULL if not cancelled |
| `tail_number` | VARCHAR(10) | YES | — | Aircraft registration number (degenerate dimension) |
| `flight_number` | SMALLINT | NO | — | Flight number assigned by the airline |
| `scheduled_departure` | SMALLINT | YES | — | Scheduled departure time in HHMM format |
| `departure_time` | SMALLINT | YES | — | Actual departure time in HHMM format |
| `departure_delay` | SMALLINT | YES | — | Departure delay in minutes. Negative = early |
| `scheduled_arrival` | SMALLINT | YES | — | Scheduled arrival time in HHMM format |
| `arrival_time` | SMALLINT | YES | — | Actual arrival time in HHMM format |
| `arrival_delay` | SMALLINT | YES | — | Arrival delay in minutes. Negative = early |
| `scheduled_time` | SMALLINT | YES | — | Scheduled flight duration in minutes |
| `elapsed_time` | SMALLINT | YES | — | Actual gate-to-gate duration in minutes |
| `air_time` | SMALLINT | YES | — | Time airborne in minutes |
| `taxi_out` | SMALLINT | YES | — | Time between gate departure and wheels off in minutes |
| `taxi_in` | SMALLINT | YES | — | Time between wheels on and gate arrival in minutes |
| `wheels_off` | SMALLINT | YES | — | Time wheels left the ground in HHMM format |
| `wheels_on` | SMALLINT | YES | — | Time wheels touched the ground in HHMM format |
| `distance` | INT | YES | — | Distance in miles between origin and destination |
| `air_system_delay` | SMALLINT | YES | — | Minutes of delay attributed to the National Air System |
| `security_delay` | SMALLINT | YES | — | Minutes of delay attributed to security |
| `airline_delay` | SMALLINT | YES | — | Minutes of delay attributed to the airline |
| `late_aircraft_delay` | SMALLINT | YES | — | Minutes of delay from a late arriving aircraft |
| `weather_delay` | SMALLINT | YES | — | Minutes of delay attributed to weather |
| `is_cancelled` | SMALLINT | NO | — | 1 if cancelled, 0 otherwise |
| `is_diverted` | SMALLINT | NO | — | 1 if diverted to a different airport, 0 otherwise |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update |

**Constraints:**

| Constraint | Type | Description |
|------------|------|-------------|
| `pk_fct_flights` | PRIMARY KEY | `flight_id` |
| `uq_fct_flights_natural_key` | UNIQUE NULLS NOT DISTINCT | `date_id, airline_id, flight_number, origin_airport_id, destination_airport_id` |
| `ck_fct_flights_cancellation` | CHECK | `is_cancelled = 1` requires `cancellation_reason_id IS NOT NULL`. `is_cancelled = 0` requires `cancellation_reason_id IS NULL` |

**Indexes:**

| Index | Column |
|-------|--------|
| `idx_fct_flights_date_id` | `date_id` |
| `idx_fct_flights_airline_id` | `airline_id` |
| `idx_fct_flights_origin_airport_id` | `origin_airport_id` |
| `idx_fct_flights_destination_airport_id` | `destination_airport_id` |
| `idx_fct_flights_is_cancelled` | `is_cancelled` |
| `idx_fct_flights_departure_delay` | `departure_delay` |
| `idx_fct_flights_arrival_delay` | `arrival_delay` |
