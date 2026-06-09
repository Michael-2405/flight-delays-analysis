from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airport_id_repository import AirportIdRepository
from readers.csv_reader import CsvReader
from validators.airport_id_schema import airport_id_schema


class AirportIdPipeline:
    """Pipeline for loading L_AIRPORT_ID.csv into bronze.airport_id_raw.

    Source file uses latin1 encoding (BTS government file).
    Truncate + full load strategy.
    """

    def run(self, file_path: Path) -> int:
        """Read, validate and load BTS DOT airport ID data into bronze.

        Args:
            file_path: Path to L_AIRPORT_ID.csv.

        Returns:
            Number of rows loaded.
        """
        logger.info("Loading L_AIRPORT_ID")
        df = CsvReader.read(file_path, encoding="latin1")
        airport_id_schema.validate(df)
        rows = [
            {col.lower(): val for col, val in row.items()}
            | {
                "source_file": str(file_path.name),
                "loaded_at": datetime.now(),
            }
            for row in df.to_dicts()
        ]
        repo = AirportIdRepository()
        repo.truncate()
        repo.insert(rows)
        logger.success("L_AIRPORT_ID loaded")
        return len(rows)
