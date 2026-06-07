from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airport_iata_repository import AirportIataRepository
from readers.csv_reader import CsvReader
from validators.airport_iata_schema import airport_iata_schema


class AirportIataPipeline:
    def run(self, file_path: Path) -> int:
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
