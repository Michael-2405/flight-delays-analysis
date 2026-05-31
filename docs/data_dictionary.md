# Data Dictionary — Flight Delays Analysis

**Version:** 1.0
**Last Updated:** 2026-05
**Database:** PostgreSQL

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

Raw airport data loaded directly from `airports.csv`.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `iata_code` | VARCHAR(10) | NO | IATA 3-letter code identifying the airport |
| `airport` | VARCHAR(200) | NO | Full name of the airport |
| `city` | VARCHAR(100) | YES | City where the airport is located |
| `state` | VARCHAR(100) | YES | US state where the airport is located |
| `country` | VARCHAR(100) | YES | Country where the airport is located |
| `latitude` | DECIMAL(10,6) | YES | Geographic latitude coordinate of the airport |
| `longitude` | DECIMAL(10,6) | YES | Geographic longitude coordinate of the airport |
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
| `tail_number` | VARCHAR(10) | YES | Unique registration number of the aircraft |
| `origin_airport` | VARCHAR(10) | YES | IATA code of the departure airport |
| `destination_airport` | VARCHAR(10) | YES | IATA code of the arrival airport |
| `scheduled_departure` | SMALLINT | YES | Scheduled departure time in HHMM format |
| `departure_time` | SMALLINT | YES | Actual departure time in HHMM format |
| `departure_delay` | SMALLINT | YES | Departure delay in minutes. Negative = early departure |
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
| `arrival_delay` | SMALLINT | YES | Arrival delay in minutes. Negative = early arrival |
| `diverted` | SMALLINT | YES | 1 if the flight was diverted to a different airport, 0 otherwise |
| `cancelled` | SMALLINT | YES | 1 if the flight was cancelled, 0 otherwise |
| `cancellation_reason` | CHAR(1) | YES | Code indicating the reason for cancellation: A=Carrier, B=Weather, C=NAS, D=Security |
| `air_system_delay` | SMALLINT | YES | Minutes of delay caused by the National Air System |
| `security_delay` | SMALLINT | YES | Minutes of delay caused by security issues |
| `airline_delay` | SMALLINT | YES | Minutes of delay caused by the airline |
| `late_aircraft_delay` | SMALLINT | YES | Minutes of delay caused by a late arriving aircraft |
| `weather_delay` | SMALLINT | YES | Minutes of delay caused by weather conditions |
| `source_file` | VARCHAR(500) | NO | Name of the source file this record was loaded from |
| `loaded_at` | TIMESTAMP | NO | Timestamp when the record was loaded into bronze |

---

## gold.dim_airline

Dimension table containing one row per airline operating US domestic flights.

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `airline_id` | INT | NO | PK | Surrogate key — system-generated unique identifier for the airline |
| `iata_code` | VARCHAR(10) | NO | — | IATA 2-letter code identifying the airline |
| `airline_name` | VARCHAR(100) | NO | — | Full name of the airline |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update to the record |

---

## gold.dim_airport

Dimension table containing one row per airport. Used as both origin and destination in `fct_flights` (role-playing dimension).

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `airport_id` | INT | NO | PK | Surrogate key — system-generated unique identifier for the airport |
| `iata_code` | VARCHAR(10) | NO | — | IATA 3-letter code identifying the airport |
| `airport_name` | VARCHAR(200) | NO | — | Full name of the airport |
| `city` | VARCHAR(100) | YES | — | City where the airport is located |
| `state` | VARCHAR(100) | YES | — | US state where the airport is located |
| `country` | VARCHAR(100) | YES | — | Country where the airport is located |
| `latitude` | DECIMAL(10,6) | YES | — | Geographic latitude coordinate of the airport |
| `longitude` | DECIMAL(10,6) | YES | — | Geographic longitude coordinate of the airport |
| `timezone` | TEXT | YES | — | Timezone of the airport (e.g. America/New_York) |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update to the record |

---

## gold.dim_cancellation_reason

Dimension table containing the four possible cancellation reason codes. Populated via seed data.

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `cancellation_reason_id` | INT | NO | PK | Surrogate key — system-generated unique identifier for the cancellation reason |
| `cancellation_code` | CHAR(1) | NO | — | Single-letter code identifying the cancellation reason: A, B, C, or D |
| `code_description` | VARCHAR(50) | NO | — | Full description of the cancellation reason code |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update to the record |

**Seed data:**

| cancellation_code | code_description |
|-------------------|-----------------|
| A | Carrier |
| B | Weather |
| C | National Air System (NAS) |
| D | Security |

---

## gold.dim_date

Calendar dimension containing one row per day in 2015. Generated programmatically — not loaded from a source file.

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `date_id` | INT | NO | PK | Date in YYYYMMDD integer format (e.g. 20150115) |
| `full_date` | DATE | NO | — | Full date value (e.g. 2015-01-15) |
| `year` | SMALLINT | NO | — | Calendar year (e.g. 2015) |
| `month` | SMALLINT | NO | — | Calendar month number (1–12) |
| `month_name` | VARCHAR(20) | NO | — | Full name of the month (e.g. January) |
| `month_name_short` | CHAR(3) | NO | — | Abbreviated month name (e.g. Jan) |
| `day` | SMALLINT | NO | — | Day of the month (1–31) |
| `day_of_week` | SMALLINT | NO | — | Day of the week number (1=Monday, 7=Sunday) |
| `day_of_week_name` | VARCHAR(20) | NO | — | Full name of the day (e.g. Monday) |
| `day_of_week_short` | CHAR(3) | NO | — | Abbreviated day name (e.g. Mon) |
| `quarter` | SMALLINT | NO | — | Quarter of the year (1–4, each covering 3 months) |
| `semester` | SMALLINT | NO | — | Semester of the year (1–2, each covering 6 months) |
| `is_weekend` | SMALLINT | NO | — | 1 if the day is Saturday or Sunday, 0 otherwise |
| `is_holiday` | SMALLINT | NO | — | 1 if the day is a US federal holiday, 0 otherwise |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update to the record |

---

## gold.fct_flights

Fact table containing one row per flight operated in 2015. Central table of the star schema.

**Grain:** One row = one flight

| Column | Type | Nullable | PK/FK | Description |
|--------|------|----------|-------|-------------|
| `flight_id` | INT | NO | PK | Surrogate key — system-generated unique identifier for the flight |
| `date_id` | INT | NO | FK → dim_date | Date the flight operated in YYYYMMDD format |
| `airline_id` | INT | NO | FK → dim_airline | Identifier of the airline operating the flight |
| `origin_airport_id` | INT | NO | FK → dim_airport | Identifier of the departure airport |
| `destination_airport_id` | INT | NO | FK → dim_airport | Identifier of the arrival airport |
| `cancellation_reason_id` | INT | YES | FK → dim_cancellation_reason | Identifier of the cancellation reason. NULL if flight was not cancelled |
| `tail_number` | VARCHAR(10) | YES | — | Unique registration number of the aircraft (degenerate dimension) |
| `flight_number` | SMALLINT | NO | — | Flight number assigned by the airline |
| `scheduled_departure` | SMALLINT | YES | — | Scheduled departure time in HHMM format (e.g. 0600 = 6:00 AM) |
| `departure_time` | SMALLINT | YES | — | Actual departure time in HHMM format |
| `departure_delay` | SMALLINT | YES | — | Departure delay in minutes. Negative value means early departure |
| `scheduled_arrival` | SMALLINT | YES | — | Scheduled arrival time in HHMM format |
| `arrival_time` | SMALLINT | YES | — | Actual arrival time in HHMM format |
| `arrival_delay` | SMALLINT | YES | — | Arrival delay in minutes. Negative value means early arrival |
| `scheduled_time` | SMALLINT | YES | — | Scheduled flight duration in minutes |
| `elapsed_time` | SMALLINT | YES | — | Actual total flight duration gate-to-gate in minutes |
| `air_time` | SMALLINT | YES | — | Time in minutes the aircraft was airborne |
| `taxi_out` | SMALLINT | YES | — | Time in minutes between gate departure and wheels off |
| `taxi_in` | SMALLINT | YES | — | Time in minutes between wheels on and gate arrival |
| `wheels_off` | SMALLINT | YES | — | Time wheels left the ground in HHMM format |
| `wheels_on` | SMALLINT | YES | — | Time wheels touched the ground in HHMM format |
| `distance` | INT | YES | — | Distance between origin and destination airports in miles |
| `air_system_delay` | SMALLINT | YES | — | Minutes of delay attributed to the National Air System |
| `security_delay` | SMALLINT | YES | — | Minutes of delay attributed to security issues |
| `airline_delay` | SMALLINT | YES | — | Minutes of delay attributed to the airline |
| `late_aircraft_delay` | SMALLINT | YES | — | Minutes of delay attributed to a late arriving aircraft |
| `weather_delay` | SMALLINT | YES | — | Minutes of delay attributed to weather conditions |
| `is_cancelled` | SMALLINT | NO | — | 1 if the flight was cancelled, 0 otherwise |
| `is_diverted` | SMALLINT | NO | — | 1 if the flight was diverted to a different airport, 0 otherwise |
| `created_at` | TIMESTAMP | NO | — | Timestamp when the record was created |
| `updated_at` | TIMESTAMP | YES | — | Timestamp of the last update to the record |

**Business Rules:**

| Rule | Description |
|------|-------------|
| `ck_fct_flights_cancellation` | If `is_cancelled = 1` then `cancellation_reason_id` must NOT be NULL. If `is_cancelled = 0` then `cancellation_reason_id` must be NULL |
