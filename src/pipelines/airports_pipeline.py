from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airports_repository import AirportsRepository
from readers.csv_reader import CsvReader
from validators.airports_schema import airports_schema


class AirportsPipeline:
    def run(self, file_path: Path) -> None:
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
        repo = AirportsRepository()
        repo.truncate()
        repo.insert(rows)
        logger.success("Airports loaded")
