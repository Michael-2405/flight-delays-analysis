-- Script Name: V1__create_schemas.sql
-- Description: Creates the database and projects schemas. First it validates
--              that the schemas don't already exists. Which in the given case
--              case they do, then it doesn't create them.
-- Author:      Michael Espinosa
-- Change Log:  First Version 01-06-2026

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS etl;
