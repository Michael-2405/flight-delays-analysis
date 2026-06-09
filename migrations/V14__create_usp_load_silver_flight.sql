-- =============================================================
-- Script Name: V14__create_usp_load_silver_flight.sql
-- Description: Creates silver.usp_load_silver_flight — loads
--              silver.flight_clean from bronze.flights_raw.
--              Derives full_date (DATE) and date_id (YYYYMMDD INT).
--              Translates DOT numeric airport codes to IATA codes
--              using etl.airport_dot_iata_map via COALESCE.
--              Truncate + full load strategy.
--              Logs execution to etl.etl_log.
-- Schema:      silver
-- Author:      Michael Espinosa
-- Date:        2026-06-05
-- Change Log:
--   2026-06-05 | Michael Espinosa | Initial version
--   2026-06-06 | Michael Espinosa | Add DOT→IATA translation via airport_dot_iata_map
-- =============================================================

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
        f.year,
        f.month,
        f.day,
        f.day_of_week,
        MAKE_DATE(f.year::int, f.month::int, f.day::int) AS full_date,
        f.year * 10000 + f.month * 100 + f.day          AS date_id,
        f.airline,
        f.flight_number,
        f.tail_number,
        COALESCE(m_orig.iata_code, f.origin_airport)      AS origin_airport,
        COALESCE(m_dest.iata_code, f.destination_airport) AS destination_airport,
        f.scheduled_departure,
        f.departure_time,
        f.departure_delay,
        f.taxi_out,
        f.wheels_off,
        f.scheduled_time,
        f.elapsed_time,
        f.air_time,
        f.distance,
        f.wheels_on,
        f.taxi_in,
        f.scheduled_arrival,
        f.arrival_time,
        f.arrival_delay,
        f.diverted,
        f.cancelled,
        f.cancellation_reason,
        f.air_system_delay,
        f.security_delay,
        f.airline_delay,
        f.late_aircraft_delay,
        f.weather_delay,
        NOW()
    FROM bronze.flights_raw f
    LEFT JOIN etl.airport_dot_iata_map m_orig
        ON CASE WHEN f.origin_airport ~ '^\d+$'
           THEN f.origin_airport::INT
           ELSE NULL END = m_orig.dot_code
    LEFT JOIN etl.airport_dot_iata_map m_dest
        ON CASE WHEN f.destination_airport ~ '^\d+$'
           THEN f.destination_airport::INT
           ELSE NULL END = m_dest.dot_code;

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
