# EDA Findings — Bronze Layer

**Version:** 1.1
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

**Airports with NULL coordinates:**

| iata_code | airport | city | state |
|-----------|---------|------|-------|
| ECP | Northwest Florida Beaches International Airport | Panama City | FL |
| PBG | Plattsburgh International Airport | Plattsburgh | NY |
| UST | Northeast Florida Regional Airport | St. Augustine | FL |

**Decision:** Keep NULLs in Silver — coordinates are optional context, not business keys.

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
| `air_system_delay` | 4,755,640 | 81.73% | Expected — no delay recorded |
| `weather_delay` | 4,755,640 | 81.73% | Expected — no delay recorded |

### Delay Ranges

| Metric | Min | Max | Avg |
|--------|-----|-----|-----|
| `departure_delay` | -82 min | 1,988 min | 9.37 min |
| `arrival_delay` | -87 min | 1,971 min | 4.41 min |

Both ranges are valid. Max ~33 hours plausible during airspace closures.

### Business Rules Validation

| Rule | Violations |
|------|------------|
| `cancelled = 1` AND `cancellation_reason IS NULL` | 0 ✅ |
| `cancelled = 0` AND `cancellation_reason IS NOT NULL` | 0 ✅ |

### Duplicate Analysis

One case found: AA803 on 2015-08-29 from STT appears twice.

| flight_number | origin | destination | cancelled | reason |
|---------------|--------|-------------|-----------|--------|
| 803 | STT | CLT | 1 | A |
| 803 | STT | SJU | 1 | A |

**Conclusion:** Not a true duplicate — same flight number used for two different routes. Natural key must include `destination_airport`.

**Natural key:** `year + month + day + airline + flight_number + origin_airport + destination_airport`

### Referential Integrity

| Check | Result |
|-------|--------|
| Airline codes not in `airlines_raw` | 0 ✅ |
| Airport codes not in `airports_raw` | 306 unique numeric DOT codes |
| Flights affected | 486,165 (8.4% of total) |
| Airlines affected | All major carriers (WN, AA, DL, OO, UA...) |

---

## ⚠️ Technical Debt — Airport Code Mismatch

`flights_raw` uses DOT numeric codes for some airports (e.g. 10135, 10136) that are not present in `airports_raw` which only contains IATA 3-letter codes.

| Metric | Value |
|--------|-------|
| Affected flights | 486,165 (8.4%) |
| Unique numeric codes | 306 |
| Airlines affected | 13 of 14 |

**Decision:** Proceed with Silver and Gold using known 322 airports. Affected flights will have NULL `origin_airport_id` and `destination_airport_id` in `fct_flights`.

**Resolution plan:**
1. Download DOT→IATA mapping from BTS: https://www.transtats.bts.gov
2. Enrich `bronze.airports_raw` with 306 missing airports
3. Re-run Silver and Gold pipelines
4. Add UNIQUE constraint to `fct_flights`

---

## ⚠️ Technical Debt — fct_flights Unique Constraint Pending

Natural key for `fct_flights`:
```
date_id + airline_id + flight_number + origin_airport_id + destination_airport_id
```

Cannot be implemented until airport enrichment is complete. 486,165 flights have NULL `origin_airport_id` and `destination_airport_id` due to DOT numeric codes not present in `dim_airport`.

**Resolution:** After enriching `dim_airport` with BTS DOT→IATA mapping, add UNIQUE constraint and change INSERT to `ON CONFLICT DO NOTHING`.
