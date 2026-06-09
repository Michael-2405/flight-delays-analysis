-- =============================================================
-- Script Name: V8__create_usp_log_error_etl.sql
-- Description: Creates etl.usp_log_error_etl — procedure that
--              updates an existing etl_log record as FAILED,
--              sets etl_finish using clock_timestamp() and stores
--              the SQL error code and message for diagnostics.
-- Schema:      etl
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

CREATE OR REPLACE PROCEDURE etl.usp_log_error_etl(
  p_etl_log_id    INT,
  p_error_code    INT,
  p_error_message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE etl.etl_log
  SET
    etl_finish        = CLOCK_TIMESTAMP(),
    etl_status        = 'FAILED',
    etl_error_code    = p_error_code,
    etl_error_message = p_error_message
  WHERE etl_log_id = p_etl_log_id;
END;
$$;
