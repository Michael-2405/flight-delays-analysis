-- Script Name: V9__create_airline_clean_table.sql
-- Description: Creates the airline clean table, this table gets loaded
--              from the airlines_raw table from the bronze schema thru a
--              stored procedure. It saves the airlines information.
-- Author:      Michael Espinosa
-- Change Log:  First Version 05-06-2026

CREATE TABLE If NOT EXISTS silver.airline_clean (
  iata_code     VARCHAR(10)     NOT NULL,
  airline_name  VARCHAR(100)    NOT NULL,
  created_at    TIMESTAMP       NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP       NOT NULL
);
