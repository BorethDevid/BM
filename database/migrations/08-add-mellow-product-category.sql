-- ==============================================
-- MIGRATION: Add category to Mellow Products
-- ==============================================
-- Adds a `category` column so products can be grouped (e.g. Bag, Shoes).
-- Existing rows default to 'bag', so the current 100 products become the
-- Bag category and the "Mellow Product" page can switch between categories.
--
-- Requires: 05-add-mellow-products.sql (creates the mellow_products table).
-- Safe to re-run.
-- Date: 2026
-- ==============================================

-- ==============================================
-- STEP 1: Add the category column
-- ==============================================

ALTER TABLE mellow_products
  ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT 'bag';

COMMENT ON COLUMN mellow_products.category IS
  'Product category key (lowercase), e.g. bag, shoes. Used to group/filter the list.';

-- ==============================================
-- STEP 2: Index for fast per-category filtering
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_mellow_products_category ON mellow_products(category);

-- ==============================================
-- STEP 3: Verify
-- ==============================================

SELECT category, COUNT(*) AS product_count
FROM mellow_products
GROUP BY category
ORDER BY category;

SELECT 'Migration completed successfully!' AS status;
SELECT 'mellow_products.category column is ready.' AS message;
