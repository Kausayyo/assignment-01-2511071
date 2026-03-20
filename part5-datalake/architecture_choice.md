## Architecture Recommendation

For a fast-growing food delivery startup collecting GPS location logs, customer text reviews, payment transactions, and restaurant menu images, I would recommend a **Data Lakehouse** architecture.

**Reason 1 — Multi-Modal, Mixed-Schema Data**

The startup's data spans four fundamentally different types: structured transactional data (payments), semi-structured text (reviews), time-series sensor data (GPS logs), and binary objects (menu images). A traditional Data Warehouse can only ingest structured, schema-on-write data — it cannot natively store raw GPS event streams or image files. A pure Data Lake can store all of these formats but lacks the query engine, ACID guarantees, and indexing needed for fast BI queries on payment data. A Data Lakehouse (e.g., built on Delta Lake, Apache Iceberg, or Databricks) provides schema enforcement where needed, schema-on-read flexibility for unstructured data, and a unified storage layer for all four data types — making it the only architecture that can handle all use cases without a complex multi-system setup.

**Reason 2 — Real-Time and Batch in One Platform**

GPS location logs are high-velocity, real-time streams. Payment transactions require low-latency processing for fraud detection. Customer reviews and menu images are ingested in batch. A Data Lakehouse, especially when paired with a streaming engine like Apache Spark Structured Streaming or Apache Flink, handles both paradigms on the same storage layer — eliminating the need to maintain separate Lambda architecture stacks.

**Reason 3 — Scalable Analytics Without Data Movement**

As the company scales, analysts will need to run SQL queries across all data types: "What delivery zones have the highest cancellation rates?" requires joining GPS logs with payment records and review sentiment scores. A Data Lakehouse exposes all raw and curated data through a SQL interface (e.g., Trino, Spark SQL, DuckDB) without requiring expensive ETL pipelines to copy data into a warehouse. This reduces pipeline complexity, data duplication costs, and latency between raw data ingestion and analytical availability.
