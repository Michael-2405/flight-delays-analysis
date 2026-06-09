-- =============================================================
-- Script Name: V30__create_indexes.sql
-- Description: Creates BTREE indexes on gold.fct_flights to improve
--              query performance for reporting and dashboard queries.
--              Covers the most frequently filtered and grouped columns
--              based on defined business questions: delay analysis by
--              airline, airport, date and cancellation status.
-- Schema:      gold
-- Author:      Michael Espinosa
-- Date:        2026-06-07
-- Change Log:
--   2026-06-07 | Michael Espinosa | Initial version
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_fct_flights_date_id
ON gold.fct_flights (date_id);

CREATE INDEX IF NOT EXISTS idx_fct_flights_airline_id
ON gold.fct_flights (airline_id);

CREATE INDEX IF NOT EXISTS idx_fct_flights_origin_airport_id
ON gold.fct_flights (origin_airport_id);

CREATE INDEX IF NOT EXISTS idx_fct_flights_destination_airport_id
ON gold.fct_flights (destination_airport_id);

CREATE INDEX IF NOT EXISTS idx_fct_flights_is_cancelled
ON gold.fct_flights (is_cancelled);

CREATE INDEX IF NOT EXISTS idx_fct_flights_departure_delay
ON gold.fct_flights (departure_delay);

CREATE INDEX IF NOT EXISTS idx_fct_flights_arrival_delay
ON gold.fct_flights (arrival_delay);
