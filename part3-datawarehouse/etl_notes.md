## ETL Decisions

### Decision 1 — Standardizing Three Inconsistent Date Formats
**Problem:** The `date` column in `retail_transactions.csv` contained dates in three different formats across 300 rows: `DD/MM/YYYY` (e.g., `29/08/2023`), `DD-MM-YYYY` (e.g., `12-12-2023`), and ISO 8601 `YYYY-MM-DD` (e.g., `2023-02-05`). This made chronological sorting impossible and caused GROUP BY on month/year to produce incorrect results since string comparison of these mixed formats yields non-sensical ordering.

**Resolution:** A Python pre-processing step parsed all three formats using `dateutil.parser.parse()` and standardized every date to ISO 8601 (`YYYY-MM-DD`). A derived integer `date_key` in `YYYYMMDD` format (e.g., `20230829`) was computed for efficient integer-based joining with `dim_date`. The `dim_date` dimension table was pre-populated with all calendar attributes (month name, quarter, year, is_weekend flag) so that analytical queries can GROUP BY any time dimension without string manipulation.

---

### Decision 2 — Normalizing Inconsistent Category Casing and Spelling
**Problem:** The `category` column in `retail_transactions.csv` contained the same categories spelled differently across rows: `"electronics"` (lowercase), `"Electronics"` (title case), `"Grocery"` (singular), and `"Groceries"` (plural) all appeared in the 300-row dataset. A simple `GROUP BY category` would therefore return 4 separate buckets instead of 2, causing revenue totals for Electronics and Groceries to be split and reported incorrectly.

**Resolution:** A controlled vocabulary of exactly 3 canonical category names was defined: `'Electronics'`, `'Clothing'`, and `'Groceries'`. All raw values were uppercased and trimmed, then mapped to the canonical form: `"electronics"` → `'Electronics'`; `"Grocery"` → `'Groceries'`. These standardized values were stored in `dim_product.category`. No values required the `'Unknown'` fallback — every raw value mapped cleanly to one of the three canonical categories.

---

### Decision 3 — Resolving NULL Values in the store_city Column
**Problem:** The `store_city` column in `retail_transactions.csv` contained NULL/empty values for 19 out of 300 rows. These NULLs appeared specifically for three stores: `'Chennai Anna'`, `'Mumbai Central'`, and `'Pune FC Road'` — all of which had non-NULL city values in other rows of the same dataset. Loading these NULLs into `dim_store` would make city-based aggregations (`GROUP BY store_city`) incomplete and inaccurate.

**Resolution:** A lookup imputation strategy was applied: for each row with a NULL `store_city`, the correct city was inferred from the `store_name` value using a deterministic mapping built from non-NULL rows (`'Chennai Anna'` → `'Chennai'`, `'Mumbai Central'` → `'Mumbai'`, `'Pune FC Road'` → `'Pune'`). Since all five store names had unambiguous canonical cities verifiable from other rows in the same file, no external reference was needed. The `dim_store` dimension was then populated with fully resolved, non-NULL city values for all 5 stores.
