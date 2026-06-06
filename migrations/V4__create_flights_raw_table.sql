-- Script Name: V4__create_flights_raw_table.sql
-- Description: Creates the flights raw table, this table getS loaded
--              from a CSV thru a python script. It saves the flights
--              delayed, cancelled, diverted information.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE TABLE If NOT EXISTS bronze.flights_raw (
  year                SMALLINT       NULL,
  month               SMALLINT       NULL,
  day                 SMALLINT       NULL,
  day_of_week         SMALLINT       NULL,
  airline             VARCHAR(10)    NULL,
  flight_number       SMALLINT       NULL,
  tail_number         VARCHAR(10)    NULL,
  origin_airport      VARCHAR(10)    NULL,
  destination_airport VARCHAR(10)    NULL,
  scheduled_departure SMALLINT       NULL,
  departure_time      SMALLINT       NULL,
  departure_delay     SMALLINT       NULL,
  taxi_out            SMALLINT       NULL,
  wheels_off          SMALLINT       NULL,
  scheduled_time      SMALLINT       NULL,
  elapsed_time        SMALLINT       NULL,
  air_time            SMALLINT       NULL,
  distance            INT            NULL,
  wheels_on           SMALLINT       NULL,
  taxi_in             SMALLINT       NULL,
  scheduled_arrival   SMALLINT       NULL,
  arrival_time        SMALLINT       NULL,
  arrival_delay       SMALLINT       NULL,
  diverted            SMALLINT       NULL,
  cancelled           SMALLINT       NULL,
  cancellation_reason CHAR(1)        NULL,
  air_system_delay    SMALLINT       NULL,
  security_delay      SMALLINT       NULL,
  airline_delay       SMALLINT       NULL,
  late_aircraft_delay SMALLINT       NULL,
  weather_delay       SMALLINT       NULL,
  source_file         VARCHAR(100)   NOT NULL,
  loaded_at           TIMESTAMP      NOT NULL    DEFAULT NOW()
);
