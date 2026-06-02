-- Script Name: V2__create_airlines_raw_table.sql
-- Description: Creates the airlines raw tables, this table get loaded
--              from a CSV thru a python script. It saves the IATA_CODE,
--              AIRLINE information.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE TABLE If NOT EXISTS bronze.airlines_raw (
  iata_code   VARCHAR(10)     NOT NULL,
  airline     VARCHAR(100)    NOT NULL,
  source_file VARCHAR(100)    NOT NULL,
  loaded_at   TIMESTAMP       NOT NULL DEFAULT NOW()
);
