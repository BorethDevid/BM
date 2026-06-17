-- ============================================================
-- Migration 09: Add delivery price + yuan unit cost to expenses
-- ============================================================
-- Adds two columns to the expenses table:
--   * total_cost_yuan - the TOTAL goods cost entered in Chinese Yuan (¥),
--                       auto-converted to USD via the live rate; unit_cost
--                       is then derived as total_amount ($) / quantity
--   * delivery_cost   - delivery / shipping price in USD ($), added into
--                       total_amount (= total_cost $ + delivery_cost)
-- Safe to run multiple times.
-- ============================================================

ALTER TABLE expenses
  ADD COLUMN IF NOT EXISTS total_cost_yuan NUMERIC DEFAULT 0 CHECK (total_cost_yuan >= 0);

ALTER TABLE expenses
  ADD COLUMN IF NOT EXISTS delivery_cost NUMERIC DEFAULT 0 CHECK (delivery_cost >= 0);

COMMENT ON COLUMN expenses.total_cost_yuan IS 'Total goods cost entered in Chinese Yuan (¥); converted to USD via live FX rate, unit_cost = total_amount / quantity';
COMMENT ON COLUMN expenses.delivery_cost IS 'Delivery / shipping price in USD, included in total_amount';

-- ============================================================
-- Repoint expense product linkage from `products` to `mellow_products`.
-- The Add Expense form now sources its product list from mellow_products,
-- so expenses.product_id holds a mellow_products id. The old FK and the
-- stock trigger both target the legacy `products` table, so we remove them.
-- ============================================================

-- Old FK enforced product_id -> products(id); drop it so a mellow id can be stored.
ALTER TABLE expenses DROP CONSTRAINT IF EXISTS expenses_product_id_fkey;

-- Old trigger bumped products.stock_quantity; mellow_products uses `qty`,
-- so the trigger no longer applies. Remove trigger and its function.
DROP TRIGGER IF EXISTS trigger_update_product_from_expense ON expenses;
DROP FUNCTION IF EXISTS update_product_cost_from_expense();

COMMENT ON COLUMN expenses.product_id IS 'Reference to mellow_products(id) (if expense is for inventory purchase)';
