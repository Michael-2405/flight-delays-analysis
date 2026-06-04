from sqlalchemy import MetaData, Table

from database.bronze_repository import BronzeRepository
from database.engine import engine


class AirportRepository(BronzeRepository):
    @property
    def table_name(self) -> str:
        return "airports_raw"

    def insert(self, rows: list[dict]) -> None:
        table = Table(
            self.table_name,
            MetaData(schema=self.schema_name),
            autoload_with=engine,
        )
        with engine.begin() as conn:
            conn.execute(table.insert(), rows)
