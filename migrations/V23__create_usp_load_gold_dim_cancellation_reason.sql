-- =============================================================
-- Script Name: V23__create_usp_load_gold_dim_cancellation_reason.sql
-- Description: Creates gold.usp_load_gold_dim_cancellation_reason —
--              loads gold.dim_cancellation_reason with seed data.
--              Four static cancellation codes: A, B, C, D.
--              UPSERT strategy — safe to re-run.
--              Logs execution to etl.etl_log.
-- Schema:      gold
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
-- =============================================================

CREATE OR REPLACE PROCEDURE gold.usp_load_gold_dim_cancellation_reason()
LANGUAGE plpgsql
AS $$
DECLARE
    v_log_id INT;
    v_rows   INT;
BEGIN
    v_log_id := etl.ufn_log_start_etl('usp_load_gold_cancellation_reason');
    RAISE NOTICE '[START] usp_load_gold_cancellation_reason';

    INSERT INTO gold.dim_cancellation_reason(
        cancellation_code, code_description, created_at, updated_at
    )
    VALUES
        ('A', 'Carrier',                   NOW(), NULL),
        ('B', 'Weather',                   NOW(), NULL),
        ('C', 'National Air System (NAS)', NOW(), NULL),
        ('D', 'Security',                  NOW(), NULL)
    ON CONFLICT (cancellation_code) DO UPDATE SET
        code_description = EXCLUDED.code_description,
        updated_at       = NOW();

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE '[SUCCESS] Rows written: %', v_rows;

    CALL etl.usp_log_success_etl(
        p_etl_log_id   := v_log_id,
        p_rows_written := v_rows,
        p_rows_read    := NULL
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
