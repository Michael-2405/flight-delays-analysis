from datetime import datetime
from pathlib import Path

from loguru import logger

from database.airlines_repository import AirlinesRepository
from readers.csv_reader import CsvReader
from validators.airlines_schema import airlines_schema


class AirlinesPipeline:
    def run(self, file_path: Path) -> None:
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
        repo = AirlinesRepository()
        repo.truncate()
        repo.insert(rows)
        logger.success("Airlines loaded")
