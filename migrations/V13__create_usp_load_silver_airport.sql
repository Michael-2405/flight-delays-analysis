-- Script Name: V13__create_usp_load_silver_airport.sql
-- Description: Creates the stored procedure that loads silver.airport_clean
--              from bronze.airports_raw. Truncate + full load strategy.
--              Logs execution start, success and errors to etl.etl_log.
-- Author:      Michael Espinosa
-- Date:        2026-06-05
-- Change Log:
--   2026-06-05 | Michael Espinosa | Initial version

CREATE OR REPLACE PROCEDURE silver.usp_load_silver_airport()
LANGUAGE plpgsql
AS $$
DECLARE
    v_log_id INT;
    v_rows   INT;
BEGIN
  v_log_id := etl.ufn_log_start_etl('usp_load_silver_airport');
  RAISE NOTICE '[START] usp_load_silver_airport';

  TRUNCATE TABLE silver.airport_clean;

  INSERT INTO silver.airport_clean(
    iata_code, airport_name, city, state,
    country, latitude, longitude, updated_at)
  SELECT
    iata_code, airport AS airport_name, city, state,
    country, latitude, longitude, NOW()
  FROM bronze.airports_raw;

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
