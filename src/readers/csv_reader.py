from pathlib import Path

import polars as pl


class CsvReader:
    @staticmethod
    def read(file_path: Path) -> pl.DataFrame:
        return pl.read_csv(file_path, infer_schema_length=10000)
