-- Q1.2 Schema Design

-- --------------------------------------------------------
CREATE TABLE customers (
    customer_id   VARCHAR(10)   PRIMARY KEY,
    customer_name VARCHAR(100)  NOT NULL,
    customer_city VARCHAR(100)  NOT NULL,
    customer_email VARCHAR(150) NOT NULL UNIQUE
);

-- --------------------------------------------------------
-- TABLE: sales_reps
-- Eliminates: Update anomaly (rep + address stored exactly once)
-- --------------------------------------------------------
CREATE TABLE sales_reps (
    rep_id         VARCHAR(10)  PRIMARY KEY,
    rep_name       VARCHAR(100) NOT NULL,
    rep_email      VARCHAR(150) NOT NULL UNIQUE,
    office_address VARCHAR(255) NOT NULL
);

-- --------------------------------------------------------
-- TABLE: products
-- Eliminates: Delete anomaly (products exist independently of orders)
-- --------------------------------------------------------
CREATE TABLE products (
    product_id   VARCHAR(10)    PRIMARY KEY,
    product_name VARCHAR(150)   NOT NULL,
    category     VARCHAR(100)   NOT NULL,
    unit_price   DECIMAL(10, 2) NOT NULL CHECK (unit_price > 0)
);

-- --------------------------------------------------------
-- TABLE: orders
-- References: customers, sales_reps
-- --------------------------------------------------------
CREATE TABLE orders (
    order_id    VARCHAR(15)  PRIMARY KEY,
    customer_id VARCHAR(10)  NOT NULL,
    rep_id      VARCHAR(10)  NOT NULL,
    product_id  VARCHAR(10)  NOT NULL,
    quantity    INT          NOT NULL CHECK (quantity > 0),
    order_date  DATE         NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (rep_id)      REFERENCES sales_reps(rep_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);

-- ============================================================
-- SAMPLE DATA — populated directly from orders_flat.csv
-- ============================================================

-- All 8 unique customers from the dataset
INSERT INTO customers (customer_id, customer_name, customer_city, customer_email) VALUES
('C001', 'Rohan Mehta',  'Mumbai',    'rohan@gmail.com'),
('C002', 'Priya Sharma', 'Delhi',     'priya@gmail.com'),
('C003', 'Amit Verma',   'Bangalore', 'amit@gmail.com'),
('C004', 'Sneha Iyer',   'Chennai',   'sneha@gmail.com'),
('C005', 'Vikram Singh', 'Mumbai',    'vikram@gmail.com'),
('C006', 'Neha Gupta',   'Delhi',     'neha@gmail.com'),
('C007', 'Arjun Nair',   'Bangalore', 'arjun@gmail.com'),
('C008', 'Kavya Rao',    'Hyderabad', 'kavya@gmail.com');

-- All 3 unique sales reps (single canonical address — fixes update anomaly)
INSERT INTO sales_reps (rep_id, rep_name, rep_email, office_address) VALUES
('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001');

-- All 8 unique products from the dataset
INSERT INTO products (product_id, product_name, category, unit_price) VALUES
('P001', 'Laptop',        'Electronics', 55000.00),
('P002', 'Mouse',         'Electronics',   800.00),
('P003', 'Desk Chair',    'Furniture',    8500.00),
('P004', 'Notebook',      'Stationery',    120.00),
('P005', 'Headphones',    'Electronics',  3200.00),
('P006', 'Standing Desk', 'Furniture',   22000.00),
('P007', 'Pen Set',       'Stationery',    250.00),
('P008', 'Webcam',        'Electronics',  2100.00);

-- Sample orders from the actual dataset (first 10 rows)
INSERT INTO orders (order_id, customer_id, rep_id, product_id, quantity, order_date) VALUES
('ORD1027', 'C002', 'SR02', 'P004', 4,  '2023-11-02'),
('ORD1114', 'C001', 'SR01', 'P007', 2,  '2023-08-06'),
('ORD1153', 'C006', 'SR01', 'P007', 3,  '2023-02-14'),
('ORD1002', 'C002', 'SR02', 'P005', 1,  '2023-01-17'),
('ORD1118', 'C006', 'SR02', 'P007', 5,  '2023-11-10'),
('ORD1132', 'C003', 'SR02', 'P007', 5,  '2023-03-07'),
('ORD1037', 'C002', 'SR03', 'P007', 2,  '2023-03-06'),
('ORD1075', 'C005', 'SR03', 'P003', 3,  '2023-04-18'),
('ORD1083', 'C006', 'SR01', 'P007', 2,  '2023-07-03'),
('ORD1091', 'C001', 'SR01', 'P006', 3,  '2023-07-24');
