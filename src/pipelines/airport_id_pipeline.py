from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airport_id_repository import AirportIdRepository
from readers.csv_reader import CsvReader
from validators.airport_id_schema import airport_id_schema


class AirportIdPipeline:
    def run(self, file_path: Path) -> int:
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
