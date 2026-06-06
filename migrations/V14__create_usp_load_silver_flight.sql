-- Script Name: V14_create_usp_load_silver_flight.sql
-- Description: Creates the stored procedure that loads silver.flight_clean
--              from bronze.flights_raw. Truncate + full load strategy.
--              Logs execution start, success and errors to etl.etl_log.
-- Author:      Michael Espinosa
-- Date:        2026-06-05
-- Change Log:
--   2026-06-05 | Michael Espinosa | Initial version

CREATE OR REPLACE PROCEDURE silver.usp_load_silver_flight()
LANGUAGE plpgsql
AS $$
DECLARE
    v_log_id INT;
    v_rows   INT;
BEGIN
  v_log_id := etl.ufn_log_start_etl('usp_load_silver_flight');
  RAISE NOTICE '[START] usp_load_silver_flight';

  TRUNCATE TABLE silver.flight_clean;

  INSERT INTO silver.flight_clean(
    year, month, day, day_of_week, full_date, date_id, airline, flight_number,
    tail_number, origin_airport, destination_airport, scheduled_departure,
    departure_time, departure_delay, taxi_out, wheels_off, scheduled_time,
    elapsed_time, air_time, distance, wheels_on, taxi_in, scheduled_arrival,
    arrival_time, arrival_delay, diverted, cancelled, cancellation_reason,
    air_system_delay, security_delay, airline_delay, late_aircraft_delay,
    weather_delay, updated_at
  )

  SELECT
    year, month, day, day_of_week,
    MAKE_DATE (year::int, month::int, day::int) AS full_date,
    year * 10000 + month * 100 + day            AS date_id,
    airline, flight_number, tail_number, origin_airport, destination_airport,
    scheduled_departure, departure_time, departure_delay, taxi_out, wheels_off,
    scheduled_time, elapsed_time, air_time, distance, wheels_on, taxi_in,
    scheduled_arrival, arrival_time, arrival_delay, diverted, cancelled,
    cancellation_reason, air_system_delay, security_delay, airline_delay,
    late_aircraft_delay, weather_delay, NOW()
  FROM bronze.flights_raw;

  GET DIAGNOSTICS v_rows = ROW_COUNT;
  RAISE NOTICE '[SUCCESS] Rows written: %', v_rows;

    CALL etl.usp_log_success_etl(
        p_etl_log_id   := v_log_id,
        p_rows_written := v_rows,
        p_rows_read    := v_rows
    );

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '[ERROR] %', SQLERRM;
    CALL etl.usp_log_error_etl(
        p_etl_log_id    := v_log_id,
        p_error_code    := 0,
        p_error_message := SQLERRM
    );
    RAISE;
END;
$$;
