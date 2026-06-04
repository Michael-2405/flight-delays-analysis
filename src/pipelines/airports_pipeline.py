from pathlib import Path

from loguru import logger
from sqlalchemy.orm import Session

from database.engine import engine
from database.models import AirportRaw
from database.repositories import AirportRepository
from readers.csv_reader import CsvReader
from validators.airports_schema import airports_schema


class AirportsPipeline:
    def run(
        self,
        file_path: Path,
    ) -> None:

        logger.info("Loading airports")

        df = CsvReader.read(file_path)

        airports_schema.validate(df)

        records = [
            AirportRaw(
                iata_code=row["IATA_CODE"],
                airport=row["AIRPORT"],
                city=row["CITY"],
                state=row["STATE"],
                country=row["COUNTRY"],
                latitude=row["LATITUDE"],
                longitude=row["LONGITUDE"],
            )
            for row in df.to_dicts()
        ]

        repo = AirportRepository()

        with Session(engine) as session:
            repo.insert(
                session,
                records,
            )

            session.commit()

        logger.success("Airports loaded")
