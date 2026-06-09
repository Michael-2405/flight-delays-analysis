from abc import abstractmethod

from database.base_repository import BaseRepository


class BronzeRepository(BaseRepository):
    """Base repository for all bronze schema tables.

    Implements schema_name as "bronze" so concrete subclasses
    only need to implement table_name.
    """

    @property
    def schema_name(self) -> str:
        """Return the bronze schema name."""
        return "bronze"

    @property
    @abstractmethod
    def table_name(self) -> str:
        """Return the specific bronze table name."""
        pass
