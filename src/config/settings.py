from pathlib import Path

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables or .env file.

    All variables are required unless a default is provided.
    The .env file is resolved relative to the project root (three levels
    above this file: src/config/settings.py → project root).

    Attributes:
        postgres_host: PostgreSQL server hostname.
        postgres_port: PostgreSQL server port.
        postgres_user: PostgreSQL username.
        postgres_password: PostgreSQL password.
        postgres_db: Target database name.
        postgres_database_schemas_raw: Comma-separated list of schemas
            (e.g. "bronze,silver,gold,etl"). Parsed via property.
        raw_data_path: Path to the directory containing source CSV files.
    """

    postgres_host: str
    postgres_port: int
    postgres_user: str
    postgres_password: str
    postgres_db: str
    postgres_database_schemas_raw: str = ""
    raw_data_path: str

    @property
    def postgres_database_schemas(self) -> list[str]:
        """Parse the raw comma-separated schemas string into a list.

        Returns:
            List of schema name strings with whitespace stripped.
        """
        return [s.strip() for s in self.postgres_database_schemas_raw.split(",")]

    model_config = {
        "env_file": str(Path(__file__).resolve().parent.parent.parent / ".env"),
        "case_sensitive": False,
    }


settings = Settings()  # type: ignore
