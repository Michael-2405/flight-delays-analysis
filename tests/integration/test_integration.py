"""
Integration tests for the Flight Delays Analysis pipeline.

These tests connect to the real database and validate:
- Row counts match across Bronze, Silver and Gold layers
- Business rules are enforced in Gold
- No nulls in critical columns
- Referential integrity between fact and dimensions

Requirements:
- Database must be running (central-postgres on port 5440)
- All three layers must be loaded before running these tests
- Run from project root: uv run pytest tests/test_integration.py -v
"""

from sqlalchemy import text

from database.engine import engine

# ============================================================
# Helpers
# ============================================================


def query_count(sql: str) -> int:
    with engine.connect() as conn:
        result = conn.execute(text(sql))
        return result.scalar() or 0


# ============================================================
# Bronze Layer
# ============================================================


class TestBronzeLayer:
    def test_airlines_raw_row_count(self):
        count = query_count("SELECT COUNT(*) FROM bronze.airlines_raw")
        assert count == 14, f"Expected 14 airlines, got {count}"

    def test_airports_raw_row_count(self):
        count = query_count("SELECT COUNT(*) FROM bronze.airports_raw")
        assert count >= 322, f"Expected at least 322 airports, got {count}"

    def test_flights_raw_row_count(self):
        count = query_count("SELECT COUNT(*) FROM bronze.flights_raw")
        assert count == 5_819_079, f"Expected 5,819,079 flights, got {count}"

    def test_airport_id_raw_row_count(self):
        count = query_count("SELECT COUNT(*) FROM bronze.airport_id_raw")
        assert count > 0, "airport_id_raw should not be empty"

    def test_airport_iata_raw_row_count(self):
        count = query_count("SELECT COUNT(*) FROM bronze.airport_iata_raw")
        assert count > 0, "airport_iata_raw should not be empty"

    def test_flights_raw_no_null_airline(self):
        count = query_count(
            "SELECT COUNT(*) FROM bronze.flights_raw WHERE airline IS NULL"
        )
        assert count == 0, f"Found {count} flights with NULL airline in bronze"

    def test_flights_raw_only_2015(self):
        count = query_count(
            "SELECT COUNT(DISTINCT year) FROM bronze.flights_raw WHERE year != 2015"
        )
        assert count == 0, "flights_raw should only contain data from 2015"

    def test_flights_raw_all_12_months(self):
        count = query_count("SELECT COUNT(DISTINCT month) FROM bronze.flights_raw")
        assert count == 12, f"Expected 12 months, got {count}"


# ============================================================
# Silver Layer
# ============================================================


class TestSilverLayer:
    def test_airline_clean_matches_bronze(self):
        bronze = query_count("SELECT COUNT(*) FROM bronze.airlines_raw")
        silver = query_count("SELECT COUNT(*) FROM silver.airline_clean")
        assert silver == bronze, (
            f"silver.airline_clean ({silver}) != bronze.airlines_raw ({bronze})"
        )

    def test_airport_clean_matches_bronze(self):
        bronze = query_count("SELECT COUNT(*) FROM bronze.airports_raw")
        silver = query_count("SELECT COUNT(*) FROM silver.airport_clean")
        assert silver == bronze, (
            f"silver.airport_clean ({silver}) != bronze.airports_raw ({bronze})"
        )

    def test_flight_clean_matches_bronze(self):
        bronze = query_count("SELECT COUNT(*) FROM bronze.flights_raw")
        silver = query_count("SELECT COUNT(*) FROM silver.flight_clean")
        assert silver == bronze, (
            f"silver.flight_clean ({silver}) != bronze.flights_raw ({bronze})"
        )

    def test_flight_clean_has_full_date(self):
        count = query_count(
            "SELECT COUNT(*) FROM silver.flight_clean WHERE full_date IS NULL"
        )
        assert count == 0, f"Found {count} flights with NULL full_date in silver"

    def test_flight_clean_has_date_id(self):
        count = query_count(
            "SELECT COUNT(*) FROM silver.flight_clean WHERE date_id IS NULL"
        )
        assert count == 0, f"Found {count} flights with NULL date_id in silver"

    def test_flight_clean_date_id_format(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM silver.flight_clean
            WHERE date_id < 20140101 OR date_id > 20161231
            """
        )
        assert count == 0, f"Found {count} flights with invalid date_id format"

    def test_flight_clean_no_dot_codes(self):
        regex = "^[0-9]+$"
        count = query_count(
            f"""
          SELECT COUNT(*) FROM silver.flight_clean
          WHERE origin_airport ~ '{regex}'
          OR destination_airport ~ '{regex}'
          """
        )
        assert count == 0, (
            f"Found {count} flights with DOT numeric codes in silver — "
            "translation should have resolved all codes"
        )


# ============================================================
# Gold Layer — Dimensions
# ============================================================


class TestGoldDimensions:
    def test_dim_airline_row_count(self):
        count = query_count("SELECT COUNT(*) FROM gold.dim_airline")
        assert count == 14, f"Expected 14 airlines in dim_airline, got {count}"

    def test_dim_airport_row_count(self):
        count = query_count("SELECT COUNT(*) FROM gold.dim_airport")
        assert count >= 322, (
            f"Expected at least 322 airports in dim_airport, got {count}"
        )

    def test_dim_date_covers_2015(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.dim_date
            WHERE full_date BETWEEN '2015-01-01' AND '2015-12-31'
            """
        )
        assert count == 365, f"Expected 365 days in 2015, got {count}"

    def test_dim_cancellation_reason_row_count(self):
        count = query_count("SELECT COUNT(*) FROM gold.dim_cancellation_reason")
        assert count == 4, f"Expected 4 cancellation reasons, got {count}"

    def test_dim_cancellation_reason_codes(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.dim_cancellation_reason
            WHERE cancellation_code IN ('A', 'B', 'C', 'D')
            """
        )
        assert count == 4, "Expected codes A, B, C, D in dim_cancellation_reason"

    def test_dim_date_no_duplicates(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM (
                SELECT date_id, COUNT(*)
                FROM gold.dim_date
                GROUP BY date_id
                HAVING COUNT(*) > 1
            ) duplicates
            """
        )
        assert count == 0, f"Found {count} duplicate date_ids in dim_date"

    def test_dim_airline_no_duplicates(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM (
                SELECT iata_code, COUNT(*)
                FROM gold.dim_airline
                GROUP BY iata_code
                HAVING COUNT(*) > 1
            ) duplicates
            """
        )
        assert count == 0, f"Found {count} duplicate iata_codes in dim_airline"


# ============================================================
# Gold Layer — Fact Table
# ============================================================


class TestGoldFactFlights:
    def test_fct_flights_row_count(self):
        count = query_count("SELECT COUNT(*) FROM gold.fct_flights")
        assert count == 5_819_079, f"Expected 5,819,079 flights, got {count}"

    def test_fct_flights_no_null_date_id(self):
        count = query_count(
            "SELECT COUNT(*) FROM gold.fct_flights WHERE date_id IS NULL"
        )
        assert count == 0, f"Found {count} flights with NULL date_id"

    def test_fct_flights_no_null_airline_id(self):
        count = query_count(
            "SELECT COUNT(*) FROM gold.fct_flights WHERE airline_id IS NULL"
        )
        assert count == 0, f"Found {count} flights with NULL airline_id"

    def test_fct_flights_no_null_airport_ids(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights
            WHERE origin_airport_id IS NULL
            OR destination_airport_id IS NULL
            """
        )
        assert count == 0, f"Found {count} flights with NULL airport IDs"

    def test_fct_flights_matches_silver(self):
        silver = query_count("SELECT COUNT(*) FROM silver.flight_clean")
        gold = query_count("SELECT COUNT(*) FROM gold.fct_flights")
        assert gold == silver, f"fct_flights ({gold}) != silver.flight_clean ({silver})"

    def test_fct_flights_no_duplicates(self):
        count = query_count(
            """
            SELECT COUNT(*) FROM (
                SELECT
                    date_id, airline_id, flight_number,
                    origin_airport_id, destination_airport_id,
                    COUNT(*)
                FROM gold.fct_flights
                GROUP BY
                    date_id, airline_id, flight_number,
                    origin_airport_id, destination_airport_id
                HAVING COUNT(*) > 1
            ) duplicates
            """
        )
        assert count == 0, f"Found {count} duplicate flights in fct_flights"

    def test_cancellation_business_rule(self):
        """Cancelled flights must have a cancellation reason."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights
            WHERE is_cancelled = 1
            AND cancellation_reason_id IS NULL
            """
        )
        assert count == 0, (
            f"Found {count} cancelled flights without cancellation_reason_id"
        )

    def test_not_cancelled_no_reason(self):
        """Non-cancelled flights must NOT have a cancellation reason."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights
            WHERE is_cancelled = 0
            AND cancellation_reason_id IS NOT NULL
            """
        )
        assert count == 0, (
            f"Found {count} non-cancelled flights with cancellation_reason_id"
        )

    def test_all_airline_ids_exist_in_dim(self):
        """All airline_ids in fct_flights must exist in dim_airline."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights f
            LEFT JOIN gold.dim_airline a ON f.airline_id = a.airline_id
            WHERE f.airline_id IS NOT NULL
            AND a.airline_id IS NULL
            """
        )
        assert count == 0, f"Found {count} orphaned airline_ids in fct_flights"

    def test_all_date_ids_exist_in_dim(self):
        """All date_ids in fct_flights must exist in dim_date."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights f
            LEFT JOIN gold.dim_date d ON f.date_id = d.date_id
            WHERE d.date_id IS NULL
            """
        )
        assert count == 0, f"Found {count} orphaned date_ids in fct_flights"

    def test_all_airport_ids_exist_in_dim(self):
        """All non-null airport_ids in fct_flights must exist in dim_airport."""
        count = query_count(
            """
            SELECT COUNT(*) FROM gold.fct_flights f
            LEFT JOIN gold.dim_airport a ON f.origin_airport_id = a.airport_id
            WHERE f.origin_airport_id IS NOT NULL
            AND a.airport_id IS NULL
            """
        )
        assert count == 0, f"Found {count} orphaned origin_airport_ids in fct_flights"
