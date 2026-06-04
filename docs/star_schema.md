# Star Schema — Flight Delays Analysis

```mermaid
flowchart TB
    dim_date["📅 dim_date
    ────────────────
    🔑 date_id (PK)
    full_date
    year / month / day
    month_name / day_of_week_name
    quarter / semester
    is_weekend / is_holiday"]

    dim_airline["✈️ dim_airline
    ────────────────
    🔑 airline_id (PK)
    iata_code
    airline_name"]

    dim_airport["🏢 dim_airport
    ────────────────
    🔑 airport_id (PK)
    iata_code
    airport_name
    city / state / country
    latitude / longitude
    timezone"]

    dim_cancellation["❌ dim_cancellation_reason
    ────────────────
    🔑 cancellation_reason_id (PK)
    cancellation_code
    code_description"]

    fct_flights["🛫 fct_flights
    ────────────────
    🔑 flight_id (PK)
    🔗 date_id (FK)
    🔗 airline_id (FK)
    🔗 origin_airport_id (FK)
    🔗 destination_airport_id (FK)
    🔗 cancellation_reason_id (FK)
    ────────────────
    tail_number
    flight_number
    departure_delay
    arrival_delay
    distance / air_time
    taxi_out / taxi_in
    weather_delay
    airline_delay
    is_cancelled / is_diverted"]

    dim_date -->|date_id| fct_flights
    dim_airline -->|airline_id| fct_flights
    dim_airport -->|origin_airport_id| fct_flights
    dim_airport -->|destination_airport_id| fct_flights
    dim_cancellation -->|cancellation_reason_id| fct_flights
```

---

## Notes

- `dim_airport` is a **role-playing dimension** — connects to `fct_flights` twice: as origin and as destination airport.
- `cancellation_reason_id` is **nullable** — only populated when `is_cancelled = 1`.
- `date_id` uses `YYYYMMDD` integer format (e.g. `20150115`).
