from sqlalchemy import MetaData, Table
from sqlalchemy.orm import Session

from database.engine import engine
from database.models import AirlineRaw, AirportRaw


class AirlineRepository:
    def insert(self, session: Session, records: list[AirlineRaw]) -> None:
        session.add_all(records)


class AirportRepository:
    def insert(self, session: Session, records: list[AirportRaw]) -> None:
        session.add_all(records)


class FlightRepository:
    def insert_batch(self, rows: list[dict]) -> None:
        metadata = MetaData(schema="bronze")

        flights = Table("flights_raw", metadata, autoload_with=engine)

        with engine.begin() as conn:
            conn.execute(flights.insert(), rows)
