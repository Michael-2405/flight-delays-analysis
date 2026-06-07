from pathlib import Path

import polars as pl


class CsvReader:
    @staticmethod
    def read(file_path: Path, encoding: str = "utf8") -> pl.DataFrame:
        return pl.read_csv(file_path, infer_schema_length=10000, encoding=encoding)
