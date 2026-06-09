from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airlines_repository import AirlineRepository
from readers.csv_reader import CsvReader
from validators.airlines_schema import airlines_schema


class AirlinePipeline:
    """Pipeline for loading airlines.csv into bronze.airlines_raw.

    Truncate + full load strategy.
    """

    def run(self, file_path: Path) -> int:
        """Read, validate and load airlines data into bronze.

        Args:
            file_path: Path to airlines.csv.

        Returns:
            Number of rows loaded.
        """
        logger.info("Loading airlines")
        df = CsvReader.read(file_path)
        airlines_schema.validate(df)
        rows = [
            {col.lower(): val for col, val in row.items()}
            | {
                "source_file": str(file_path.name),
                "loaded_at": datetime.now(),
            }
            for row in df.to_dicts()
        ]
        repo = AirlineRepository()
        repo.truncate()
        repo.insert(rows)
        logger.success("Airlines loaded")
        return len(rows)
