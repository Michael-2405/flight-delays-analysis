-- Script Name: V7__create_usp_log_success_etl.sql
-- Description: Creates the stored procedure that updates an ETL execution
--              record as successful, setting the finish timestamp and
--              storing execution metrics such as rows read, written,
--              updated, and deleted.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE OR REPLACE PROCEDURE etl.usp_log_success_etl(
  p_etl_log_id INT,
  p_rows_written  INT DEFAULT NULL,
  p_rows_updated  INT DEFAULT NULL,
  p_rows_read   INT DEFAULT NULL,
  p_rows_deleted  INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE etl.etl_log
  SET
    etl_finish       = NOW(),
    etl_status       = 'SUCCESS',
    etl_rows_written = p_rows_written,
    etl_rows_updated = p_rows_updated,
    etl_rows_read    = p_rows_read,
    etl_rows_deleted = p_rows_deleted
  WHERE etl_log_id = p_etl_log_id;
END;
$$;
