-- Script Name: V24__create_usp_load_gold_fct_flights.sql
-- Description: Creates the stored procedure that loads gold.fct_flights
--              from silver.flight_clean. Joins to all gold dimensions
--              to resolve surrogate keys. Incremental INSERT strategy —
--              skips duplicates using ON CONFLICT DO NOTHING on natural key
--              (date_id, airline_id, flight_number, origin_airport_id,
--              destination_airport_id).
--              Logs execution start, success and errors to etl.etl_log.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
--   2026-06-06 | Michael Espinosa | Add ON CONFLICT DO NOTHING to prevent duplicates

CREATE OR REPLACE PROCEDURE gold.usp_load_gold_fct_flights()
LANGUAGE plpgsql
AS $$
DECLARE
    v_log_id INT;
    v_rows   INT;
BEGIN
    v_log_id := etl.ufn_log_start_etl('usp_load_gold_fct_flights');
    RAISE NOTICE '[START] usp_load_gold_fct_flights';

    INSERT INTO gold.fct_flights(
        date_id,
        airline_id,
        origin_airport_id,
        destination_airport_id,
        cancellation_reason_id,
        tail_number,
        flight_number,
        scheduled_departure,
        departure_time,
        departure_delay,
        scheduled_arrival,
        arrival_time,
        arrival_delay,
        scheduled_time,
        elapsed_time,
        air_time,
        taxi_out,
        taxi_in,
        wheels_off,
        wheels_on,
        distance,
        air_system_delay,
        security_delay,
        airline_delay,
        late_aircraft_delay,
        weather_delay,
        is_cancelled,
        is_diverted,
        created_at,
        updated_at
    )
    SELECT
        f.date_id,
        a.airline_id,
        orig.airport_id         AS origin_airport_id,
        dest.airport_id         AS destination_airport_id,
        cr.cancellation_reason_id,
        f.tail_number,
        f.flight_number,
        f.scheduled_departure,
        f.departure_time,
        f.departure_delay,
        f.scheduled_arrival,
        f.arrival_time,
        f.arrival_delay,
        f.scheduled_time,
        f.elapsed_time,
        f.air_time,
        f.taxi_out,
        f.taxi_in,
        f.wheels_off,
        f.wheels_on,
        f.distance,
        f.air_system_delay,
        f.security_delay,
        f.airline_delay,
        f.late_aircraft_delay,
        f.weather_delay,
        f.cancelled             AS is_cancelled,
        f.diverted              AS is_diverted,
        NOW()                   AS created_at,
        NULL::TIMESTAMP         AS updated_at
    FROM silver.flight_clean f
    LEFT JOIN gold.dim_airline a
        ON f.airline = a.iata_code
    LEFT JOIN gold.dim_airport orig
        ON f.origin_airport = orig.iata_code
    LEFT JOIN gold.dim_airport dest
        ON f.destination_airport = dest.iata_code
    LEFT JOIN gold.dim_cancellation_reason cr
        ON f.cancellation_reason = cr.cancellation_code
    ON CONFLICT (date_id, airline_id, flight_number, origin_airport_id, destination_airport_id)
    DO NOTHING;

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
