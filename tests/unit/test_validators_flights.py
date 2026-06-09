"""Unit tests for the flights Pandera schema validator.

Validates that flights_schema correctly accepts well-formed data
and rejects malformed DataFrames with missing columns, extra columns
and incorrect types for key flight fields.
"""

import polars as pl
import pytest

from validators.flights_schema import flights_schema


def valid_flights_df() -> pl.DataFrame:
    return pl.DataFrame(
        {
            "YEAR": [2015, 2015],
            "MONTH": [1, 1],
            "DAY": [1, 1],
            "DAY_OF_WEEK": [4, 4],
            "AIRLINE": ["AA", "UA"],
            "FLIGHT_NUMBER": [100, 200],
            "TAIL_NUMBER": ["N123AA", "N456UA"],
        }
    )


class TestFlightsSchema:
    """Tests for flights_schema validator."""

    def test_valid_dataframe_passes(self):
        flights_schema.validate(valid_flights_df())

    def test_rejects_missing_year_column(self):
        with pytest.raises(Exception):
            flights_schema.validate(valid_flights_df().drop("YEAR"))

    def test_rejects_missing_airline_column(self):
        with pytest.raises(Exception):
            flights_schema.validate(valid_flights_df().drop("AIRLINE"))

    def test_rejects_missing_flight_number_column(self):
        with pytest.raises(Exception):
            flights_schema.validate(valid_flights_df().drop("FLIGHT_NUMBER"))

    def test_rejects_extra_column(self):
        df = valid_flights_df().with_columns(pl.lit("extra").alias("EXTRA"))
        with pytest.raises(Exception):
            flights_schema.validate(df)

    def test_rejects_wrong_type_year(self):
        df = valid_flights_df().with_columns(pl.Series("YEAR", ["2015", "2015"]))
        with pytest.raises(Exception):
            flights_schema.validate(df)

    def test_rejects_wrong_type_flight_number(self):
        df = valid_flights_df().with_columns(pl.Series("FLIGHT_NUMBER", ["100", "200"]))
        with pytest.raises(Exception):
            flights_schema.validate(df)
