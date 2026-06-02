-- Script Name: V8__create_usp_log_error_etl.sql
-- Description: Creates the stored procedure that updates an ETL execution
--              record as failed, setting the finish timestamp and storing
--              the corresponding error code and error message.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE OR REPLACE PROCEDURE etl.usp_log_error_etl(
  p_etl_log_id  INT,
  p_error_code  INT,
  p_error_message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE etl.etl_log
  SET
    etl_finish = NOW(),
    etl_status = 'FAILED',
    etl_error_code = p_error_code,
    etl_error_message = p_error_message
  WHERE etl_log_id = p_etl_log_id;
END;
$$;
