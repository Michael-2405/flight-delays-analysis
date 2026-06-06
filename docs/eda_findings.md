# EDA Findings — Bronze Layer

## airlines_raw
- 14 rows — clean, no nulls, no duplicates, no whitespace issues
- Ready for Silver with minor rename: `airline` → `airline_name`

## airports_raw
- 322 rows
- 3 airports with NULL latitude/longitude: ECP, PBG, UST
- Decision: keep NULLs in Silver — coordinates are optional context

## flights_raw
- 5,819,079 rows
- All data from 2015 — all 12 months present

### Nulls
- `tail_number`: 14,721 nulls — acceptable, no dim_aircraft
- `departure_delay`: 86,153 nulls — correlate with cancelled=1
- `arrival_delay`: 105,071 nulls — correlate with cancelled=1
- `cancellation_reason`: 5,729,195 nulls — expected (not cancelled)
- Delay breakdown columns: 4,755,640 nulls — expected (no delay recorded)

### Duplicates
- 1 case: AA803 on 2015-08-29 appears twice
- Not a true duplicate — same flight number, different destinations (STT→CLT and STT→SJU)
- Natural key must include destination_airport

### Business rules validation
- cancelled=1 AND cancellation_reason IS NULL: 0 violations ✅
- cancelled=0 AND cancellation_reason IS NOT NULL: 0 violations ✅

### Delay ranges
- departure_delay: min=-82, max=1988, avg=9.37 — valid range
- arrival_delay: min=-87, max=1971, avg=4.41 — valid range

### ⚠️ Technical Debt — Airport Code Mismatch
- flights_raw uses DOT numeric codes for some airports (e.g. 10135, 10136)
- airports_raw only contains 322 IATA 3-letter codes
- Affected flights: 486,165 (8.4% of total)
- Affected airports: 306 unique numeric codes
- All major airlines affected (WN, AA, DL, OO, UA...)
- Decision: proceed with Silver using known 322 airports
- Future task: enrich airports_raw with DOT→IATA mapping from BTS
- Source: https://www.transtats.bts.gov

## ⚠️ Technical Debt — fct_flights unique constraint pending

Natural key for fct_flights:
date_id + airline_id + flight_number + origin_airport_id + destination_airport_id

Cannot be implemented until airport enrichment is complete.
486,165 flights have NULL origin/destination airport IDs due to
DOT numeric codes not present in dim_airport.

Resolution: after enriching dim_airport with BTS DOT→IATA mapping,
add UNIQUE constraint and change INSERT to ON CONFLICT DO NOTHING.
