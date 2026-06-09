-- =============================================================
-- Script Name: V9__create_airline_clean_table.sql
-- Description: Creates silver.airline_clean — cleaned airline data
--              loaded from bronze.airlines_raw via stored procedure.
--              Renames airline → airline_name for consistency.
--              Load strategy: truncate + full load.
-- Schema:      silver
-- Author:      Michael Espinosa
-- Date:        2026-06-05
-- Change Log:
--   2026-06-05 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS silver.airline_clean (
  iata_code    VARCHAR(10)  NOT NULL,
  airline_name VARCHAR(100) NOT NULL,
  created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMP    NULL
);
