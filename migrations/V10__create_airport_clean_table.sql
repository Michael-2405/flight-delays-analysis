-- Script Name: V10__create_airport_clean_table.sql
-- Description: Creates the airport clean table, this table get loaded
--              from the airports_raw table from the bronze schema thru a
--              stored procedure. It saves the airports information.
-- Author:      Michael Espinosa
-- Change Log:  First Version 05-06-2026

CREATE TABLE If NOT EXISTS silver.airport_clean (
  iata_code       VARCHAR(10)     NOT NULL,
  airport_name    VARCHAR(200)    NOT NULL,
  city            VARCHAR(100)    NULL,
  state           VARCHAR(100)    NULL,
  country         VARCHAR(100)    NULL,
  latitude        DECIMAL(10, 6)  NULL,
  longitude       DECIMAL(10, 6)  NULL,
  created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP       NOT NULL
);
