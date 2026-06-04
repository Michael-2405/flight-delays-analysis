import pandera.polars as pa

airports_schema = pa.DataFrameSchema(
    {
        "IATA_CODE": pa.Column(str, nullable=False),
        "AIRPORT": pa.Column(str, nullable=False),
        "CITY": pa.Column(str, nullable=False),
        "STATE": pa.Column(str, nullable=False),
        "COUNTRY": pa.Column(str, nullable=False),
        "LATITUDE": pa.Column(float, nullable=False),
        "LONGITUDE": pa.Column(float, nullable=False),
    },
    strict=True,
)
