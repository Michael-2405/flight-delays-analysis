-- Script Name: V17__create_dim_airport_table.sql
-- Description: Creates the dim_airport table in the gold schema.
--              This dimension stores de information of airports. Ready for use
--              in the star schema.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

CREATE TABLE IF NOT EXISTS gold.dim_airport(
  airport_id    INT               NOT NULL GENERATED ALWAYS AS IDENTITY,
  iata_code     VARCHAR(10)       NOT NULL,
  airport_name  VARCHAR(200)      NOT NULL,
  city          VARCHAR(100)      NULL,
  state         VARCHAR(100)      NULL,
  country       VARCHAR(100)      NULL,
  latitude      DECIMAL(10, 6)    NULL,
  longitude     DECIMAL(10, 6)    NULL,
  timezone      TEXT              NULL,
  created_at    TIMESTAMP         NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP         NULL,

  CONSTRAINT pk_dim_airport PRIMARY KEY (airport_id),
  CONSTRAINT uq_dim_airport_iata_code UNIQUE (iata_code)
);

COMMENT ON TABLE gold.dim_airport IS
'Airports operating US domestic flights in 2015.';

COMMENT ON COLUMN gold.dim_airport.airport_id IS
'Surrogate key.';

COMMENT ON COLUMN gold.dim_airport.iata_code IS
'IATA 3-letter code identifying the airport.';

COMMENT ON COLUMN gold.dim_airport.airport_name IS
'Full name of the airport.';

COMMENT ON COLUMN gold.dim_airport.city IS
'City where the airport is located.';

COMMENT ON COLUMN gold.dim_airport.state IS
'US state where the airport is located.';

COMMENT ON COLUMN gold.dim_airport.country IS
'Country where the airport is located.';

COMMENT ON COLUMN gold.dim_airport.latitude IS
'Geographic latitude coordinate.';

COMMENT ON COLUMN gold.dim_airport.longitude IS
'Geographic longitude coordinate.';

COMMENT ON COLUMN gold.dim_airport.timezone IS
'Timezone (e.g. America/New_York).';

COMMENT ON COLUMN gold.dim_airport.created_at IS
'Timestamp of when the record was created';

COMMENT ON COLUMN gold.dim_airport.updated_at IS
'Timestamp of the last update of the record.';
