# EDA Findings — Bronze Layer

**Version:** 1.3
**Date:** 2026-06
**Author:** Michael Espinosa

---

## airlines_raw

| Check | Result |
|-------|--------|
| Row count | 14 |
| Nulls | 0 in all columns |
| Duplicates | None |
| Whitespace | None |

**Decision:** Ready for Silver with single rename: `airline` → `airline_name`.

---

## airports_raw

| Check | Result |
|-------|--------|
| Row count | 322 |
| Nulls in key columns | 0 |
| Nulls in coordinates | 3 airports (ECP, PBG, UST) |
| Duplicates | None |
| Whitespace | None |

**Decision:** Keep NULLs in Silver — coordinates are optional context.

---

## flights_raw

### Row Count
5,819,079 rows — all from 2015, all 12 months present.

### Nulls

| Column | Nulls | % | Explanation |
|--------|-------|---|-------------|
| `tail_number` | 14,721 | 0.25% | Acceptable — no dim_aircraft |
| `departure_delay` | 86,153 | 1.48% | Correlate with `cancelled = 1` |
| `arrival_delay` | 105,071 | 1.80% | Correlate with `cancelled = 1` |
| `cancellation_reason` | 5,729,195 | 98.45% | Expected — not cancelled |
| delay breakdown columns | 4,755,640 | 81.73% | Expected — no delay recorded |

### Business Rules Validation

| Rule | Violations |
|------|------------|
| `cancelled = 1` AND `cancellation_reason IS NULL` | 0 ✅ |
| `cancelled = 0` AND `cancellation_reason IS NOT NULL` | 0 ✅ |

### Duplicate Analysis

AA803 on 2015-08-29 from STT appears twice — not a true duplicate.
Same flight number used for two different routes (STT→CLT and STT→SJU).

**Natural key:** `year + month + day + airline + flight_number + origin_airport + destination_airport`

### Delay Ranges

| Metric | Min | Max | Avg |
|--------|-----|-----|-----|
| `departure_delay` | -82 min | 1,988 min | 9.37 min |
| `arrival_delay` | -87 min | 1,971 min | 4.41 min |

### Referential Integrity

| Check | Result |
|-------|--------|
| Airline codes not in `airlines_raw` | 0 ✅ |
| Airport codes not in `airports_raw` | 306 unique DOT numeric codes |
| Flights affected | 486,165 (8.4%) |

---

## ✅ Resolved — Airport Code Mismatch

**Status:** RESOLVED in v0.4.0

`flights_raw` used DOT numeric codes (e.g. 10423) not present in `airports_raw`.

| Stage | Result |
|-------|--------|
| Codes identified | 306 unique DOT codes |
| Flights affected | 486,165 (8.4%) |
| Resolved automatically | 302 codes via BTS description match |
| Resolved manually | 4 codes (civil/military shared airports) |
| Final NULL airport IDs | 0 |

**Resolution:** Built `etl.airport_dot_iata_map` by crossing `L_AIRPORT_ID.csv`
with `L_AIRPORT.csv` on description. Updated `usp_load_silver_flight` to
translate DOT codes to IATA via `COALESCE`.

Manual mappings for civil/military airports:

| dot_code | iata_code | Airport |
|----------|-----------|---------|
| 10170 | ADQ | Kodiak, AK |
| 10423 | AUS | Austin, TX |
| 12173 | HNL | Honolulu, HI |
| 16218 | YUM | Yuma, AZ |

---

## ✅ Resolved — fct_flights Unique Constraint

**Status:** RESOLVED in v0.4.0

Added `UNIQUE NULLS NOT DISTINCT` constraint on natural key:
```
date_id + airline_id + flight_number + origin_airport_id + destination_airport_id
```

Updated `usp_load_gold_fct_flights` with `ON CONFLICT DO NOTHING`.

---

## ✅ Resolved — Indexes on fct_flights

**Status:** RESOLVED in v0.5.0

Added 7 BTREE indexes on `gold.fct_flights` covering the most frequently
filtered and grouped columns for reporting queries.

---

## ✅ Resolved — Unit and Integration Tests

**Status:** RESOLVED in v0.5.0

Added 22 unit tests for Pandera validators and 33 integration tests
validating Bronze → Silver → Gold pipeline correctness.
