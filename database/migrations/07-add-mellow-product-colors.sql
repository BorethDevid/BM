-- ==============================================
-- MIGRATION: Add per-color quantity to Mellow Products
-- ==============================================
-- Adds a `colors` JSONB column to mellow_products so each product can record
-- the quantity (QTY) of each color. Products may have one or many colors.
--
-- Shape: an array of objects, e.g.
--   [{ "color": "Red", "qty": 5 }, { "color": "Blue", "qty": 3 }]
--
-- When a product has colors, its top-level `qty` is the sum of all color
-- quantities (kept in sync by the "Mellow Product" page). Products without a
-- color breakdown keep using `qty` directly, so existing rows are unaffected.
--
-- Requires: 05-add-mellow-products.sql (creates the mellow_products table).
-- Safe to re-run.
-- Date: 2026
-- ==============================================

-- ==============================================
-- STEP 1: Add the colors column
-- ==============================================

ALTER TABLE mellow_products
  ADD COLUMN IF NOT EXISTS colors JSONB NOT NULL DEFAULT '[]'::jsonb;

COMMENT ON COLUMN mellow_products.colors IS
  'Per-color quantity breakdown: array of { color: text, qty: int }. Sum equals qty.';

-- ==============================================
-- STEP 2: Verify
-- ==============================================

SELECT 'Migration completed successfully!' AS status;
SELECT 'mellow_products.colors column is ready.' AS message;
