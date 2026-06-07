# Naming Conventions

**Version:** 1.0
**Project:** Flight Delays and Cancellations
**Database:** PostgreSQL
**Architecture:** Medallion (Bronze → Silver → Gold)

---

## General Rules

| Rule | Detail |
|------|--------|
| **Language** | English (US) for all database objects |
| **Format** | `snake_case` — words separated by underscore |
| **Case** | Always lowercase — no exceptions |
| **Characters** | Only `a-z`, `0-9`, `_` |
| **Abbreviations** | Only industry-standard: `id`, `fk`, `pk`, `usp`, `vw`, `fct`, `dim` |
| **Forbidden** | Spaces, `@#$%`, accents (é,ñ,ü), camelCase, PascalCase, Hungarian notation |

---

## Cheat Sheet

| Object | Pattern | Example |
|--------|---------|---------|
| **Schema** | `<layer>` | `bronze`, `silver`, `gold`, `etl` |
| **Bronze Table** | `<entity>_raw` | `flights_raw`, `airlines_raw`, `airports_raw` |
| **Silver Table** | `<entity>_clean` | `flights_clean`, `airlines_clean` |
| **Gold Dimension** | `dim_<entity>` | `dim_airline`, `dim_airport`, `dim_date` |
| **Gold Fact** | `fct_<business_process>` | `fct_flights` |
| **Gold Aggregation** | `agg_<metric>_<grain>` | `agg_delays_monthly`, `agg_flights_daily` |
| **ETL Table** | `etl_<purpose>` | `etl_log`, `etl_error_detail` |
| **Column (general)** | `<descriptive_name>` | `airport_name`, `departure_delay` |
| **Column (flag)** | `is_` + name | `is_cancelled`, `is_diverted`, `is_weekend` |
| **Column (date)** | name + `_date` | `flight_date`, `effective_date` |
| **Column (timestamp)** | name + `_at` | `created_at`, `updated_at`, `loaded_at` |
| **Column (amount)** | name + `_amount` | `fare_amount` |
| **Column (percentage)** | name + `_pct` | `delay_pct`, `cancellation_pct` |
| **Column (count)** | name + `_count` | `flight_count`, `delay_count` |
| **Column (code)** | name + `_code` | `iata_code`, `cancellation_code` |
| **PK (all types)** | `<entity>_id` | `airline_id`, `airport_id`, `flight_id` |
| **FK** | `<referenced_entity>_id` | `airline_id`, `origin_airport_id` |
| **Stored Procedure** | `usp_<action>_<layer>_<entity>` | `usp_load_silver_flights` |
| **View (standard)** | `vw_<entity>` | `vw_flights_current` |
| **View (report)** | `vw_rpt_<name>` | `vw_rpt_delay_analysis` |
| **View (dashboard)** | `vw_dash_<name>` | `vw_dash_flight_summary` |
| **View (quality)** | `vw_dq_<check>` | `vw_dq_duplicate_flights` |
| **Index** | `idx_<table>_<column>` | `idx_fct_flights_date_id` |
| **PK Constraint** | `pk_<table>` | `pk_dim_airline`, `pk_fct_flights` |
| **FK Constraint** | `fk_<table>_<referenced_table>` | `fk_fct_flights_dim_airline` |
| **Unique Constraint** | `uq_<table>_<column>` | `uq_dim_airline_iata_code` |
| **Check Constraint** | `ck_<table>_<condition>` | `ck_fct_flights_cancellation` |
| **Default Constraint** | `df_<table>_<column>` | `df_fct_flights_created_at` |

---

## SQL File Conventions

| Script Type | Pattern | Example |
|-------------|---------|---------|
| DDL (tables) | `ddl_<schema>_<entity>.sql` | `ddl_bronze_flights_raw.sql` |
| Stored Procedure | `sp_<schema>_<proc_name>.sql` | `sp_silver_usp_load_flights.sql` |
| View | `vw_<schema>_<view_name>.sql` | `vw_gold_rpt_delay_analysis.sql` |
| Migration | `V<version>__<description>.sql` | `V1.0.0__initial_schema.sql` |
| Seed data | `seed_<schema>_<entity>.sql` | `seed_gold_dim_cancellation_reason.sql` |
| Documentation | `doc_<topic>.md` | `doc_data_dictionary.md` |

---

## Required Metadata by Layer

### Bronze

```sql
source_file      VARCHAR(500)   NOT NULL   -- origin file name
loaded_at        TIMESTAMP      NOT NULL   DEFAULT NOW()
```

### Silver and Gold

```sql
created_at       TIMESTAMP      NOT NULL   DEFAULT NOW()
updated_at       TIMESTAMP
```

---

## Good vs Bad Examples

| ✅ Correct | ❌ Incorrect | Reason |
|-----------|-------------|--------|
| `airline_id` | `AirlineID` | Wrong case |
| `is_cancelled` | `cancelled` | Missing boolean prefix |
| `departure_delay` | `depDelay` | camelCase forbidden |
| `dim_airport` | `tblAirport` | Hungarian notation forbidden |
| `fct_flights` | `flights_fact` | Wrong pattern order |
| `iata_code` | `code` | Not descriptive |
| `usp_load_silver_flights` | `load_flights` | Missing prefix and layer |
| `fk_fct_flights_dim_airline` | `fk_airline` | Missing table context |

---

## Checklist Before Creating Any Object

- [ ] Is it lowercase?
- [ ] Does it use snake_case?
- [ ] Does it only contain alphanumeric characters and `_`?
- [ ] Is it descriptive and self-documented?
- [ ] Does it follow the layer pattern (Bronze/Silver/Gold)?
- [ ] Is it 63 characters or fewer? (PostgreSQL limit)
- [ ] Does it avoid SQL reserved words?
- [ ] Does it include the required metadata columns?
- [ ] Is it consistent with existing objects in the project?
