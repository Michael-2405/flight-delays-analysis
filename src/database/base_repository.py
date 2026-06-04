from abc import ABC, abstractmethod

from sqlalchemy import text
from sqlalchemy.orm import Session

from database.engine import engine


class BaseRepository(ABC):
    @property
    @abstractmethod
    def schema_name(self) -> str:
        pass

    @property
    @abstractmethod
    def table_name(self) -> str:
        pass

    def truncate(self, session: Session | None = None):
        sql = text(f"TRUNCATE TABLE {self.schema_name}.{self.table_name}")

        if session is not None:
            session.execute(sql)
        else:
            with engine.begin() as conn:
                conn.execute(sql)
