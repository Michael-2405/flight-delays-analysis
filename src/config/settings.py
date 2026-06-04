from pathlib import Path

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    postgres_host: str
    postgres_port: int
    postgres_user: str
    postgres_password: str
    postgres_db: str
    postgres_database_schemas_raw: str = ""
    raw_data_path: str

    @property
    def postgres_database_schemas(self) -> list[str]:
        return [s.strip() for s in self.postgres_database_schemas_raw.split(",")]

    model_config = {
        "env_file": str(Path(__file__).resolve().parent.parent.parent / ".env"),
        "case_sensitive": False,
    }


settings = Settings()
