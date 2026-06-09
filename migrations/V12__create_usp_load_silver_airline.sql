-- =============================================================
-- Script Name: V12__create_usp_load_silver_airline.sql
-- Description: Creates silver.usp_load_silver_airline — loads
--              silver.airline_clean from bronze.airlines_raw.
--              Renames airline → airline_name.
--              Truncate + full load strategy.
--              Logs execution to etl.etl_log.
-- Schema:      silver
-- Author:      Michael Espinosa
-- Date:        2026-06-05
-- Change Log:
--   2026-06-05 | Michael Espinosa | Initial version
-- =============================================================

CREATE OR REPLACE PROCEDURE silver.usp_load_silver_airline()
LANGUAGE plpgsql
AS $$
DECLARE
    v_log_id INT;
    v_rows   INT;
BEGIN
    v_log_id := etl.ufn_log_start_etl('usp_load_silver_airline');
    RAISE NOTICE '[START] usp_load_silver_airline';

    TRUNCATE TABLE silver.airline_clean;

    INSERT INTO silver.airline_clean(iata_code, airline_name, updated_at)
    SELECT iata_code, airline AS airline_name, NOW()
    FROM bronze.airlines_raw;

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
