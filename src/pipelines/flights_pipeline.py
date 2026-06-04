from datetime import datetime
from pathlib import Path

import polars as pl
from loguru import logger

from database.flights_repository import FlightRepository


class FlightPipeline:
    BATCH_SIZE = 100_000

    def run(self, file_path: Path) -> int:
        logger.info(f"Starting flights ingestion from {file_path.name}")

        repo = FlightRepository()
        reader = pl.read_csv_batched(file_path, batch_size=self.BATCH_SIZE)

        repo.truncate()

        batch_counter = 0
        total_rows = 0

        while True:
            batches = reader.next_batches(1)
            if not batches:
                break

            batch = batches[0]
            batch_counter += 1
            rows = [
                {col.lower(): val for col, val in row.items()}
                | {
                    "source_file": str(file_path.name),
                    "loaded_at": datetime.now(),
                }
                for row in batch.to_dicts()
            ]

            total_rows += len(rows)
            logger.info(
                f"Batch {batch_counter} — {len(rows):,} rows — {total_rows:,} total"
            )
            repo.insert_batch_copy(rows, source_file=str(file_path.name))

        logger.success(
            f"Flights loaded — {batch_counter} batches — {total_rows:,} rows"
        )
        return total_rows
