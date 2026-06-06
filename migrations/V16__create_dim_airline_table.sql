-- Script Name: V16__create_dim_airline_table.sql
-- Description: Creates the dim_airline table in the gold schema.
--              This dimension stores de information of airlines. Ready for use
--              in the star schema.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

CREATE TABLE IF NOT EXISTS gold.dim_airline(
  airline_id    INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
  iata_code     VARCHAR(10)   NOT NULL,
  airline_name  VARCHAR(100)  NOT NULL,
  created_at    TIMESTAMP     NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP     NULL,

  CONSTRAINT pk_dim_airline PRIMARY KEY (airline_id)
);

COMMENT ON TABLE gold.dim_airline IS
'Airlines operating US domestic flights in 2015.';

COMMENT ON COLUMN gold.dim_airline.airline_id IS
'Surrogate key.';

COMMENT ON COLUMN gold.dim_airline.iata_code IS
'IATA 2-letter code identifying the airline.';

COMMENT ON COLUMN gold.dim_airline.airline_name IS
'Full name of the airline.';

COMMENT ON COLUMN gold.dim_airline.created_at IS
'Timestamp of when the record was created.';

COMMENT ON COLUMN gold.dim_airline.updated_at IS
'Timestamp of the last update of the record.';
