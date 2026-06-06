-- Script Name: V19__create_fct_flight_table.sql
-- Description: Creates the fct_flight table in the gold schema.
--              This is a fact tables that stores every flight operated
--              in 2015. Ready for use in the star schema for flight
--            delay analysis.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

CREATE TABLE IF NOT EXISTS gold.fct_flights(
  flight_id               INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
  date_id                 INT           NOT NULL,
  airline_id              INT           NOT NULL,
  origin_airport_id       INT           NOT NULL,
  destination_airport_id  INT           NOT NULL,
  cancellation_reason_id  INT           NULL,
  tail_number             VARCHAR(10)   NULL,
  flight_number           SMALLINT      NOT NULL,
  scheduled_departure     SMALLINT      NULL,
  departure_time          SMALLINT      NULL,
  departure_delay         SMALLINT      NULL,
  scheduled_arrival       SMALLINT      NULL,
  arrival_time            SMALLINT      NULL,
  arrival_delay           SMALLINT      NULL,
  scheduled_time          SMALLINT      NULL,
  elapsed_time            SMALLINT      NULL,
  air_time                SMALLINT      NULL,
  taxi_out                SMALLINT      NULL,
  taxi_in                 SMALLINT      NULL,
  wheels_off              SMALLINT      NULL,
  wheels_on               SMALLINT      NULL,
  distance                INT           NULL,
  air_system_delay        SMALLINT      NULL,
  security_delay          SMALLINT      NULL,
  airline_delay           SMALLINT      NULL,
  late_aircraft_delay     SMALLINT      NULL,
  weather_delay           SMALLINT      NULL,
  is_cancelled            SMALLINT      NOT NULL,
  is_diverted             SMALLINT      NOT NULL,
  created_at              TIMESTAMP     NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMP,

  CONSTRAINT pk_fct_flights                         PRIMARY KEY (flight_id),
  CONSTRAINT fk_fct_flights_dim_date                FOREIGN KEY (date_id)                REFERENCES gold.dim_date(date_id),
  CONSTRAINT fk_fct_flights_dim_airline             FOREIGN KEY (airline_id)             REFERENCES gold.dim_airline(airline_id),
  CONSTRAINT fk_fct_flights_dim_airport_origin      FOREIGN KEY (origin_airport_id)      REFERENCES gold.dim_airport(airport_id),
  CONSTRAINT fk_fct_flights_dim_airport_destination FOREIGN KEY (destination_airport_id) REFERENCES gold.dim_airport(airport_id),
  CONSTRAINT fk_fct_flights_dim_cancellation_reason FOREIGN KEY (cancellation_reason_id) REFERENCES gold.dim_cancellation_reason(cancellation_reason_id),

  CONSTRAINT ck_fct_flights_cancellation
  CHECK (
      (is_cancelled = 1 AND cancellation_reason_id IS NOT NULL)
      OR
      (is_cancelled = 0 AND cancellation_reason_id IS NULL)
  )
);

COMMENT ON TABLE gold.fct_flights IS
'Fact table that stores every flight operated in 2015. Designed for flight delay analysis in the gold star schema.';

COMMENT ON COLUMN gold.fct_flights.flight_id IS
'Surrogate key';

COMMENT ON COLUMN gold.fct_flights.date_id IS
'Date the flight operated in YYYYMMDD format';

COMMENT ON COLUMN gold.fct_flights.airline_id IS
'Identifier of the operating airline';

COMMENT ON COLUMN gold.fct_flights.origin_airport_id IS
'Identifier of the departure airport';

COMMENT ON COLUMN gold.fct_flights.destination_airport_id IS
'Identifier of the arrival airport';

COMMENT ON COLUMN gold.fct_flights.cancellation_reason_id IS
'Cancellation reason identifier. NULL if the flight was not cancelled';

COMMENT ON COLUMN gold.fct_flights.tail_number IS
'Aircraft registration number (degenerate dimension)';

COMMENT ON COLUMN gold.fct_flights.flight_number IS
'Flight number assigned by the airline';

COMMENT ON COLUMN gold.fct_flights.scheduled_departure IS
'Scheduled departure time in HHMM format';

COMMENT ON COLUMN gold.fct_flights.departure_time IS
'Actual departure time in HHMM format';

COMMENT ON COLUMN gold.fct_flights.departure_delay IS
'Departure delay in minutes. Negative values indicate early departure';

COMMENT ON COLUMN gold.fct_flights.scheduled_arrival IS
'Scheduled arrival time in HHMM format';

COMMENT ON COLUMN gold.fct_flights.arrival_time IS
'Actual arrival time in HHMM format';

COMMENT ON COLUMN gold.fct_flights.arrival_delay IS
'Arrival delay in minutes. Negative values indicate early arrival';

COMMENT ON COLUMN gold.fct_flights.scheduled_time IS
'Scheduled flight duration in minutes';

COMMENT ON COLUMN gold.fct_flights.elapsed_time IS
'Actual gate-to-gate duration in minutes';

COMMENT ON COLUMN gold.fct_flights.air_time IS
'Time airborne in minutes';

COMMENT ON COLUMN gold.fct_flights.taxi_out IS
'Time between gate departure and wheels off in minutes';

COMMENT ON COLUMN gold.fct_flights.taxi_in IS
'Time between wheels on and gate arrival in minutes';

COMMENT ON COLUMN gold.fct_flights.wheels_off IS
'Time wheels left the ground in HHMM format';

COMMENT ON COLUMN gold.fct_flights.wheels_on IS
'Time wheels touched the ground in HHMM format';

COMMENT ON COLUMN gold.fct_flights.distance IS
'Distance in miles between origin and destination airports';

COMMENT ON COLUMN gold.fct_flights.air_system_delay IS
'Minutes of delay attributed to the National Air System';

COMMENT ON COLUMN gold.fct_flights.security_delay IS
'Minutes of delay attributed to security screening';

COMMENT ON COLUMN gold.fct_flights.airline_delay IS
'Minutes of delay attributed to the airline';

COMMENT ON COLUMN gold.fct_flights.late_aircraft_delay IS
'Minutes of delay caused by a late arriving aircraft';

COMMENT ON COLUMN gold.fct_flights.weather_delay IS
'Minutes of delay attributed to weather conditions';

COMMENT ON COLUMN gold.fct_flights.is_cancelled IS
'1 if the flight was cancelled, 0 otherwise';

COMMENT ON COLUMN gold.fct_flights.is_diverted IS
'1 if the flight was diverted, 0 otherwise';

COMMENT ON COLUMN gold.fct_flights.created_at IS
'Timestamp when the record was created';

COMMENT ON COLUMN gold.fct_flights.updated_at IS
'Timestamp when the record was last updated';
