-- ==============================================
-- MIGRATION: Add Done column to Mellow Products
-- ==============================================
-- Adds a boolean `done` column to mellow_products to control true or false values.
-- Safe to re-run.
-- Date: 2026
-- ==============================================

-- ==============================================
-- STEP 1: Add the done column
-- ==============================================
ALTER TABLE mellow_products
  ADD COLUMN IF NOT EXISTS done BOOLEAN DEFAULT false;

COMMENT ON COLUMN mellow_products.done IS
  'Indicates if the product is done/completed (true/false).';

-- ==============================================
-- STEP 2: Verify
-- ==============================================
SELECT 'Migration completed successfully!' AS status;
SELECT 'mellow_products now has a done column.' AS message;
