## Anomaly Analysis

### Insert Anomaly
**Example from orders_flat.csv:**
The flat file stores customer and order data together in the same row. This means it is impossible to add a new customer to the system unless they have already placed at least one order. For example, if a new customer "Meera Kapoor" from Pune registers on the website but hasn't ordered yet, we cannot record her in the database at all — because every row **requires** an `order_id`, `product_id`, `unit_price`, `quantity`, and `order_date`. We would have to insert dummy/NULL values across order columns just to store her contact details. This is a direct consequence of mixing customer data (`customer_id`, `customer_name`, `customer_email`, `customer_city`) with order data in a single flat table.

---

### Update Anomaly
**Example from orders_flat.csv:**
Sales rep `SR01` (Deepak Joshi) has their `office_address` stored in every row of every order they handled. Scanning the actual CSV data, this address appears in **two different forms** across rows: `"Mumbai HQ, Nariman Point, Mumbai - 400021"` (in rows ORD1114, ORD1153, ORD1083, etc.) and the abbreviated `"Mumbai HQ, Nariman Pt, Mumbai - 400021"` (in rows ORD1180, ORD1173, ORD1170, etc.). This is a real update anomaly in the dataset — a partial update to SR01's address propagated inconsistently, leaving contradictory values in the same column for the same sales rep.

---

### Delete Anomaly
**Example from orders_flat.csv:**
Product `P008` (Webcam, Electronics, ₹2,100) appears in exactly **one row** in the entire dataset — `ORD1185` (placed by Amit Verma, Bangalore). If this order is cancelled and the row is deleted, **all knowledge of the Webcam product is permanently erased** from the database — its product ID, category, and unit price — even though the business may still carry and sell it. Because product master data is stored only as part of order rows, deleting the last remaining order that references a product destroys the product record entirely.

---

## Normalization Justification

Your manager's claim that keeping everything in one flat table is "simpler" may seem intuitive at first glance — fewer tables mean fewer JOINs, and the structure is immediately understandable to non-technical staff. However, this argument fundamentally misunderstands what "simplicity" costs at scale, and the actual data in `orders_flat.csv` makes this cost concrete and undeniable.

The most damning evidence is already present in the dataset itself. Sales rep `SR01` (Deepak Joshi) has two different `office_address` values across his 60+ order rows — `"Mumbai HQ, Nariman Point"` and the truncated `"Mumbai HQ, Nariman Pt"`. This is not a hypothetical risk of update anomalies; it has already happened in this dataset. In a normalized schema, Deepak Joshi's address would be stored exactly once in a `sales_reps` table and referenced by a foreign key — making inconsistency structurally impossible.

Consider also the delete anomaly: product `P008` (Webcam) appears in only one order. In a retail business, the decision to delete a cancelled order is entirely routine. But in a flat file, that routine action silently destroys an entire product's master record. A products table that exists independently of orders — as 3NF demands — would preserve product data regardless of order history.

Finally, the insert anomaly means the business literally cannot record a new customer, a new product, or a new sales rep unless they are simultaneously attached to a completed order. This is not a minor inconvenience; it prevents the CRM team from building prospect pipelines and the inventory team from maintaining a product catalog.

Normalization is not over-engineering. It is the structural guarantee that data remains consistent, complete, and trustworthy over time. The one-time cost of designing 3NF tables is trivially small compared to the ongoing cost of debugging partial updates, recovering lost records, and explaining to management why the same sales rep has two different office addresses.
