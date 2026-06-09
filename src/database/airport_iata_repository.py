from sqlalchemy import MetaData, Table

from database.bronze_repository import BronzeRepository
from database.engine import engine


class AirportIataRepository(BronzeRepository):
    """Repository for bronze.airport_iata_raw (BTS IATA codes)."""

    @property
    def table_name(self) -> str:
        return "airport_iata_raw"

    def insert(self, rows: list[dict]) -> None:
        """Insert rows into bronze.airport_iata_raw using executemany.

        Args:
            rows: List of dicts with keys matching the table columns.
        """
        table = Table(
            self.table_name,
            MetaData(schema=self.schema_name),
            autoload_with=engine,
        )
        with engine.begin() as conn:
            conn.execute(statement=table.insert(), parameters=rows)
