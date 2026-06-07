-- Script Name: V29__add_fct_flights_unique_constraint.sql
-- Description: Adds a unique constraint to gold.fct_flights to prevent
--              duplicate flights on re-runs. Natural key is:
--              date_id + airline_id + flight_number +
--              origin_airport_id + destination_airport_id.
--              Requires airport enrichment to be complete first.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

ALTER TABLE gold.fct_flights
ADD CONSTRAINT uq_fct_flights_natural_key
UNIQUE NULLS NOT DISTINCT (
    date_id,
    airline_id,
    flight_number,
    origin_airport_id,
    destination_airport_id
);
