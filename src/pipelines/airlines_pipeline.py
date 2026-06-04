from pathlib import Path

from loguru import logger
from sqlalchemy.orm import Session

from database.engine import engine
from database.models import AirlineRaw
from database.repositories import AirlineRepository
from readers.csv_reader import CsvReader
from validators.airlines_schema import airlines_schema


class AirlinesPipeline:
    def run(self, file_path: Path) -> None:
        logger.info("Loading airlines")

        df = CsvReader.read(file_path)

        airlines_schema.validate(df)

        records = [
            AirlineRaw(iata_code=row["IATA_CODE"], airline=row["AIRLINE"])
            for row in df.to_dicts()
        ]

        repo = AirlineRepository()

        with Session(engine) as session:
            repo.insert(session, records)

            session.commit()

            logger.success("Airlines loaded")
