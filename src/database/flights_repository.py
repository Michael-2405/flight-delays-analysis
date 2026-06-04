from sqlalchemy import MetaData, Table

from database.bronze_repository import BronzeRepository
from database.engine import engine


class FlightsRepository(BronzeRepository):
    @property
    def table_name(self) -> str:
        return "flights_raw"

    def insert_batch(self, rows: list[dict]) -> None:
        flights = Table(
            self.table_name, MetaData(schema=self.schema_name), autoload_with=engine
        )

        with engine.begin() as conn:
            conn.execute(flights.insert(), rows)
