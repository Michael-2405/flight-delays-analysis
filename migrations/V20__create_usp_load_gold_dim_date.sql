-- Script Name: V20__create_usp_load_gold_dim_date.sql
-- Description: Creates the stored procedure that generates and loads
--              gold.dim_date programmatically using generate_series.
--              Covers all 365 days of 2015 with calendar attributes,
--              US federal holidays and weekend flags.
--              Truncate + full load strategy.
--              Logs execution to etl.etl_log.
-- Author:      Michael Espinosa
-- Date:        2026-06-06
-- Change Log:
--   2026-06-06 | Michael Espinosa | Initial version

CREATE OR REPLACE PROCEDURE gold.usp_load_gold_dim_date()
LANGUAGE plpgsql
AS $$
DECLARE
  v_log_id INT;
  v_rows   INT;
BEGIN
  v_log_id := etl.ufn_log_start_etl('usp_load_gold_dim_date');
  RAISE NOTICE '[START] usp_load_gold_dim_date';

  INSERT INTO gold.dim_date(
    date_id,
    full_date,
    year,
    month,
    month_name,
    month_name_short,
    day,
    day_of_week,
    day_of_week_name,
    day_of_week_short,
    quarter,
    semester,
    is_weekend,
    is_holiday,
    created_at,
    updated_at
  )
  SELECT
    EXTRACT(YEAR FROM full_date)::INT * 10000
    + EXTRACT(MONTH FROM full_date)::INT * 100
    + EXTRACT(DAY FROM full_date)::INT          AS date_id,
    full_date::DATE                             AS full_date,
    EXTRACT(YEAR  FROM full_date)               AS year,
    EXTRACT(MONTH FROM full_date)               AS month,
    TO_CHAR(full_date, 'Month')                 AS month_name,
    TO_CHAR(full_date, 'Mon')                   AS month_name_short,
    EXTRACT(DAY   FROM full_date)               AS day,
    EXTRACT(ISODOW FROM full_date)::SMALLINT    AS day_of_week,
    TO_CHAR(full_date, 'FMDay')                 AS day_of_week_name,
    TO_CHAR(full_date, 'Dy')                    AS day_of_week_short,
    EXTRACT(QUARTER FROM full_date)::SMALLINT   AS quarter,
    CASE
      WHEN EXTRACT(MONTH FROM full_date) <= 6 THEN 1
      ELSE 2
    END AS semester,
    CASE
      WHEN EXTRACT(ISODOW FROM full_date) IN (6, 7)
      THEN 1
      ELSE 0
    END AS is_weekend,
    CASE
      WHEN full_date IN (
        '2015-01-01', '2015-01-19', '2015-02-16', '2015-05-25',
        '2015-07-03', '2015-09-07', '2015-10-12', '2015-11-11',
        '2015-11-26', '2015-12-25'
      )
      THEN 1
      ELSE 0
    END AS is_holiday,
    NOW()                                       AS created_at,
    NULL::TIMESTAMP                             AS updated_at
  FROM GENERATE_SERIES(
    '2014-01-01'::DATE,
    '2016-12-31'::DATE,
    '1 day'::INTERVAL
  ) AS full_date
  WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_date d
    WHERE d.date_id = (
        EXTRACT(YEAR FROM full_date)::INT * 10000
        + EXTRACT(MONTH FROM full_date)::INT * 100
        + EXTRACT(DAY FROM full_date)::INT
    )
  );

  GET DIAGNOSTICS v_rows = ROW_COUNT;
  RAISE NOTICE '[SUCCESS] Rows written: %', v_rows;

  CALL etl.usp_log_success_etl(
      p_etl_log_id   := v_log_id,
      p_rows_written := v_rows,
      p_rows_read    := v_rows
  );

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '[ERROR] %', SQLERRM;
    CALL etl.usp_log_error_etl(
        p_etl_log_id    := v_log_id,
        p_error_code    := 0,
        p_error_message := SQLERRM
    );
    RAISE;
END;
$$;
