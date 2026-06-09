-- =============================================================
-- Script Name: V6__create_ufn_log_start_etl.sql
-- Description: Creates etl.ufn_log_start_etl — function that
--              inserts a new execution record in etl.etl_log
--              with status RUNNING and returns the generated
--              etl_log_id for use in success/error procedures.
-- Schema:      etl
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

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
