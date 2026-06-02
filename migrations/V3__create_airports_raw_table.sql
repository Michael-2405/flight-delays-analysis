-- Script Name: V3__create_airports_raw_table.sql
-- Description: Creates the airports raw table, this table get loaded
--              from a CSV thru a python script. It saves the airports
--              information.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE TABLE If NOT EXISTS bronze.airports_raw (
  iata_code     VARCHAR(10)         NOT NULL,
  airport       VARCHAR(200)        NOT NULL,
  city          VARCHAR(100)        NULL,
  state         VARCHAR(100)        NULL,
  country       VARCHAR(100)        NULL,
  latitude      DECIMAL(10, 6)      NULL,
  longitude     DECIMAL(10, 6)      NULL,
  source_file   VARCHAR(100)        NOT NULL,
  loaded_at     TIMESTAMP           NOT NULL DEFAULT NOW()
);
