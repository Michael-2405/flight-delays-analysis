"""Unit tests for the airlines Pandera schema validator.

Validates that airlines_schema correctly accepts well-formed data
and rejects malformed DataFrames with missing columns, extra columns,
null values and incorrect types.
"""

import polars as pl
import pytest

from validators.airlines_schema import airlines_schema


def valid_airlines_df() -> pl.DataFrame:
    return pl.DataFrame(
        {
            "IATA_CODE": ["AA", "UA"],
            "AIRLINE": ["American Airlines", "United Airlines"],
        }
    )


class TestAirlinesSchema:
    """Tests for airlines_schema validator."""

    def test_valid_dataframe_passes(self):
        airlines_schema.validate(valid_airlines_df())

    def test_rejects_missing_iata_code_column(self):
        df = pl.DataFrame({"AIRLINE": ["American Airlines"]})
        with pytest.raises(Exception):
            airlines_schema.validate(df)

    def test_rejects_missing_airline_column(self):
        df = pl.DataFrame({"IATA_CODE": ["AA"]})
        with pytest.raises(Exception):
            airlines_schema.validate(df)

    def test_rejects_extra_column(self):
        df = valid_airlines_df().with_columns(pl.lit("extra").alias("EXTRA"))
        with pytest.raises(Exception):
            airlines_schema.validate(df)

    def test_rejects_null_iata_code(self):
        df = pl.DataFrame(
            {
                "IATA_CODE": [None, "UA"],
                "AIRLINE": ["American Airlines", "United Airlines"],
            }
        )
        with pytest.raises(Exception):
            airlines_schema.validate(df)

    def test_rejects_null_airline(self):
        df = pl.DataFrame(
            {
                "IATA_CODE": ["AA", "UA"],
                "AIRLINE": [None, "United Airlines"],
            }
        )
        with pytest.raises(Exception):
            airlines_schema.validate(df)

    def test_rejects_wrong_type_iata_code(self):
        df = pl.DataFrame(
            {
                "IATA_CODE": [1, 2],
                "AIRLINE": ["American Airlines", "United Airlines"],
            }
        )
        with pytest.raises(Exception):
            airlines_schema.validate(df)
