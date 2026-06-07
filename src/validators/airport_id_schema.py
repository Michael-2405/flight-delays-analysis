import pandera.polars as pa

airport_id_schema = pa.DataFrameSchema(
    {
        "Code": pa.Column(int, nullable=False),
        "Description": pa.Column(str, nullable=False),
    },
    strict=True,
)
