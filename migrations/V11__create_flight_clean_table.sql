-- =============================================================
-- Script Name: V11__create_flight_clean_table.sql
-- Description: Creates silver.flight_clean — cleaned flight data
--              loaded from bronze.flights_raw via stored procedure.
--              Adds derived columns full_date (DATE) and date_id (INT
--              YYYYMMDD) for joining with gold.dim_date.
--              DOT numeric airport codes translated to IATA in the SP.
--              Load strategy: truncate + full load.
-- Schema:      silver
-- Author:      Michael Espinosa
-- Date:        2026-06-05
-- Change Log:
--   2026-06-05 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS silver.flight_clean (
  year                SMALLINT    NULL,
  month               SMALLINT    NULL,
  day                 SMALLINT    NULL,
  day_of_week         SMALLINT    NULL,
  full_date           DATE        NULL,
  date_id             INT         NULL,
  airline             VARCHAR(10) NULL,
  flight_number       SMALLINT    NULL,
  tail_number         VARCHAR(10) NULL,
  origin_airport      VARCHAR(10) NULL,
  destination_airport VARCHAR(10) NULL,
  scheduled_departure SMALLINT    NULL,
  departure_time      SMALLINT    NULL,
  departure_delay     SMALLINT    NULL,
  taxi_out            SMALLINT    NULL,
  wheels_off          SMALLINT    NULL,
  scheduled_time      SMALLINT    NULL,
  elapsed_time        SMALLINT    NULL,
  air_time            SMALLINT    NULL,
  distance            INT         NULL,
  wheels_on           SMALLINT    NULL,
  taxi_in             SMALLINT    NULL,
  scheduled_arrival   SMALLINT    NULL,
  arrival_time        SMALLINT    NULL,
  arrival_delay       SMALLINT    NULL,
  diverted            SMALLINT    NOT NULL,
  cancelled           SMALLINT    NOT NULL,
  cancellation_reason CHAR(1)     NULL,
  air_system_delay    SMALLINT    NULL,
  security_delay      SMALLINT    NULL,
  airline_delay       SMALLINT    NULL,
  late_aircraft_delay SMALLINT    NULL,
  weather_delay       SMALLINT    NULL,
  created_at          TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMP   NULL
);
