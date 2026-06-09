"""Unit tests for the airports Pandera schema validator.

Validates that airports_schema correctly accepts well-formed data
including NULL coordinates (ECP, PBG, UST), and rejects malformed
DataFrames with missing columns, extra columns, nulls in required
fields and incorrect types.
"""

import polars as pl
import pytest

from validators.airports_schema import airports_schema


def valid_airports_df() -> pl.DataFrame:
    return pl.DataFrame(
        {
            "IATA_CODE": ["ABE", "ABI"],
            "AIRPORT": ["Lehigh Valley International", "Abilene Regional"],
            "CITY": ["Allentown", "Abilene"],
            "STATE": ["PA", "TX"],
            "COUNTRY": ["USA", "USA"],
            "LATITUDE": [40.65, 32.41],
            "LONGITUDE": [-75.44, -99.68],
        }
    )


class TestAirportsSchema:
    """Tests for airports_schema validator."""

    def test_valid_dataframe_passes(self):
        airports_schema.validate(valid_airports_df())

    def test_valid_dataframe_with_null_coordinates_passes(self):
        """NULL coordinates are valid — ECP, PBG, UST have no coordinates."""
        df = valid_airports_df().with_columns(
            [
                pl.lit(None).cast(pl.Float64).alias("LATITUDE"),
                pl.lit(None).cast(pl.Float64).alias("LONGITUDE"),
            ]
        )
        airports_schema.validate(df)

    def test_rejects_missing_iata_code_column(self):
        with pytest.raises(Exception):
            airports_schema.validate(valid_airports_df().drop("IATA_CODE"))

    def test_rejects_missing_airport_column(self):
        with pytest.raises(Exception):
            airports_schema.validate(valid_airports_df().drop("AIRPORT"))

    def test_rejects_missing_latitude_column(self):
        with pytest.raises(Exception):
            airports_schema.validate(valid_airports_df().drop("LATITUDE"))

    def test_rejects_extra_column(self):
        df = valid_airports_df().with_columns(pl.lit("extra").alias("EXTRA"))
        with pytest.raises(Exception):
            airports_schema.validate(df)

    def test_rejects_null_iata_code(self):
        df = valid_airports_df().with_columns(pl.Series("IATA_CODE", [None, "ABI"]))
        with pytest.raises(Exception):
            airports_schema.validate(df)

    def test_rejects_wrong_type_latitude(self):
        df = valid_airports_df().with_columns(
            pl.Series("LATITUDE", ["not_a_float", "also_not"])
        )
        with pytest.raises(Exception):
            airports_schema.validate(df)
