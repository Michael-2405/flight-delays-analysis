import pandera.polars as pa

flights_schema = pa.DataFrameSchema(
    {
        "YEAR": pa.Column(int),
        "MONTH": pa.Column(int),
        "DAY": pa.Column(int),
        "DAY_OF_WEEK": pa.Column(int),
        "AIRLINE": pa.Column(str),
        "FLIGHT_NUMBER": pa.Column(int),
        "TAIL_NUMBER": pa.Column(int),
    },
    strict=True,
)
