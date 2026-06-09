-- =============================================================
-- Script Name: V1__create_schemas.sql
-- Description: Creates the four schemas used in the Medallion
--              architecture: bronze (raw), silver (clean),
--              gold (dimensional model) and etl (infrastructure).
--              Uses IF NOT EXISTS to allow idempotent execution.
-- Schema:      bronze, silver, gold, etl
-- Author:      Michael Espinosa
-- Date:        2026-06-01
-- Change Log:
--   2026-06-01 | Michael Espinosa | Initial version
-- =============================================================

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS etl;
