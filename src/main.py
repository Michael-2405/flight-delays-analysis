from pathlib import Path

from loguru import logger

from config.logging import configure_logging
from config.settings import settings
from pipelines.airlines_pipeline import AirlinesPipeline
from pipelines.airports_pipeline import AirportsPipeline
from pipelines.flights_pipeline import FlightsPipeline


def main() -> None:
    configure_logging()

    raw_path = Path(settings.raw_data_path)

    AirlinesPipeline().run(raw_path / "airlines.csv")
    AirportsPipeline().run(file_path=raw_path / "airports.csv")
    FlightsPipeline().run(file_path=raw_path / "flights.csv")

    logger.success("Pipeline completed")


if __name__ == "__main__":
    main()
