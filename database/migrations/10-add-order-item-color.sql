-- ==============================================
-- MIGRATION: Order items use Mellow Products + per-item color
-- ==============================================
-- The order form now picks products from the `mellow_products` catalog and lets
-- the user choose a color for each product line. This migration:
--   1. Repoints order_items.product_id from products -> mellow_products, so a
--      selected mellow product can be saved (the old FK would reject it).
--   2. Adds order_items.color to record the chosen color per line.
--   3. Updates the order_details view to read product_name from mellow_products
--      and expose the new color column.
--
-- Requires: 01-add-multi-product-support.sql (order_items + order_details view)
--           05-add-mellow-products.sql / 07-add-mellow-product-colors.sql
-- Safe to re-run.
-- Date: 2026
-- ==============================================

-- ==============================================
-- STEP 1: Repoint the product foreign key to mellow_products
-- ==============================================
-- order_items.product_id should now reference mellow_products. Legacy rows that
-- point at the old `products` table have no equivalent mellow_products id and
-- would block the new constraint, so we remove those orphaned lines first.
--
-- WARNING: this permanently deletes order lines whose product_id is not a valid
-- mellow_products id. Orders left with no remaining lines are kept (they will
-- simply show no products); delete them separately if you don't want them.

ALTER TABLE order_items
  DROP CONSTRAINT IF EXISTS order_items_product_id_fkey;

DELETE FROM order_items
WHERE product_id NOT IN (SELECT id FROM mellow_products);

ALTER TABLE order_items
  ADD CONSTRAINT order_items_product_id_fkey
  FOREIGN KEY (product_id) REFERENCES mellow_products(id) ON DELETE CASCADE;

-- ==============================================
-- STEP 2: Add the color column
-- ==============================================

ALTER TABLE order_items
  ADD COLUMN IF NOT EXISTS color TEXT;

COMMENT ON COLUMN order_items.color IS
  'Chosen color for this line, from the mellow product''s color breakdown (nullable).';

-- ==============================================
-- STEP 3: Refresh the order_details view
-- ==============================================
-- Reads product_name from mellow_products and exposes the per-line color.

CREATE OR REPLACE VIEW order_details AS
SELECT
  o.id as order_id,
  o.customer_name,
  o.customer_email,
  o.status,
  o.channel,
  o.location,
  o.order_date,
  o.notes,
  o.created_at,
  oi.id as item_id,
  oi.product_id,
  p.name as product_name,
  oi.quantity,
  oi.unit_price,
  oi.total_price,
  oi.color
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN mellow_products p ON oi.product_id = p.id
ORDER BY o.id DESC, oi.id;

-- ==============================================
-- STEP 4: Verify
-- ==============================================

SELECT 'Migration completed successfully!' AS status;
SELECT 'order_items now references mellow_products and has a color column.' AS message;
