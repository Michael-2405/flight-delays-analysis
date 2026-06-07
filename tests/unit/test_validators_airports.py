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
    def test_valid_dataframe_passes(self):
        df = valid_airports_df()
        airports_schema.validate(df)

    def test_valid_dataframe_with_null_coordinates_passes(self):
        df = valid_airports_df().with_columns(
            [
                pl.lit(None).cast(pl.Float64).alias("LATITUDE"),
                pl.lit(None).cast(pl.Float64).alias("LONGITUDE"),
            ]
        )
        airports_schema.validate(df)

    def test_rejects_missing_iata_code_column(self):
        df = valid_airports_df().drop("IATA_CODE")
        with pytest.raises(Exception):
            airports_schema.validate(df)

    def test_rejects_missing_airport_column(self):
        df = valid_airports_df().drop("AIRPORT")
        with pytest.raises(Exception):
            airports_schema.validate(df)

    def test_rejects_missing_latitude_column(self):
        df = valid_airports_df().drop("LATITUDE")
        with pytest.raises(Exception):
            airports_schema.validate(df)

    def test_rejects_extra_column(self):
        df = valid_airports_df().with_columns(pl.lit("extra").alias("EXTRA_COLUMN"))
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
