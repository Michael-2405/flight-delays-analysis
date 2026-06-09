# Naming Conventions

**Version:** 1.1
**Database:** PostgreSQL
**Architecture:** Medallion (Bronze → Silver → Gold)

---

## General Rules

| Rule | Detail |
|------|--------|
| **Language** | English (US) for all objects |
| **Format** | `snake_case` — words separated by underscore |
| **Case** | Always lowercase — no exceptions |
| **Characters** | Only `a-z`, `0-9`, `_` |
| **Abbreviations** | Only industry-standard: `id`, `fk`, `pk`, `usp`, `vw`, `fct`, `dim`, `agg` |
| **Forbidden** | Spaces, `@#$%`, accents (é,ñ,ü), camelCase, PascalCase, Hungarian notation |
| **Length** | 63 characters maximum (PostgreSQL identifier limit) |

---

## Database Objects

### Schemas

| Layer | Pattern | Example |
|-------|---------|---------|
| Raw ingestion | `bronze` | `bronze` |
| Cleaned data | `silver` | `silver` |
| Dimensional model | `gold` | `gold` |
| Pipeline infrastructure | `etl` | `etl` |
| Reporting views | `reporting` | `reporting` |

### Tables

| Type | Pattern | Example |
|------|---------|---------|
| Bronze | `<entity>_raw` | `orders_raw`, `customers_raw` |
| Silver | `<entity>_clean` | `orders_clean`, `customers_clean` |
| Gold Dimension | `dim_<entity>` | `dim_customer`, `dim_date`, `dim_product` |
| Gold Fact | `fct_<business_process>` | `fct_sales`, `fct_orders` |
| Gold Aggregation | `agg_<metric>_<grain>` | `agg_revenue_monthly`, `agg_orders_daily` |
| ETL log/reference | `<purpose>` | `etl_log`, `airport_dot_iata_map` |

### Columns

| Type | Pattern | Example |
|------|---------|---------|
| General | `<descriptive_name>` | `customer_name`, `total_amount` |
| Boolean flag | `is_<condition>` | `is_cancelled`, `is_active`, `is_weekend` |
| Date | `<name>_date` | `order_date`, `effective_date` |
| Timestamp | `<name>_at` | `created_at`, `updated_at`, `loaded_at` |
| Amount | `<name>_amount` | `fare_amount`, `tax_amount` |
| Percentage | `<name>_pct` | `discount_pct`, `margin_pct` |
| Count | `<name>_count` | `order_count`, `retry_count` |
| Code | `<name>_code` | `product_code`, `status_code` |
| Surrogate key | `<entity>_id` | `customer_id`, `product_id` |
| Foreign key | `<referenced_entity>_id` | `customer_id`, `origin_location_id` |

### Required Metadata Columns

**Bronze tables:**
```sql
source_file  VARCHAR(500) NOT NULL              -- origin file or API name
loaded_at    TIMESTAMP    NOT NULL DEFAULT NOW() -- ingestion timestamp
```

**Silver and Gold tables:**
```sql
created_at   TIMESTAMP NOT NULL DEFAULT NOW() -- record creation timestamp
updated_at   TIMESTAMP NULL                   -- last update timestamp (NULL until first update)
```

---

## Database Procedures and Functions

| Type | Pattern | Example |
|------|---------|---------|
| Stored Procedure | `usp_<action>_<layer>_<entity>` | `usp_load_silver_orders` |
| Scalar Function | `ufn_<purpose>` | `ufn_log_start_etl` |
| Table Function | `utfn_<purpose>` | `utfn_get_active_customers` |

---

## Views

| Type | Pattern | Example |
|------|---------|---------|
| Standard | `vw_<entity>` | `vw_customers_active` |
| Report | `vw_rpt_<name>` | `vw_rpt_revenue_summary` |
| Dashboard | `vw_dash_<name>` | `vw_dash_sales_overview` |
| Data quality | `vw_dq_<check>` | `vw_dq_duplicate_orders` |

---

## Constraints and Indexes

| Type | Pattern | Example |
|------|---------|---------|
| Primary Key | `pk_<table>` | `pk_dim_customer`, `pk_fct_orders` |
| Foreign Key | `fk_<table>_<referenced_table>` | `fk_fct_orders_dim_customer` |
| Unique | `uq_<table>_<column>` | `uq_dim_customer_email` |
| Check | `ck_<table>_<condition>` | `ck_fct_orders_status` |
| Default | `df_<table>_<column>` | `df_orders_created_at` |
| Index | `idx_<table>_<column>` | `idx_fct_orders_customer_id` |

---

## SQL Files

| Type | Pattern | Example |
|------|---------|---------|
| Migration | `V<N>__<description>.sql` | `V1__create_schemas.sql` |
| DDL standalone | `ddl_<schema>_<entity>.sql` | `ddl_bronze_orders_raw.sql` |
| Stored Procedure | `sp_<schema>_<proc_name>.sql` | `sp_silver_usp_load_orders.sql` |
| View | `vw_<schema>_<view_name>.sql` | `vw_gold_rpt_revenue.sql` |
| Seed data | `seed_<schema>_<entity>.sql` | `seed_gold_dim_status.sql` |
| EDA | `eda_<entity>.sql` | `eda_orders_raw.sql` |

### SQL File Header Standard

```sql
-- =============================================================
-- Script Name: <filename>.sql
-- Description: <concise description of what the script does>
-- Schema:      <affected schema>
-- Author:      <author name>
-- Date:        YYYY-MM-DD
-- Change Log:
--   YYYY-MM-DD | <author> | Initial version
--   YYYY-MM-DD | <author> | <description of change>
-- =============================================================
```

---

## Python Conventions

### Files and Modules

| Type | Pattern | Example |
|------|---------|---------|
| Module | `snake_case.py` | `flights_pipeline.py` |
| Class | `PascalCase` | `FlightPipeline`, `BaseRepository` |
| Function / Method | `snake_case` | `run()`, `insert_batch_copy()` |
| Constant | `UPPER_SNAKE_CASE` | `BATCH_SIZE`, `MAX_RETRIES` |
| Variable | `snake_case` | `total_rows`, `file_path` |
| Private | `_snake_case` | `_build_query()` |

### Docstrings

Google Style docstrings for all public classes and methods:

```python
def method(self, param: type) -> return_type:
    """Short one-line description.

    Longer explanation if needed — when, why, edge cases.

    Args:
        param: Description of the parameter.

    Returns:
        Description of the return value.

    Raises:
        ExceptionType: When this condition occurs.
    """
```

**What to document:**
- All public classes — class-level docstring describing purpose
- Methods with non-obvious parameters or behavior
- Methods that raise exceptions
- Module-level docstrings for test files

**What not to document:**
- Pandera schema definitions — the schema is self-documenting
- Single-variable modules (e.g. `engine.py`)
- `main.py` when the flow is obvious from reading the code
- Simple getters and property implementations

### Type Hints

Always use type hints on function signatures:

```python
# ✅ Correct
def run(self, file_path: Path) -> int:
def insert(self, rows: list[dict]) -> None:
def truncate(self, session: Session | None = None) -> None:

# ❌ Incorrect
def run(self, file_path):
def insert(self, rows):
```

---

## Good vs Bad Examples

### SQL

| ✅ Correct | ❌ Incorrect | Reason |
|-----------|-------------|--------|
| `customer_id` | `CustomerID` | Wrong case |
| `is_active` | `active` | Missing boolean prefix |
| `total_amount` | `totAmt` | Abbreviation not standard |
| `dim_product` | `tblProduct` | Hungarian notation |
| `fct_orders` | `orders_fact` | Wrong pattern order |
| `usp_load_silver_orders` | `load_orders` | Missing prefix and layer |
| `fk_fct_orders_dim_customer` | `fk_customer` | Missing table context |

### Python

| ✅ Correct | ❌ Incorrect | Reason |
|-----------|-------------|--------|
| `class FlightPipeline` | `class flightPipeline` | Must be PascalCase |
| `BATCH_SIZE = 100_000` | `batchSize = 100_000` | Constants must be UPPER_SNAKE_CASE |
| `def run(self, file_path: Path) -> int` | `def run(self, filePath)` | camelCase and no type hints |
| `total_rows += len(rows)` | `totalRows += len(rows)` | camelCase forbidden |

---

## Checklist Before Creating Any Object

### Database
- [ ] Lowercase and snake_case?
- [ ] Only alphanumeric characters and `_`?
- [ ] Descriptive and self-documenting?
- [ ] Follows the layer pattern (Bronze/Silver/Gold)?
- [ ] 63 characters or fewer?
- [ ] Avoids SQL reserved words?
- [ ] Includes required metadata columns?
- [ ] Constraint and index names follow the pattern?
- [ ] Consistent with existing objects in the project?

### Python

- [ ] Classes in PascalCase?
- [ ] Functions and variables in snake_case?
- [ ] Constants in UPPER_SNAKE_CASE?
- [ ] Type hints on all public method signatures?
- [ ] Docstrings on classes and non-obvious methods?
- [ ] No abbreviations unless industry-standard?
