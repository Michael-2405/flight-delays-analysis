from pydantic import Field, field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    postgres_host: str
    postgres_port: int
    postgres_user: str
    postgres_password: str
    postgres_db: str

    postgres_database_schemas: list[str] = Field(default_factory=list)

    raw_data_path: str

    @field_validator("postgres_database_schemas", mode="before")
    @classmethod
    def parse_schemas(
        cls,
        value: str,
    ) -> list[str]:
        return [item.strip() for item in value.split(",")]

    model_config = {
        "env_file": ".env",
        "case_sensitive": False,
    }


settings = Settings()
