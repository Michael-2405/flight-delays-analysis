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
    total = 0

    total += AirlinePipeline().run(raw_path / "airlines.csv")
    logger.info(f"Cumulative rows processed: {total:,}")

    total += AirportPipeline().run(file_path=raw_path / "airports.csv")
    logger.info(f"Cumulative rows processed: {total:,}")

    total += FlightPipeline().run(file_path=raw_path / "flights.csv")

    logger.success(f"Pipeline completed — {total:,} total rows processed")


if __name__ == "__main__":
    main()
