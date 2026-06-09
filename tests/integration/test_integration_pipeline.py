"""Integration tests for the full Bronze → Silver → Gold pipeline.

Connects to the real database and validates row counts, business rules,
referential integrity and data quality across all three layers.

Requirements:
    - central-postgres must be running on the configured port.
    - All three layers must be fully loaded before running these tests.
    - Run from project root: uv run pytest tests/integration/ -v
"""

from sqlalchemy import text

from database.engine import engine


def query_count(sql: str) -> int:
    """Execute a COUNT query and return the result as an integer.

    Args:
        sql: SQL SELECT COUNT(*) statement to execute.

    Returns:
        Integer count result. Returns 0 if the query returns NULL.
    """
    with engine.connect() as conn:
        result = conn.execute(text(sql))
        return result.scalar() or 0


class TestBronzeLayer:
    """Validates row counts and data quality in the bronze schema."""

    def test_airlines_raw_row_count(self):
        assert query_count("SELECT COUNT(*) FROM bronze.airlines_raw") == 14

    def test_airports_raw_row_count(self):
        assert query_count("SELECT COUNT(*) FROM bronze.airports_raw") >= 322

    def test_flights_raw_row_count(self):
        assert query_count("SELECT COUNT(*) FROM bronze.flights_raw") == 5_819_079

    def test_airport_id_raw_row_count(self):
        assert query_count("SELECT COUNT(*) FROM bronze.airport_id_raw") > 0

    def test_airport_iata_raw_row_count(self):
        assert query_count("SELECT COUNT(*) FROM bronze.airport_iata_raw") > 0

    def test_flights_raw_no_null_airline(self):
        count = query_count(
            "SELECT COUNT(*) FROM bronze.flights_raw WHERE airline IS NULL"
        )
        assert count == 0

    def test_flights_raw_only_2015(self):
        count = query_count(
            "SELECT COUNT(DISTINCT year) FROM bronze.flights_raw WHERE year != 2015"
        )
        assert count == 0

    def test_flights_raw_all_12_months(self):
        count = query_count("SELECT COUNT(DISTINCT month) FROM bronze.flights_raw")
        assert count == 12


class TestSilverLayer:
    """Validates that silver counts match bronze and transformations are correct."""

    def test_airline_clean_matches_bronze(self):
        assert query_count("SELECT COUNT(*) FROM silver.airline_clean") == query_count(
            "SELECT COUNT(*) FROM bronze.airlines_raw"
        )

    def test_airport_clean_matches_bronze(self):
        assert query_count("SELECT COUNT(*) FROM silver.airport_clean") == query_count(
            "SELECT COUNT(*) FROM bronze.airports_raw"
        )

    def test_flight_clean_matches_bronze(self):
        assert query_count("SELECT COUNT(*) FROM silver.flight_clean") == query_count(
            "SELECT COUNT(*) FROM bronze.flights_raw"
        )

    def test_flight_clean_has_full_date(self):
        count = query_count(
            "SELECT COUNT(*) FROM silver.flight_clean WHERE full_date IS NULL"
        )
        assert count == 0

    def test_flight_clean_has_date_id(self):
        count = query_count(
            "SELECT COUNT(*) FROM silver.flight_clean WHERE date_id IS NULL"
        )
        assert count == 0

    def test_flight_clean_date_id_format(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM silver.flight_clean
            WHERE date_id < 20140101 OR date_id > 20161231
            """
        )
        assert count == 0

    def test_flight_clean_no_dot_codes(self):
        """DOT numeric codes must be fully translated to IATA in silver."""
        regex = "^[0-9]+$"
        count = query_count(
            f"""
            SELECT COUNT(*) FROM silver.flight_clean
            WHERE origin_airport ~ '{regex}'
            OR destination_airport ~ '{regex}'
            """
        )
        assert count == 0


class TestGoldDimensions:
    """Validates gold dimension tables for counts, uniqueness and completeness."""

    def test_dim_airline_row_count(self):
        assert query_count("SELECT COUNT(*) FROM gold.dim_airline") == 14

    def test_dim_airport_row_count(self):
        assert query_count("SELECT COUNT(*) FROM gold.dim_airport") >= 322

    def test_dim_date_covers_2015(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.dim_date
            WHERE full_date BETWEEN '2015-01-01' AND '2015-12-31'
            """
        )
        assert count == 365

    def test_dim_cancellation_reason_row_count(self):
        assert query_count("SELECT COUNT(*) FROM gold.dim_cancellation_reason") == 4

    def test_dim_cancellation_reason_codes(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.dim_cancellation_reason
            WHERE cancellation_code IN ('A', 'B', 'C', 'D')
            """
        )
        assert count == 4

    def test_dim_date_no_duplicates(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM (
                SELECT date_id, COUNT(*)
                FROM gold.dim_date
                GROUP BY date_id
                HAVING COUNT(*) > 1
            ) d
            """
        )
        assert count == 0

    def test_dim_airline_no_duplicates(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM (
                SELECT iata_code, COUNT(*)
                FROM gold.dim_airline
                GROUP BY iata_code
                HAVING COUNT(*) > 1
            ) d
            """
        )
        assert count == 0


class TestGoldFactFlights:
    """Validates fct_flights for counts, nulls, duplicates and business rules."""

    def test_fct_flights_row_count(self):
        assert query_count("SELECT COUNT(*) FROM gold.fct_flights") == 5_819_079

    def test_fct_flights_no_null_date_id(self):
        count = query_count(
            "SELECT COUNT(*) FROM gold.fct_flights WHERE date_id IS NULL"
        )
        assert count == 0

    def test_fct_flights_no_null_airline_id(self):
        count = query_count(
            "SELECT COUNT(*) FROM gold.fct_flights WHERE airline_id IS NULL"
        )
        assert count == 0

    def test_fct_flights_no_null_airport_ids(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights
            WHERE origin_airport_id IS NULL OR destination_airport_id IS NULL
            """
        )
        assert count == 0

    def test_fct_flights_matches_silver(self):
        assert query_count("SELECT COUNT(*) FROM gold.fct_flights") == query_count(
            "SELECT COUNT(*) FROM silver.flight_clean"
        )

    def test_fct_flights_no_duplicates(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM (
                SELECT date_id, airline_id, flight_number,
                       origin_airport_id, destination_airport_id, COUNT(*)
                FROM gold.fct_flights
                GROUP BY date_id, airline_id, flight_number,
                         origin_airport_id, destination_airport_id
                HAVING COUNT(*) > 1
            ) d
            """
        )
        assert count == 0

    def test_cancellation_business_rule(self):
        """Cancelled flights must always have a cancellation_reason_id."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights
            WHERE is_cancelled = 1 AND cancellation_reason_id IS NULL
            """
        )
        assert count == 0

    def test_not_cancelled_no_reason(self):
        """Non-cancelled flights must never have a cancellation_reason_id."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights
            WHERE is_cancelled = 0 AND cancellation_reason_id IS NOT NULL
            """
        )
        assert count == 0

    def test_all_airline_ids_exist_in_dim(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights f
            LEFT JOIN gold.dim_airline a ON f.airline_id = a.airline_id
            WHERE f.airline_id IS NOT NULL AND a.airline_id IS NULL
            """
        )
        assert count == 0

    def test_all_date_ids_exist_in_dim(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights f
            LEFT JOIN gold.dim_date d ON f.date_id = d.date_id
            WHERE d.date_id IS NULL
            """
        )
        assert count == 0

    def test_all_airport_ids_exist_in_dim(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights f
            LEFT JOIN gold.dim_airport a ON f.origin_airport_id = a.airport_id
            WHERE f.origin_airport_id IS NOT NULL AND a.airport_id IS NULL
            """
        )
        assert count == 0
