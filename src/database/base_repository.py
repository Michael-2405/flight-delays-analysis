from abc import ABC, abstractmethod

from sqlalchemy import text
from sqlalchemy.orm import Session

from database.engine import engine


class BaseRepository(ABC):
    """Abstract base class for all repository classes.

    Defines the interface that all repositories must implement:
    schema_name and table_name as abstract properties, and provides
    a concrete truncate() method usable with or without a SQLAlchemy Session.

    Subclasses must implement schema_name and table_name.
    """

    @property
    @abstractmethod
    def schema_name(self) -> str:
        """Return the PostgreSQL schema name for this repository."""
        pass

    @property
    @abstractmethod
    def table_name(self) -> str:
        """Return the PostgreSQL table name for this repository."""
        pass

    def truncate(self, session: Session | None = None) -> None:
        """Truncate the table managed by this repository.

        Args:
            session: Optional SQLAlchemy Session. If provided, the TRUNCATE
                is executed within the session's transaction. If None, a new
                connection is opened via engine.begin().
        """
        sql = text(f"TRUNCATE TABLE {self.schema_name}.{self.table_name}")

        if session is not None:
            session.execute(sql)
        else:
            with engine.begin() as conn:
                conn.execute(sql)
