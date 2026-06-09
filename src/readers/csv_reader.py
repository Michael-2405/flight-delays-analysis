from pathlib import Path

import polars as pl


class CsvReader:
    """Utility class for reading CSV files into Polars DataFrames."""

    @staticmethod
    def read(file_path: Path, encoding: str = "utf8") -> pl.DataFrame:
        """Read a CSV file into a Polars DataFrame.

        Args:
            file_path: Path to the CSV file to read.
            encoding: File encoding. Defaults to "utf8". Use "latin1"
                for BTS government files (L_AIRPORT_ID.csv, L_AIRPORT.csv).

        Returns:
            Polars DataFrame with inferred schema (10,000 row sample).
        """
        return pl.read_csv(file_path, infer_schema_length=10000, encoding=encoding)
