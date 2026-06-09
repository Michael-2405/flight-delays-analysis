from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airport_iata_repository import AirportIataRepository
from readers.csv_reader import CsvReader
from validators.airport_iata_schema import airport_iata_schema


class AirportIataPipeline:
    """Pipeline for loading L_AIRPORT.csv into bronze.airport_iata_raw.

    Source file uses latin1 encoding (BTS government file).
    Truncate + full load strategy.
    """

    def run(self, file_path: Path) -> int:
        """Read, validate and load BTS IATA airport code data into bronze.

        Args:
            file_path: Path to L_AIRPORT.csv.

        Returns:
            Number of rows loaded.
        """
        logger.info("Loading L_AIRPORT")
        df = CsvReader.read(file_path, encoding="latin1")
        airport_iata_schema.validate(df)
        rows = [
            {col.lower(): val for col, val in row.items()}
            | {
                "source_file": str(file_path.name),
                "loaded_at": datetime.now(),
            }
            for row in df.to_dicts()
        ]
        repo = AirportIataRepository()
        repo.truncate()
        repo.insert(rows)
        logger.success("L_AIRPORT loaded")
        return len(rows)
