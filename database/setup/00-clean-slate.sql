-- ==============================================
-- CLEAN SLATE - DROP ALL TABLES
-- ==============================================
-- ⚠️ WARNING: This will DELETE ALL DATA! ⚠️
-- Only run this if you want to start completely fresh
-- Recommended: Backup your data before running this script
-- ==============================================

-- ==============================================
-- STEP 1: Drop all views first (dependencies)
-- ==============================================

DROP VIEW IF EXISTS order_details CASCADE;
DROP VIEW IF EXISTS order_totals CASCADE;
DROP VIEW IF EXISTS expense_details CASCADE;
DROP VIEW IF EXISTS expense_summary_by_category CASCADE;
DROP VIEW IF EXISTS expense_summary_by_month CASCADE;
DROP VIEW IF EXISTS expense_summary_by_supplier CASCADE;
DROP VIEW IF EXISTS income_with_orders CASCADE;
DROP VIEW IF EXISTS income_summary_by_category CASCADE;
DROP VIEW IF EXISTS income_summary_by_month CASCADE;
DROP VIEW IF EXISTS income_summary_by_day CASCADE;
DROP VIEW IF EXISTS profit_loss_summary CASCADE;
DROP VIEW IF EXISTS business_performance CASCADE;

-- ==============================================
-- STEP 2: Drop all triggers (if tables exist)
-- ==============================================

DO $$
BEGIN
  -- Only drop triggers if the tables exist
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'expenses') THEN
    DROP TRIGGER IF EXISTS trigger_update_product_from_expense ON expenses CASCADE;
    DROP TRIGGER IF EXISTS update_expenses_updated_at ON expenses CASCADE;
  END IF;

  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'income') THEN
    DROP TRIGGER IF EXISTS update_income_updated_at ON income CASCADE;
  END IF;

  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'orders') THEN
    DROP TRIGGER IF EXISTS trigger_create_income_from_order ON orders CASCADE;
  END IF;
END $$;

-- ==============================================
-- STEP 3: Drop all functions
-- ==============================================

DROP FUNCTION IF EXISTS migrate_existing_orders() CASCADE;
DROP FUNCTION IF EXISTS migrate_legacy_orders() CASCADE;
DROP FUNCTION IF EXISTS update_product_cost_from_expense() CASCADE;
DROP FUNCTION IF EXISTS create_income_from_order() CASCADE;
DROP FUNCTION IF EXISTS get_expense_stats(DATE, DATE) CASCADE;
DROP FUNCTION IF EXISTS get_income_stats(DATE, DATE) CASCADE;
DROP FUNCTION IF EXISTS get_profit_loss(DATE, DATE) CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- ==============================================
-- STEP 4: Drop all tables (in correct order due to foreign keys)
-- ==============================================

-- Drop tables with foreign key dependencies first
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS income CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS orders CASCADE;

-- Drop standalone tables
DROP TABLE IF EXISTS expense_categories CASCADE;
DROP TABLE IF EXISTS income_categories CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==============================================
-- STEP 5: Verification
-- ==============================================

-- Check that all tables are gone
SELECT 'Checking remaining tables...' as step;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check that all views are gone
SELECT 'Checking remaining views...' as step;
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check that all functions are gone
SELECT 'Checking remaining functions...' as step;
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT '✅ Database cleaned successfully!' as status;
SELECT '⚠️ All tables, views, and functions have been dropped.' as message;
SELECT '📝 You can now run the complete setup script to rebuild everything.' as next_step;
