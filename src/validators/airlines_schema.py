import pandera.polars as pa

airlines_schema = pa.DataFrameSchema(
    {
        "IATA_CODE": pa.Column(str, nullable=False),
        "AIRLINE": pa.Column(str, nullable=False),
    },
    strict=True,
)
