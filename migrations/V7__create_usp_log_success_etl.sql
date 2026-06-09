-- =============================================================
-- Script Name: V7__create_usp_log_success_etl.sql
-- Description: Creates etl.usp_log_success_etl — procedure that
--              updates an existing etl_log record as SUCCESS,
--              sets etl_finish using clock_timestamp() for accurate
--              duration tracking, and stores row count metrics.
-- Schema:      etl
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

CREATE OR REPLACE PROCEDURE etl.usp_log_success_etl(
  p_etl_log_id   INT,
  p_rows_written INT DEFAULT NULL,
  p_rows_updated INT DEFAULT NULL,
  p_rows_read    INT DEFAULT NULL,
  p_rows_deleted INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE etl.etl_log
  SET
    etl_finish       = CLOCK_TIMESTAMP(),
    etl_status       = 'SUCCESS',
    etl_rows_written = p_rows_written,
    etl_rows_updated = p_rows_updated,
    etl_rows_read    = p_rows_read,
    etl_rows_deleted = p_rows_deleted
  WHERE etl_log_id = p_etl_log_id;
END;
$$;
