import sys
from pathlib import Path

from loguru import logger


def configure_logging() -> None:
    Path("logs").mkdir(exist_ok=True)

    logger.remove()

    logger.add(
        "logs/pipeline.log",
        level="INFO",
        rotation="10 MB",
        retention="30 days",
        compression="zip",
        enqueue=True,
    )

    logger.add(sys.stdout, level="INFO", colorize=True)
