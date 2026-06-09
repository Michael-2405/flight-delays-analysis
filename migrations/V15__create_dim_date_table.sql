-- =============================================================
-- Script Name: V15__create_dim_date_table.sql
-- Description: Creates gold.dim_date — calendar dimension covering
--              2014-01-01 to 2030-12-31. date_id uses YYYYMMDD
--              integer format (e.g. 20150115). Not IDENTITY — values
--              are controlled programmatically by usp_load_gold_dim_date.
--              Populated via generate_series, idempotent INSERT.
-- Schema:      gold
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version
-- =============================================================

CREATE TABLE IF NOT EXISTS gold.dim_date (
  date_id          INT         NOT NULL,
  full_date        DATE        NOT NULL,
  year             SMALLINT    NOT NULL,
  month            SMALLINT    NOT NULL,
  month_name       VARCHAR(20) NOT NULL,
  month_name_short CHAR(3)     NOT NULL,
  day              SMALLINT    NOT NULL,
  day_of_week      SMALLINT    NOT NULL,
  day_of_week_name  VARCHAR(20) NOT NULL,
  day_of_week_short CHAR(3)    NOT NULL,
  quarter          SMALLINT    NOT NULL,
  semester         SMALLINT    NOT NULL,
  is_weekend       SMALLINT    NOT NULL,
  is_holiday       SMALLINT    NOT NULL,
  created_at       TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMP   NULL,

  CONSTRAINT pk_dim_date PRIMARY KEY (date_id)
);

COMMENT ON TABLE gold.dim_date IS
'Calendar dimension for the star schema. Covers 2014-01-01 to 2030-12-31.';
COMMENT ON COLUMN gold.dim_date.date_id IS
'Date in YYYYMMDD integer format (e.g. 20150115).';
COMMENT ON COLUMN gold.dim_date.full_date IS
'Full date value (e.g. 2015-01-15).';
COMMENT ON COLUMN gold.dim_date.year IS
'Calendar year.';
COMMENT ON COLUMN gold.dim_date.month IS
'Calendar month number (1-12).';
COMMENT ON COLUMN gold.dim_date.month_name IS
'Full month name (e.g. January).';
COMMENT ON COLUMN gold.dim_date.month_name_short IS
'Abbreviated month name (e.g. Jan).';
COMMENT ON COLUMN gold.dim_date.day IS
'Day of the month (1-31).';
COMMENT ON COLUMN gold.dim_date.day_of_week IS
'Day of the week (1=Monday, 7=Sunday).';
COMMENT ON COLUMN gold.dim_date.day_of_week_name IS
'Full day name (e.g. Monday).';
COMMENT ON COLUMN gold.dim_date.day_of_week_short IS
'Abbreviated day name (e.g. Mon).';
COMMENT ON COLUMN gold.dim_date.quarter IS
'Quarter of the year (1-4).';
COMMENT ON COLUMN gold.dim_date.semester IS
'Semester of the year (1-2).';
COMMENT ON COLUMN gold.dim_date.is_weekend IS
'1 if Saturday or Sunday, 0 otherwise.';
COMMENT ON COLUMN gold.dim_date.is_holiday IS
'1 if US federal holiday, 0 otherwise.';
COMMENT ON COLUMN gold.dim_date.created_at IS
'Timestamp when the record was created.';
COMMENT ON COLUMN gold.dim_date.updated_at IS
'Timestamp of the last update to the record.';
