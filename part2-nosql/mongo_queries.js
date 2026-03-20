// ============================================================
// Part 2.2 — MongoDB Operations
// Database: ecommerce_catalog
// Collection: products
// ============================================================

// ----- Switch to/create the database -----
use ecommerce_catalog;

// OP1: insertMany() — insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    _id: "PROD-ELEC-001",
    name: "Sony WH-1000XM5 Wireless Headphones",
    category: "Electronics",
    brand: "Sony",
    price: 29999,
    currency: "INR",
    stock: 45,
    specs: {
      battery_life_hours: 30,
      connectivity: ["Bluetooth 5.2", "3.5mm Jack"],
      noise_cancellation: true,
      voltage: "5V DC",
      warranty_years: 1,
      weight_grams: 250,
      color_options: ["Black", "Silver", "Midnight Blue"]
    },
    certifications: ["CE", "FCC", "BIS"],
    ratings: { average: 4.7, total_reviews: 1823 },
    tags: ["wireless", "noise-cancelling", "premium", "audio"],
    in_stock: true,
    created_at: new Date("2024-01-10T09:00:00Z")
  },
  {
    _id: "PROD-CLTH-001",
    name: "Men's Slim Fit Formal Shirt",
    category: "Clothing",
    brand: "Arrow",
    price: 1299,
    currency: "INR",
    stock: 200,
    specs: {
      fabric: "100% Cotton",
      fit_type: "Slim Fit",
      collar_type: "Spread Collar",
      sleeve: "Full Sleeve",
      wash_care: "Machine wash cold, do not bleach",
      available_sizes: ["S", "M", "L", "XL", "XXL"],
      available_colors: [
        { color: "White",      sku: "ARW-SHT-WHT" },
        { color: "Light Blue", sku: "ARW-SHT-LBL" },
        { color: "Navy",       sku: "ARW-SHT-NVY" }
      ]
    },
    occasion: ["Office", "Formal", "Party"],
    ratings: { average: 4.3, total_reviews: 542 },
    tags: ["formal", "cotton", "slim-fit", "office-wear"],
    in_stock: true,
    created_at: new Date("2024-02-15T10:30:00Z")
  },
  {
    _id: "PROD-GROC-001",
    name: "Organic Basmati Rice",
    category: "Groceries",
    brand: "Daawat",
    price: 349,
    currency: "INR",
    stock: 500,
    specs: {
      weight_kg: 5,
      grain_type: "Long Grain",
      organic_certified: true,
      country_of_origin: "India",
      shelf_life_months: 18,
      storage_instructions: "Store in a cool, dry place away from moisture",
      manufacturing_date: "2024-06-01",
      expiry_date: "2025-12-01"
    },
    nutritional_info: {
      serving_size_g: 100,
      calories: 356,
      protein_g: 7.5,
      carbohydrates_g: 78.2,
      fat_g: 0.6,
      fiber_g: 0.4,
      sodium_mg: 1
    },
    allergens: [],
    certifications: ["USDA Organic", "FSSAI"],
    ratings: { average: 4.5, total_reviews: 3210 },
    tags: ["organic", "basmati", "rice", "staple"],
    in_stock: true,
    created_at: new Date("2024-03-01T08:00:00Z")
  }
]);

// OP2: find() — retrieve all Electronics products with price > 20000
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    name: 1,
    category: 1,
    price: 1,
    brand: 1,
    "specs.warranty_years": 1
  }
);

// OP3: find() — retrieve all Groceries expiring before 2025-01-01
db.products.find(
  {
    category: "Groceries",
    "specs.expiry_date": { $lt: "2025-01-01" }
  },
  {
    name: 1,
    brand: 1,
    "specs.expiry_date": 1,
    "specs.manufacturing_date": 1,
    price: 1
  }
);

// OP4: updateOne() — add a "discount_percent" field to a specific product
db.products.updateOne(
  { _id: "PROD-ELEC-001" },
  {
    $set: {
      discount_percent: 10,
      discounted_price: 26999.10,
      discount_valid_until: new Date("2024-12-31T23:59:59Z")
    }
  }
);

// OP5: createIndex() — create an index on category field and explain why
// Reason: The 'category' field is the most common filter in product catalog queries
// (e.g., "show all Electronics", "filter by Groceries"). Without an index, MongoDB
// performs a full collection scan (O(n)) for every category-based query. With a
// single-field index on 'category', lookups become O(log n) using a B-tree structure,
// dramatically improving query performance as the catalog grows to millions of products.
// This is especially impactful for OP2 and OP3 which both filter on 'category'.
db.products.createIndex(
  { category: 1 },
  {
    name: "idx_category",
    background: true  // Build index without blocking other operations
  }
);

// Verify the index was created
db.products.getIndexes();

// Explain plan for OP2 to confirm index usage
db.products.find({ category: "Electronics", price: { $gt: 20000 } }).explain("executionStats");
