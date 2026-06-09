from typing import cast

import psycopg
from psycopg.abc import Query
from sqlalchemy import inspect

from config.settings import settings
from database.bronze_repository import BronzeRepository
from database.engine import engine


class FlightRepository(BronzeRepository):
    """Repository for bronze.flights_raw.

    Uses PostgreSQL COPY FROM STDIN for bulk loading instead of
    executemany, which provides 10-50x better performance for
    the 5.8M row flights dataset.
    """

    @property
    def table_name(self) -> str:
        return "flights_raw"

    def insert_batch_copy(self, rows: list[dict], source_file: str) -> None:
        """Bulk insert a batch of flight rows using PostgreSQL COPY FROM STDIN.

        Dynamically reads column names from the table schema, excluding
        loaded_at (handled by DEFAULT NOW()). Adds source_file to each row
        before writing.

        Args:
            rows: List of dicts with lowercase keys matching the table columns.
                Each dict should contain all flight fields from flights.csv.
            source_file: Name of the source CSV file (e.g. "flights.csv").
                Written to the source_file column for traceability.

        Raises:
            psycopg.Error: If the COPY operation fails.
        """
        if not rows:
            return

        inspector = inspect(engine)
        columns = [
            col["name"]
            for col in inspector.get_columns(self.table_name, schema=self.schema_name)
            if col["name"] not in ("loaded_at",)
        ]

        copy_sql = f"""
            COPY {self.schema_name}.{self.table_name}
            ({", ".join(columns)})
            FROM STDIN
        """
        conn_string = (
            f"host={settings.postgres_host} "
            f"port={settings.postgres_port} "
            f"dbname={settings.postgres_db} "
            f"user={settings.postgres_user} "
            f"password={settings.postgres_password}"
        )

        with psycopg.connect(conn_string) as conn:
            with conn.cursor() as cur:
                with cur.copy(cast(Query, copy_sql)) as copy:
                    for row in rows:
                        row["source_file"] = source_file
                        copy.write_row(tuple(row.get(col) for col in columns))
