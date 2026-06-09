from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airports_repository import AirportRepository
from readers.csv_reader import CsvReader
from validators.airports_schema import airports_schema


class AirportPipeline:
    """Pipeline for loading airports.csv into bronze.airports_raw.

    Truncate + full load strategy.
    """

    def run(self, file_path: Path) -> int:
        """Read, validate and load airports data into bronze.

        Args:
            file_path: Path to airports.csv.

        Returns:
            Number of rows loaded.
        """
        logger.info("Loading airports")
        df = CsvReader.read(file_path)
        airports_schema.validate(df)
        rows = [
            {col.lower(): val for col, val in row.items()}
            | {
                "source_file": str(file_path.name),
                "loaded_at": datetime.now(),
            }
            for row in df.to_dicts()
        ]
        repo = AirportRepository()
        repo.truncate()
        repo.insert(rows)
        logger.success("Airports loaded")
        return len(rows)
