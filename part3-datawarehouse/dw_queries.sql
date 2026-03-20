-- ============================================================
-- dw_queries.sql
-- Analytical queries for Part 3 — Data Warehouse
-- Run star_schema.sql first to create and populate tables
-- ============================================================

-- Q1: Total sales revenue by product category for each month
SELECT
    dd.year,
    dd.month_number,
    dd.month_name,
    dp.category,
    SUM(fs.gross_revenue)         AS total_gross_revenue,
    SUM(fs.net_revenue)           AS total_net_revenue,
    SUM(fs.quantity)              AS total_units_sold,
    ROUND(AVG(fs.unit_price), 2)  AS avg_unit_price
FROM fact_sales fs
JOIN dim_date    dd ON fs.date_key    = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY
    dd.year,
    dd.month_number,
    dd.month_name,
    dp.category
ORDER BY
    dd.year,
    dd.month_number,
    dp.category;

-- Q2: Top 2 performing stores by total revenue
SELECT
    ds.store_id,
    ds.store_name,
    ds.city,
    ds.region,
    SUM(fs.net_revenue)  AS total_net_revenue,
    SUM(fs.quantity)     AS total_units_sold,
    COUNT(fs.sale_id)    AS total_transactions
FROM fact_sales fs
JOIN dim_store ds ON fs.store_key = ds.store_key
GROUP BY
    ds.store_id,
    ds.store_name,
    ds.city,
    ds.region
ORDER BY total_net_revenue DESC
LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
SELECT
    dd.year,
    dd.month_number,
    dd.month_name,
    SUM(fs.net_revenue)  AS monthly_revenue,
    LAG(SUM(fs.net_revenue))
        OVER (ORDER BY dd.year, dd.month_number)  AS prev_month_revenue,
    ROUND(
        (SUM(fs.net_revenue)
         - LAG(SUM(fs.net_revenue)) OVER (ORDER BY dd.year, dd.month_number))
        / NULLIF(
            LAG(SUM(fs.net_revenue)) OVER (ORDER BY dd.year, dd.month_number),
            0
          ) * 100,
        2
    ) AS mom_growth_pct
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
GROUP BY
    dd.year,
    dd.month_number,
    dd.month_name
ORDER BY
    dd.year,
    dd.month_number;
