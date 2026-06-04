from pathlib import Path

from loguru import logger

from config.logging import configure_logging
from config.settings import settings
from pipelines.airlines_pipeline import AirlinePipeline
from pipelines.airports_pipeline import AirportPipeline
from pipelines.flights_pipeline import FlightPipeline


def main() -> None:
    configure_logging()

    raw_path = Path(settings.raw_data_path)

    AirlinePipeline().run(raw_path / "airlines.csv")
    AirportPipeline().run(file_path=raw_path / "airports.csv")
    FlightPipeline().run(file_path=raw_path / "flights.csv")

    logger.success("Pipeline completed")


if __name__ == "__main__":
    main()
