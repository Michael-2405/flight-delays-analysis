import pandera.polars as pa

airport_iata_schema = pa.DataFrameSchema(
    {
        "Code": pa.Column(str, nullable=False),
        "Description": pa.Column(str, nullable=False),
    },
    strict=True,
)
