## Storage Systems

The hospital network's four goals require four distinct storage technologies, each chosen to match the nature of the data and the access pattern of the use case.

**Goal 1 — Predict patient readmission risk:** Historical treatment records (diagnoses, medications, lab results, procedures) are stored in a relational OLTP database (PostgreSQL) for transactional integrity. A nightly ETL pipeline extracts this data into a columnar analytical store (Amazon Redshift or BigQuery) that serves as the feature store for the ML model. The ML model itself (a gradient boosting classifier or LSTM) is trained on the warehoused data and served via a model registry (MLflow). PostgreSQL is chosen for OLTP because medical records require full ACID compliance — a partial write (e.g., a drug order without a dosage) could cause patient harm.

**Goal 2 — Plain-English queries over patient history:** A vector database (Pinecone or pgvector) stores dense embeddings of structured patient notes, discharge summaries, and clinical reports. When a doctor asks "Has this patient had a cardiac event before?", the query is embedded and the top-k semantically similar patient records are retrieved and passed to an LLM (via RAG) to generate a precise, cited response. This cannot be done with keyword search because clinical language is highly paraphrased.

**Goal 3 — Monthly management reports:** The data warehouse (Redshift/BigQuery) serves this goal directly. Pre-aggregated materialized views for bed occupancy, department-wise costs, and staff utilization are refreshed nightly and exposed via a BI tool (Tableau, Looker, or Power BI). Columnar storage enables fast GROUP BY and aggregation queries across millions of rows.

**Goal 4 — Real-time ICU vitals streaming:** Apache Kafka ingests high-frequency sensor streams (heart rate, SpO2, blood pressure) from bedside monitors. A stream processing engine (Apache Flink) applies real-time anomaly detection. Raw sensor data is archived to a time-series database (InfluxDB or TimescaleDB) for historical analysis, and critical alert events are pushed to the OLTP system and the clinical team's dashboard.

## OLTP vs OLAP Boundary

The transactional boundary ends at the PostgreSQL RDBMS layer. All writes from clinical systems — new admissions, prescriptions, test results, billing events — go into PostgreSQL, which guarantees ACID compliance and row-level locking for concurrent access by doctors, nurses, and billing staff.

The OLAP boundary begins at the data warehouse. A nightly ETL (or near-real-time CDC pipeline using Debezium) extracts changed records from PostgreSQL and loads them into Redshift/BigQuery in a star schema optimized for analytical queries. No ad-hoc analytical queries run against the OLTP system, preventing reporting workloads from degrading clinical application performance.

The ICU streaming pipeline straddles both: Flink performs real-time OLAP (windowed aggregations) on the Kafka stream, while archiving to InfluxDB for retrospective time-series analysis.

## Trade-offs

**Trade-off: Complexity of a Polyglot Persistence Architecture**

Using five different storage systems (PostgreSQL, Redshift, Pinecone, Kafka/InfluxDB, MLflow) introduces significant operational complexity: each system requires separate monitoring, backup, access control, and expertise. This raises the risk of data inconsistency across systems (e.g., a patient record updated in PostgreSQL may lag 24 hours before appearing in Redshift) and increases the total cost of infrastructure and DevOps staffing.

**Mitigation:** Implement a unified data catalog (Apache Atlas or AWS Glue Data Catalog) that tracks data lineage and schema across all systems. Use infrastructure-as-code (Terraform) to standardize deployment and monitoring. For the PostgreSQL → Redshift lag, evaluate a real-time CDC pipeline (Debezium + Kafka) to reduce analytical latency to minutes rather than hours. For the vector database, consider using `pgvector` as a PostgreSQL extension rather than a separate Pinecone cluster — this reduces the system count by one while keeping vector search within the familiar PostgreSQL operational envelope.
