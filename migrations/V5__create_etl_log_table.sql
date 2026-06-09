-- =============================================================
-- Script Name: V5__create_etl_log_table.sql
-- Description: Creates etl.etl_log — execution log for all ETL
--              stored procedures. One row per SP execution.
--              Tracks status, row counts, timestamps and errors.
--              Used by ufn_log_start_etl, usp_log_success_etl
--              and usp_log_error_etl.
-- Schema:      etl
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS etl.etl_log (
  etl_log_id        INT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  etl_name          VARCHAR(100) NOT NULL,
  etl_start         TIMESTAMP    NOT NULL DEFAULT NOW(),
  etl_finish        TIMESTAMP    NULL,
  etl_rows_written  INT          NULL,
  etl_rows_updated  INT          NULL,
  etl_rows_read     INT          NULL,
  etl_rows_deleted  INT          NULL,
  etl_status        VARCHAR(50)  NULL,
  etl_error_code    INT          NULL,
  etl_error_message TEXT         NULL,
  etl_ran_by        TEXT         NOT NULL DEFAULT CURRENT_USER
);
