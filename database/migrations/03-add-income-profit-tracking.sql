-- ==============================================
-- MIGRATION: Add Income & Profit Tracking
-- ==============================================
-- This migration adds income tracking and profit analytics
-- Date: 2025-10-24
-- ==============================================

-- ==============================================
-- STEP 1: Create income table
-- ==============================================

CREATE TABLE IF NOT EXISTS income (
  id BIGSERIAL PRIMARY KEY,

  -- Income details
  income_date DATE NOT NULL DEFAULT CURRENT_DATE,
  category TEXT NOT NULL,
  description TEXT NOT NULL,

  -- Order reference (optional - links to order if income is from sales)
  order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL,
  order_number TEXT,

  -- Financial information
  amount NUMERIC NOT NULL CHECK (amount >= 0),
  cost NUMERIC DEFAULT 0 CHECK (cost >= 0),
  profit NUMERIC GENERATED ALWAYS AS (amount - cost) STORED,

  -- Source information
  source TEXT,
  payment_method TEXT,
  payment_status TEXT NOT NULL DEFAULT 'Received',

  -- Additional details
  reference_number TEXT,
  notes TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================
-- STEP 2: Create income categories table
-- ==============================================

CREATE TABLE IF NOT EXISTS income_categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default income categories
INSERT INTO income_categories (name, description, icon, color) VALUES
  ('Product Sales', 'Revenue from product sales', '💰', '#10b981'),
  ('Service Revenue', 'Revenue from services', '🔧', '#3b82f6'),
  ('Commission', 'Commission income', '💵', '#8b5cf6'),
  ('Rental Income', 'Income from rentals', '🏢', '#f59e0b'),
  ('Interest', 'Interest income', '📈', '#14b8a6'),
  ('Investment Returns', 'Returns from investments', '💎', '#6366f1'),
  ('Consulting', 'Consulting fees', '👔', '#ec4899'),
  ('Affiliate Income', 'Affiliate marketing income', '🔗', '#f97316'),
  ('Royalties', 'Royalty income', '📚', '#84cc16'),
  ('Other Income', 'Miscellaneous income', '💸', '#64748b')
ON CONFLICT (name) DO NOTHING;

-- ==============================================
-- STEP 3: Add indexes for better performance
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_income_income_date ON income(income_date);
CREATE INDEX IF NOT EXISTS idx_income_category ON income(category);
CREATE INDEX IF NOT EXISTS idx_income_order_id ON income(order_id);
CREATE INDEX IF NOT EXISTS idx_income_payment_status ON income(payment_status);
CREATE INDEX IF NOT EXISTS idx_income_created_at ON income(created_at);

-- ==============================================
-- STEP 4: Add table and column comments
-- ==============================================

COMMENT ON TABLE income IS 'Track all business income and revenue streams';
COMMENT ON TABLE income_categories IS 'Predefined income categories for organization';

COMMENT ON COLUMN income.income_date IS 'Date the income was received or earned';
COMMENT ON COLUMN income.category IS 'Income category';
COMMENT ON COLUMN income.description IS 'Detailed description of the income';
COMMENT ON COLUMN income.order_id IS 'Reference to order (if income is from sales)';
COMMENT ON COLUMN income.amount IS 'Total income amount (revenue)';
COMMENT ON COLUMN income.cost IS 'Associated cost (for profit calculation)';
COMMENT ON COLUMN income.profit IS 'Calculated profit (amount - cost)';
COMMENT ON COLUMN income.source IS 'Source of income (customer, platform, etc.)';
COMMENT ON COLUMN income.payment_method IS 'How payment was received';
COMMENT ON COLUMN income.payment_status IS 'Payment status (Received, Pending, Partial)';

-- ==============================================
-- STEP 5: Enable Row Level Security
-- ==============================================

ALTER TABLE income ENABLE ROW LEVEL SECURITY;
ALTER TABLE income_categories ENABLE ROW LEVEL SECURITY;

-- Drop policies if they exist
DROP POLICY IF EXISTS "Allow all operations on income" ON income;
DROP POLICY IF EXISTS "Allow all operations on income_categories" ON income_categories;

-- Create RLS policies
CREATE POLICY "Allow all operations on income" ON income
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on income_categories" ON income_categories
  FOR ALL USING (true);

-- ==============================================
-- STEP 6: Create helpful views
-- ==============================================

-- View: Income with order details
CREATE OR REPLACE VIEW income_with_orders AS
SELECT
  i.id,
  i.income_date,
  i.category,
  i.description,
  i.order_id,
  i.order_number,
  o.customer_name,
  o.customer_email,
  i.amount,
  i.cost,
  i.profit,
  i.source,
  i.payment_method,
  i.payment_status,
  i.reference_number,
  i.notes,
  i.created_at
FROM income i
LEFT JOIN orders o ON i.order_id = o.id
ORDER BY i.income_date DESC, i.created_at DESC;

-- View: Income summary by category
CREATE OR REPLACE VIEW income_summary_by_category AS
SELECT
  category,
  COUNT(*) as transaction_count,
  SUM(amount) as total_revenue,
  SUM(cost) as total_cost,
  SUM(profit) as total_profit,
  AVG(profit) as avg_profit,
  MIN(income_date) as first_income,
  MAX(income_date) as last_income
FROM income
GROUP BY category
ORDER BY total_revenue DESC;

-- View: Monthly income summary
CREATE OR REPLACE VIEW income_summary_by_month AS
SELECT
  DATE_TRUNC('month', income_date) as month,
  COUNT(*) as transaction_count,
  SUM(amount) as total_revenue,
  SUM(cost) as total_cost,
  SUM(profit) as total_profit,
  AVG(profit) as avg_profit
FROM income
GROUP BY DATE_TRUNC('month', income_date)
ORDER BY month DESC;

-- View: Daily income summary
CREATE OR REPLACE VIEW income_summary_by_day AS
SELECT
  income_date,
  COUNT(*) as transaction_count,
  SUM(amount) as total_revenue,
  SUM(cost) as total_cost,
  SUM(profit) as total_profit
FROM income
GROUP BY income_date
ORDER BY income_date DESC;

-- View: Profit and loss summary
CREATE OR REPLACE VIEW profit_loss_summary AS
SELECT
  DATE_TRUNC('month', date) as period,
  SUM(revenue) as total_revenue,
  SUM(expenses) as total_expenses,
  SUM(revenue) - SUM(expenses) as net_profit,
  CASE
    WHEN SUM(expenses) > 0
    THEN ((SUM(revenue) - SUM(expenses)) / SUM(expenses)) * 100
    ELSE 0
  END as profit_margin
FROM (
  -- Income records
  SELECT
    income_date as date,
    amount as revenue,
    0 as expenses
  FROM income

  UNION ALL

  -- Expense records
  SELECT
    expense_date as date,
    0 as revenue,
    total_amount as expenses
  FROM expenses
) combined
GROUP BY DATE_TRUNC('month', date)
ORDER BY period DESC;

-- View: Overall business performance
CREATE OR REPLACE VIEW business_performance AS
SELECT
  COUNT(DISTINCT CASE WHEN amount > 0 THEN id END) as total_income_transactions,
  SUM(amount) as total_revenue,
  SUM(cost) as total_costs,
  SUM(profit) as total_profit,
  AVG(profit) as average_profit_per_transaction,
  MAX(profit) as highest_profit_transaction,
  MIN(profit) as lowest_profit_transaction,
  (SELECT SUM(total_amount) FROM expenses) as total_expenses,
  SUM(profit) - (SELECT COALESCE(SUM(total_amount), 0) FROM expenses) as net_business_profit
FROM income;

-- ==============================================
-- STEP 7: Create trigger to sync income from orders
-- ==============================================

-- Function to automatically create income record when order is marked complete
CREATE OR REPLACE FUNCTION create_income_from_order()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create income if order status is 'Completed' and no income exists yet
  IF NEW.status = 'Completed' AND (OLD.status IS NULL OR OLD.status != 'Completed') THEN
    -- Check if income already exists for this order
    IF NOT EXISTS (SELECT 1 FROM income WHERE order_id = NEW.id) THEN
      INSERT INTO income (
        income_date,
        category,
        description,
        order_id,
        order_number,
        amount,
        source,
        payment_status
      ) VALUES (
        COALESCE(NEW.order_date, NEW.created_at::date),
        'Product Sales',
        'Order #' || NEW.id || ' - ' || NEW.customer_name,
        NEW.id,
        '#' || NEW.id,
        NEW.total_amount,
        NEW.customer_name,
        'Received'
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger (optional - you can enable this later)
-- DROP TRIGGER IF EXISTS trigger_create_income_from_order ON orders;
-- CREATE TRIGGER trigger_create_income_from_order
--   AFTER INSERT OR UPDATE ON orders
--   FOR EACH ROW
--   EXECUTE FUNCTION create_income_from_order();

-- ==============================================
-- STEP 8: Create analytics functions
-- ==============================================

-- Function to get income statistics
CREATE OR REPLACE FUNCTION get_income_stats(
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL
)
RETURNS TABLE(
  total_transactions BIGINT,
  total_revenue NUMERIC,
  total_cost NUMERIC,
  total_profit NUMERIC,
  avg_profit NUMERIC,
  top_category TEXT,
  best_day DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT as total_transactions,
    COALESCE(SUM(i.amount), 0) as total_revenue,
    COALESCE(SUM(i.cost), 0) as total_cost,
    COALESCE(SUM(i.profit), 0) as total_profit,
    COALESCE(AVG(i.profit), 0) as avg_profit,
    (SELECT category FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE) GROUP BY category ORDER BY SUM(amount) DESC LIMIT 1) as top_category,
    (SELECT income_date FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE) GROUP BY income_date ORDER BY SUM(profit) DESC LIMIT 1) as best_day
  FROM income i
  WHERE i.income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- Function to get profit/loss for a period
CREATE OR REPLACE FUNCTION get_profit_loss(
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL
)
RETURNS TABLE(
  total_revenue NUMERIC,
  total_expenses NUMERIC,
  gross_profit NUMERIC,
  net_profit NUMERIC,
  profit_margin NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE((SELECT SUM(amount) FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0) as total_revenue,
    COALESCE((SELECT SUM(total_amount) FROM expenses WHERE expense_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0) as total_expenses,
    COALESCE((SELECT SUM(profit) FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0) as gross_profit,
    COALESCE((SELECT SUM(profit) FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0) -
    COALESCE((SELECT SUM(total_amount) FROM expenses WHERE expense_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0) as net_profit,
    CASE
      WHEN (SELECT SUM(amount) FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)) > 0
      THEN (
        (COALESCE((SELECT SUM(profit) FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0) -
         COALESCE((SELECT SUM(total_amount) FROM expenses WHERE expense_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE)), 0)) /
        (SELECT SUM(amount) FROM income WHERE income_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE))
      ) * 100
      ELSE 0
    END as profit_margin;
END;
$$ LANGUAGE plpgsql;

-- ==============================================
-- STEP 9: Add updated_at trigger
-- ==============================================

-- Create trigger for income table
DROP TRIGGER IF EXISTS update_income_updated_at ON income;

CREATE TRIGGER update_income_updated_at
  BEFORE UPDATE ON income
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ==============================================
-- STEP 10: Verification queries
-- ==============================================

-- Check if income table was created
SELECT 'Checking income table...' as step;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'income'
ORDER BY ordinal_position;

-- Check if income_categories table was created
SELECT 'Checking income_categories table...' as step;
SELECT * FROM income_categories ORDER BY name;

-- Check if indexes were created
SELECT 'Checking indexes...' as step;
SELECT indexname, tablename
FROM pg_indexes
WHERE tablename IN ('income', 'income_categories')
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- Check if views were created
SELECT 'Checking views...' as step;
SELECT table_name
FROM information_schema.views
WHERE table_name LIKE '%income%' OR table_name LIKE '%profit%'
ORDER BY table_name;

-- Check if functions were created
SELECT 'Checking functions...' as step;
SELECT routine_name
FROM information_schema.routines
WHERE (routine_name LIKE '%income%' OR routine_name LIKE '%profit%')
AND routine_schema = 'public'
ORDER BY routine_name;

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT 'Migration completed successfully!' as status;
SELECT 'Income and profit tracking has been added to your database.' as message;
SELECT 'You can now track revenue, calculate profits, and analyze business performance.' as next_step;
