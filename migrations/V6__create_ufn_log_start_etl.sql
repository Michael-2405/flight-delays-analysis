-- Script Name: V6__create_ufn_log_start_etl.sql
-- Description: Creates the function that registers the start of an ETL
--              execution in the etl_log table and returns the generated
--              etl_log_id for tracking the execution lifecycle.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE OR REPLACE FUNCTION etl.ufn_log_start_etl(
  p_etl_name VARCHAR(100)
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
  v_etl_log_id INT;
BEGIN
  INSERT INTO etl.etl_log (
    etl_name,
    etl_start,
    etl_status
  )
  VALUES (
    p_etl_name,
    NOW(),
    'RUNNING'
  )
  RETURNING etl_log_id INTO v_etl_log_id;

  RETURN v_etl_log_id;
END;
$$;
