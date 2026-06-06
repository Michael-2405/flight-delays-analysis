-- Script Name: V18__create_dim_cancellation_reason_table.sql
-- Description: Creates the dim_cancellation_reason table in the gold schema.
--              This dimension stores de information of the reasons for cancellation.
--              Ready for use in the star schema.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

CREATE TABLE IF NOT EXISTS gold.dim_cancellation_reason(
  cancellation_reason_id    INT           NOT NULL GENERATED ALWAYS AS IDENTITY,
  cancellation_code         CHAR(1)       NOT NULL,
  code_description          VARCHAR(50)   NOT NULL,
  created_at                TIMESTAMP     NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMP     NULL,

  CONSTRAINT pk_dim_cancellation_reason PRIMARY KEY (cancellation_reason_id),
  CONSTRAINT uq_dim_cancellation_reason_cancellation_code UNIQUE (cancellation_code)
);

COMMENT ON TABLE gold.dim_cancellation_reason IS
'Cancellation codes for flights.';

COMMENT ON COLUMN gold.dim_cancellation_reason.cancellation_reason_id IS
'Surrogate key.';

COMMENT ON COLUMN gold.dim_cancellation_reason.cancellation_code IS
'Single-letter code: A, B, C, or D.';

COMMENT ON COLUMN gold.dim_cancellation_reason.code_description IS
'Full description of the cancellation reason.';

COMMENT ON COLUMN gold.dim_cancellation_reason.created_at IS
'Timestamp of when the record was created.';

COMMENT ON COLUMN gold.dim_cancellation_reason.updated_at IS
'Timestamp of the last update of the record.';
