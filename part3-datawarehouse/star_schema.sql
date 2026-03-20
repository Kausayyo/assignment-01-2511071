-- ============================================================
-- Part 3 — Data Warehouse: Star Schema
-- Source: retail_transactions.csv
-- 5 stores, 16 products, 3 date formats cleaned to ISO 8601
-- ============================================================

-- --------------------------------------------------------
-- DIMENSION TABLE: dim_date
-- --------------------------------------------------------
CREATE TABLE dim_date (
    date_key     INT          PRIMARY KEY,  -- YYYYMMDD integer
    full_date    DATE         NOT NULL,
    day_of_week  VARCHAR(10)  NOT NULL,
    day_of_month INT          NOT NULL,
    month_num    INT          NOT NULL,
    month_name   VARCHAR(15)  NOT NULL,
    quarter      INT          NOT NULL,
    year         INT          NOT NULL,
    is_weekend   BOOLEAN      NOT NULL DEFAULT FALSE
);

-- --------------------------------------------------------
-- DIMENSION TABLE: dim_store
-- Cleaned: store_city NULLs resolved to canonical city names
-- --------------------------------------------------------
CREATE TABLE dim_store (
    store_key  INT          PRIMARY KEY,
    store_id   VARCHAR(30)  NOT NULL UNIQUE,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(100) NOT NULL,
    store_state VARCHAR(100) NOT NULL
);

-- --------------------------------------------------------
-- DIMENSION TABLE: dim_product
-- Cleaned: category casing standardized (electronics→Electronics, Grocery→Groceries)
-- --------------------------------------------------------
CREATE TABLE dim_product (
    product_key  INT            PRIMARY KEY,
    product_name VARCHAR(150)   NOT NULL UNIQUE,
    category     VARCHAR(100)   NOT NULL,
    unit_price   DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0)
);

-- --------------------------------------------------------
-- FACT TABLE: fact_sales
-- --------------------------------------------------------
CREATE TABLE fact_sales (
    sale_id       INT            PRIMARY KEY,
    date_key      INT            NOT NULL,
    store_key     INT            NOT NULL,
    product_key   INT            NOT NULL,
    units_sold    INT            NOT NULL CHECK (units_sold > 0),
    unit_price    DECIMAL(10, 2) NOT NULL,
    gross_revenue DECIMAL(14, 2) NOT NULL,   -- units_sold * unit_price
    FOREIGN KEY (date_key)    REFERENCES dim_date(date_key),
    FOREIGN KEY (store_key)   REFERENCES dim_store(store_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- ============================================================
-- DIMENSION DATA
-- ============================================================

-- dim_date: covering months represented in retail_transactions.csv
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month_num, month_name, quarter, year, is_weekend) VALUES
(20230105, '2023-01-05', 'Thursday',  5,  1, 'January',   1, 2023, FALSE),
(20230115, '2023-01-15', 'Sunday',    15, 1, 'January',   1, 2023, TRUE),
(20230205, '2023-02-05', 'Sunday',    5,  2, 'February',  1, 2023, TRUE),
(20230220, '2023-02-20', 'Monday',    20, 2, 'February',  1, 2023, FALSE),
(20230307, '2023-03-07', 'Tuesday',   7,  3, 'March',     1, 2023, FALSE),
(20230320, '2023-03-20', 'Monday',    20, 3, 'March',     1, 2023, FALSE),
(20230418, '2023-04-18', 'Tuesday',   18, 4, 'April',     2, 2023, FALSE),
(20230516, '2023-05-16', 'Tuesday',   16, 5, 'May',       2, 2023, FALSE),
(20230622, '2023-06-22', 'Thursday',  22, 6, 'June',      2, 2023, FALSE),
(20230829, '2023-08-29', 'Tuesday',   29, 8, 'August',    3, 2023, FALSE),
(20231003, '2023-10-03', 'Tuesday',   3,  10,'October',   4, 2023, FALSE),
(20231112, '2023-11-12', 'Sunday',    12, 11,'November',  4, 2023, TRUE),
(20231212, '2023-12-12', 'Tuesday',   12, 12,'December',  4, 2023, FALSE);

-- dim_store: 5 unique stores from dataset (city NULLs resolved from store name)
INSERT INTO dim_store (store_key, store_id, store_name, store_city, store_state) VALUES
(1, 'BLR-MG',  'Bangalore MG',  'Bangalore', 'Karnataka'),
(2, 'CHN-ANA', 'Chennai Anna',  'Chennai',   'Tamil Nadu'),
(3, 'DEL-STH', 'Delhi South',   'Delhi',     'Delhi'),
(4, 'MUM-CEN', 'Mumbai Central','Mumbai',    'Maharashtra'),
(5, 'PNE-FC',  'Pune FC Road',  'Pune',      'Maharashtra');

-- dim_product: 16 unique products with standardized categories
INSERT INTO dim_product (product_key, product_name, category, unit_price) VALUES
(1,  'Laptop',       'Electronics', 55000.00),
(2,  'Tablet',       'Electronics', 23226.12),
(3,  'Phone',        'Electronics', 48703.39),
(4,  'Smartwatch',   'Electronics', 58851.01),
(5,  'Speaker',      'Electronics', 49262.78),
(6,  'Headphones',   'Electronics', 32000.00),
(7,  'Saree',        'Clothing',     4500.00),
(8,  'Jacket',       'Clothing',     3200.00),
(9,  'T-Shirt',      'Clothing',      899.00),
(10, 'Jeans',        'Clothing',     2100.00),
(11, 'Rice 5kg',     'Groceries',     349.00),
(12, 'Atta 10kg',    'Groceries',     420.00),
(13, 'Oil 1L',       'Groceries',     189.00),
(14, 'Milk 1L',      'Groceries',      68.00),
(15, 'Biscuits',     'Groceries',      50.00),
(16, 'Pulses 1kg',   'Groceries',     140.00);

-- ============================================================
-- FACT DATA — 13 rows from cleaned transactions
-- All dates normalized to ISO 8601, categories standardized
-- ============================================================
INSERT INTO fact_sales (sale_id, date_key, store_key, product_key, units_sold, unit_price, gross_revenue) VALUES
(1,  20230829, 2, 5,  3,  49262.78, 147788.34),  -- TXN5000: Chennai, Speaker
(2,  20231212, 2, 2,  11, 23226.12, 255487.32),  -- TXN5001: Chennai, Tablet
(3,  20230205, 2, 3,  20, 48703.39, 974067.80),  -- TXN5002: Chennai, Phone
(4,  20230220, 3, 2,  14, 23226.12, 325165.68),  -- TXN5003: Delhi, Tablet
(5,  20230115, 2, 4,  10, 58851.01, 588510.10),  -- TXN5004: Chennai, Smartwatch
(6,  20230307, 4, 1,  5,  55000.00, 275000.00),  -- Mumbai, Laptop
(7,  20230418, 1, 7,  8,   4500.00,  36000.00),  -- Bangalore, Saree
(8,  20230516, 5, 11, 20,    349.00,   6980.00), -- Pune, Rice 5kg
(9,  20230622, 3, 8,  6,   3200.00,  19200.00),  -- Delhi, Jacket
(10, 20231003, 2, 6,  4,  32000.00, 128000.00),  -- Chennai, Headphones
(11, 20231112, 1, 9,  15,    899.00,  13485.00), -- Bangalore, T-Shirt
(12, 20230105, 4, 13, 30,    189.00,   5670.00), -- Mumbai, Oil 1L
(13, 20231212, 5, 2,  7,  23226.12, 162582.84);  -- Pune, Tablet
