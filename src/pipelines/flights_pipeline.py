from datetime import datetime
from pathlib import Path

import polars as pl
from loguru import logger

from database.flights_repository import FlightRepository


class FlightPipeline:
    BATCH_SIZE = 100_000

    def run(self, file_path: Path) -> None:
        logger.info("Loading flights")
        repo = FlightRepository()
        reader = pl.read_csv_batched(file_path, batch_size=self.BATCH_SIZE)

        repo.truncate()
        counter = 0
        logger.info(f"Starting flights ingestion from {file_path.name}")
        while True:
            batches = reader.next_batches(1)
            if not batches:
                break
            batch = batches[0]

            counter += 1
            rows = [
                {col.lower(): val for col, val in row.items()}
                | {
                    "source_file": str(file_path.name),
                    "loaded_at": datetime.now(),
                }
                for row in batch.to_dicts()
            ]
            logger.info(f"Processing batch {counter} — {len(rows):,} rows")
            repo.insert_batch_copy(rows, source_file=str(file_path.name))
            logger.info(f"Total batches processed: {counter}")
        logger.success("Flights loaded")
