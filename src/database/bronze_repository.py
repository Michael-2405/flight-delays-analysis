from abc import abstractmethod

from database.base_repository import BaseRepository


class BronzeRepository(BaseRepository):
    @property
    def schema_name(self) -> str:
        return "bronze"

    @property
    @abstractmethod
    def table_name(self) -> str:
        pass
