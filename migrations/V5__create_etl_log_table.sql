-- Script Name: V5__create_etl_log_table.sql
-- Description: Creates the log etl table. This table stores information
--              about the etl process executions, to see if it failed, succeeded,
--              who ran it, who updated it, how many rows where affected, etc.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE TABLE If NOT EXISTS etl.etl_log (
  etl_log_id        INT           GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  etl_name          VARCHAR(100)  NOT NULL,
  etl_start         TIMESTAMP     NOT NULL DEFAULT NOW(),
  etl_finish        TIMESTAMP     NULL ,
  etl_rows_written  INT           NULL,
  etl_rows_updated  INT           NULL,
  etl_rows_read     INT           NULL,
  etl_rows_deleted  INT           NULL,
  etl_status        VARCHAR(50),
  etl_error_code    INT           NULL,
  etl_error_message TEXT,
  etl_ran_by        TEXT          NOT NULL DEFAULT CURRENT_USER
);
