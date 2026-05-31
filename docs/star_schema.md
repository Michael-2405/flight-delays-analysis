# Star Schema — Flight Delays Analysis

```mermaid
erDiagram

    dim_date {
        int date_id PK
        date full_date
        smallint year
        smallint month
        varchar month_name
        char month_name_short
        smallint day
        smallint day_of_week
        varchar day_of_week_name
        char day_of_week_short
        smallint quarter
        smallint semester
        smallint is_weekend
        smallint is_holiday
        timestamp created_at
        timestamp updated_at
    }

    dim_airline {
        int airline_id PK
        varchar iata_code
        varchar airline_name
        timestamp created_at
        timestamp updated_at
    }

    dim_airport {
        int airport_id PK
        varchar iata_code
        varchar airport_name
        varchar city
        varchar state
        varchar country
        decimal latitude
        decimal longitude
        text timezone
        timestamp created_at
        timestamp updated_at
    }

    dim_cancellation_reason {
        int cancellation_reason_id PK
        char cancellation_code
        varchar code_description
        timestamp created_at
        timestamp updated_at
    }

    fct_flights {
        int flight_id PK
        int date_id FK
        int airline_id FK
        int origin_airport_id FK
        int destination_airport_id FK
        int cancellation_reason_id FK
        varchar tail_number
        smallint flight_number
        smallint scheduled_departure
        smallint departure_time
        smallint departure_delay
        smallint scheduled_arrival
        smallint arrival_time
        smallint arrival_delay
        smallint scheduled_time
        smallint elapsed_time
        smallint air_time
        smallint taxi_out
        smallint taxi_in
        smallint wheels_off
        smallint wheels_on
        int distance
        smallint air_system_delay
        smallint security_delay
        smallint airline_delay
        smallint late_aircraft_delay
        smallint weather_delay
        smallint is_cancelled
        smallint is_diverted
        timestamp created_at
        timestamp updated_at
    }

    dim_date ||--o{ fct_flights : "date_id"
    dim_airline ||--o{ fct_flights : "airline_id"
    dim_airport ||--o{ fct_flights : "origin_airport_id"
    dim_airport ||--o{ fct_flights : "destination_airport_id"
    dim_cancellation_reason ||--o{ fct_flights : "cancellation_reason_id"
```

---

## Notes

- `dim_airport` is a **role-playing dimension** — it connects to `fct_flights` twice: once as origin airport and once as destination airport.
- `cancellation_reason_id` is **nullable** — only populated when `is_cancelled = 1`.
- `date_id` uses `YYYYMMDD` integer format (e.g. `20150115`).
