from pathlib import Path

import polars as pl
from loguru import logger

from database.repositories import FlightsRepository


class FlightsPipeline:
    BATCH_SIZE = 100_000

    def run(
        self,
        file_path: Path,
    ) -> None:

        logger.info("Loading flights")

        repo = FlightsRepository()

        reader = pl.read_csv_batched(
            file_path,
            batch_size=self.BATCH_SIZE,
        )

        while True:
            batches = reader.next_batches(1)

            if not batches:
                break

            batch = batches[0]

            rows = batch.to_dicts()

            repo.insert_batch(rows)

        logger.success("Flights loaded")
