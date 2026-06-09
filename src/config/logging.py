import sys
from pathlib import Path

from loguru import logger

LOG_DIR = Path(__file__).resolve().parent.parent.parent / "logs"


def configure_logging() -> None:
    """Configure loguru logging for the ingestion pipeline.

    Sets up two sinks:
    - Console (stdout): INFO level with colorized output and timestamp.
    - File (logs/pipeline.log): INFO level with 10 MB rotation,
      30-day retention and zip compression.

    Creates the logs/ directory if it does not exist.
    """
    LOG_DIR.mkdir(exist_ok=True)

    logger.remove()

    logger.add(
        sys.stdout,
        level="INFO",
        colorize=True,
        format="<green>{time:HH:mm:ss}</green> | <level>{level}</level> | {message}",
    )

    logger.add(
        "logs/pipeline.log",
        level="INFO",
        rotation="10 MB",
        retention="30 days",
        compression="zip",
        enqueue=True,
    )
