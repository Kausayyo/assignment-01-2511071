## Database Recommendation

For a healthcare startup building a patient management system, I would recommend **MySQL (RDBMS)** as the primary database — but with an important caveat that a hybrid architecture is likely the most pragmatic long-term choice.

**Why MySQL for the core patient management system:**

Healthcare data is fundamentally relational and deeply regulated. Patient records, diagnoses, prescriptions, lab results, and appointment histories have well-defined, consistent schemas — exactly the kind of structured data that relational databases were designed for. More critically, healthcare systems require full **ACID compliance** (Atomicity, Consistency, Isolation, Durability). Consider a transaction that records a drug dosage and simultaneously debits a patient's insurance coverage: if either step fails, the entire operation must roll back. Partial writes in medical records are not just bugs — they can be life-threatening. MySQL guarantees this. MongoDB, operating on **BASE** semantics (Basically Available, Soft-state, Eventually consistent), permits temporary inconsistency, which is unacceptable in clinical contexts.

From the **CAP theorem** perspective, MySQL prioritizes **Consistency and Partition Tolerance** (CP-leaning), meaning it will reject a write rather than allow inconsistent data to persist — the correct behavior for patient records. MongoDB is typically configured as AP (Available + Partition Tolerant), favouring availability over strict consistency.

Regulatory frameworks like HIPAA (US) and India's DPDP Act also implicitly favour systems with strong schema enforcement and audit logging — both natural strengths of RDBMS.

**Would the answer change for a fraud detection module?**

Yes — significantly. Fraud detection requires analyzing large volumes of unstructured behavioral data in real time: click patterns, transaction velocities, IP geolocation logs, and device fingerprints. This data is semi-structured, high-velocity, and highly variable in schema — a perfect fit for MongoDB or even a specialized event-streaming system like Apache Kafka combined with a graph database (e.g., Neo4j) for detecting relationship-based fraud patterns. For the fraud module alone, MongoDB's flexible document model and horizontal scalability make it the better choice.

**Recommended architecture:** MySQL for the core patient management system (ACID-compliant, relational, auditable), with MongoDB or a streaming store for the fraud detection and behavioral analytics layer. This hybrid approach uses each database where it excels.
