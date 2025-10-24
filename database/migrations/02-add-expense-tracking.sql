-- ==============================================
-- MIGRATION: Add Expense Tracking
-- ==============================================
-- This migration adds expense tracking for goods purchased for resale
-- Date: 2025-10-24
-- ==============================================

-- ==============================================
-- STEP 1: Create expenses table
-- ==============================================

CREATE TABLE IF NOT EXISTS expenses (
  id BIGSERIAL PRIMARY KEY,

  -- Expense details
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  category TEXT NOT NULL,
  description TEXT NOT NULL,

  -- Product information (optional - for goods purchased for resale)
  product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
  product_name TEXT,
  quantity INTEGER CHECK (quantity > 0),

  -- Financial information
  unit_cost NUMERIC NOT NULL CHECK (unit_cost >= 0),
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),

  -- Supplier information
  supplier_name TEXT,
  supplier_contact TEXT,

  -- Payment information
  payment_method TEXT,
  payment_status TEXT NOT NULL DEFAULT 'Paid',

  -- Additional details
  receipt_number TEXT,
  notes TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================
-- STEP 2: Create expense categories table
-- ==============================================

CREATE TABLE IF NOT EXISTS expense_categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default expense categories
INSERT INTO expense_categories (name, description, icon, color) VALUES
  ('Inventory Purchase', 'Goods purchased for resale', '📦', '#3b82f6'),
  ('Raw Materials', 'Materials for production', '🏭', '#8b5cf6'),
  ('Shipping & Delivery', 'Shipping and delivery costs', '🚚', '#f59e0b'),
  ('Packaging', 'Packaging materials', '📦', '#10b981'),
  ('Marketing', 'Marketing and advertising expenses', '📢', '#ec4899'),
  ('Utilities', 'Electricity, water, internet', '💡', '#6366f1'),
  ('Rent', 'Office or warehouse rent', '🏢', '#ef4444'),
  ('Salaries', 'Employee salaries and wages', '👥', '#14b8a6'),
  ('Equipment', 'Equipment and tools', '🔧', '#f97316'),
  ('Other', 'Miscellaneous expenses', '💰', '#64748b')
ON CONFLICT (name) DO NOTHING;

-- ==============================================
-- STEP 3: Add indexes for better performance
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);
CREATE INDEX IF NOT EXISTS idx_expenses_product_id ON expenses(product_id);
CREATE INDEX IF NOT EXISTS idx_expenses_supplier_name ON expenses(supplier_name);
CREATE INDEX IF NOT EXISTS idx_expenses_payment_status ON expenses(payment_status);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at);

-- ==============================================
-- STEP 4: Add table and column comments
-- ==============================================

COMMENT ON TABLE expenses IS 'Track all business expenses including goods purchased for resale';
COMMENT ON TABLE expense_categories IS 'Predefined expense categories for organization';

COMMENT ON COLUMN expenses.expense_date IS 'Date of the expense';
COMMENT ON COLUMN expenses.category IS 'Expense category';
COMMENT ON COLUMN expenses.description IS 'Detailed description of the expense';
COMMENT ON COLUMN expenses.product_id IS 'Reference to product (if expense is for inventory purchase)';
COMMENT ON COLUMN expenses.product_name IS 'Product name (for reference, can differ from products table)';
COMMENT ON COLUMN expenses.quantity IS 'Quantity purchased (for inventory items)';
COMMENT ON COLUMN expenses.unit_cost IS 'Cost per unit';
COMMENT ON COLUMN expenses.total_amount IS 'Total expense amount';
COMMENT ON COLUMN expenses.supplier_name IS 'Supplier or vendor name';
COMMENT ON COLUMN expenses.supplier_contact IS 'Supplier contact information';
COMMENT ON COLUMN expenses.payment_method IS 'How the payment was made (Cash, Bank Transfer, Credit Card, etc.)';
COMMENT ON COLUMN expenses.payment_status IS 'Payment status (Paid, Pending, Partial)';
COMMENT ON COLUMN expenses.receipt_number IS 'Receipt or invoice number';

-- ==============================================
-- STEP 5: Enable Row Level Security
-- ==============================================

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;

-- Drop policies if they exist
DROP POLICY IF EXISTS "Allow all operations on expenses" ON expenses;
DROP POLICY IF EXISTS "Allow all operations on expense_categories" ON expense_categories;

-- Create RLS policies
CREATE POLICY "Allow all operations on expenses" ON expenses
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on expense_categories" ON expense_categories
  FOR ALL USING (true);

-- ==============================================
-- STEP 6: Create helpful views
-- ==============================================

-- View: Expense details with product information
CREATE OR REPLACE VIEW expense_details AS
SELECT
  e.id,
  e.expense_date,
  e.category,
  e.description,
  e.product_id,
  e.product_name,
  COALESCE(p.name, e.product_name) as actual_product_name,
  e.quantity,
  e.unit_cost,
  e.total_amount,
  e.supplier_name,
  e.supplier_contact,
  e.payment_method,
  e.payment_status,
  e.receipt_number,
  e.notes,
  e.created_at,
  e.updated_at
FROM expenses e
LEFT JOIN products p ON e.product_id = p.id
ORDER BY e.expense_date DESC, e.created_at DESC;

-- View: Expense summary by category
CREATE OR REPLACE VIEW expense_summary_by_category AS
SELECT
  category,
  COUNT(*) as expense_count,
  SUM(total_amount) as total_spent,
  AVG(total_amount) as avg_expense,
  MIN(expense_date) as first_expense,
  MAX(expense_date) as last_expense
FROM expenses
GROUP BY category
ORDER BY total_spent DESC;

-- View: Monthly expense summary
CREATE OR REPLACE VIEW expense_summary_by_month AS
SELECT
  DATE_TRUNC('month', expense_date) as month,
  COUNT(*) as expense_count,
  SUM(total_amount) as total_spent,
  AVG(total_amount) as avg_expense
FROM expenses
GROUP BY DATE_TRUNC('month', expense_date)
ORDER BY month DESC;

-- View: Supplier summary
CREATE OR REPLACE VIEW expense_summary_by_supplier AS
SELECT
  supplier_name,
  COUNT(*) as purchase_count,
  SUM(total_amount) as total_spent,
  AVG(total_amount) as avg_purchase,
  MAX(expense_date) as last_purchase
FROM expenses
WHERE supplier_name IS NOT NULL
GROUP BY supplier_name
ORDER BY total_spent DESC;

-- ==============================================
-- STEP 7: Create helper functions
-- ==============================================

-- Function to update product cost when expense is added
CREATE OR REPLACE FUNCTION update_product_cost_from_expense()
RETURNS TRIGGER AS $$
BEGIN
  -- If expense has a product_id and quantity, update the product's stock
  IF NEW.product_id IS NOT NULL AND NEW.quantity IS NOT NULL AND NEW.quantity > 0 THEN
    -- Update stock quantity (add purchased quantity)
    UPDATE products
    SET stock_quantity = stock_quantity + NEW.quantity
    WHERE id = NEW.product_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update product stock
DROP TRIGGER IF EXISTS trigger_update_product_from_expense ON expenses;

CREATE TRIGGER trigger_update_product_from_expense
  AFTER INSERT ON expenses
  FOR EACH ROW
  WHEN (NEW.product_id IS NOT NULL AND NEW.quantity IS NOT NULL)
  EXECUTE FUNCTION update_product_cost_from_expense();

-- Function to get expense statistics
CREATE OR REPLACE FUNCTION get_expense_stats(
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL
)
RETURNS TABLE(
  total_expenses BIGINT,
  total_amount NUMERIC,
  avg_expense NUMERIC,
  top_category TEXT,
  top_supplier TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT as total_expenses,
    COALESCE(SUM(e.total_amount), 0) as total_amount,
    COALESCE(AVG(e.total_amount), 0) as avg_expense,
    (SELECT category FROM expenses WHERE expense_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE) GROUP BY category ORDER BY SUM(total_amount) DESC LIMIT 1) as top_category,
    (SELECT supplier_name FROM expenses WHERE supplier_name IS NOT NULL AND expense_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE) GROUP BY supplier_name ORDER BY SUM(total_amount) DESC LIMIT 1) as top_supplier
  FROM expenses e
  WHERE e.expense_date BETWEEN COALESCE(start_date, '1900-01-01') AND COALESCE(end_date, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- ==============================================
-- STEP 8: Add updated_at trigger
-- ==============================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for expenses table
DROP TRIGGER IF EXISTS update_expenses_updated_at ON expenses;

CREATE TRIGGER update_expenses_updated_at
  BEFORE UPDATE ON expenses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ==============================================
-- STEP 9: Verification queries
-- ==============================================

-- Check if expenses table was created
SELECT 'Checking expenses table...' as step;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'expenses'
ORDER BY ordinal_position;

-- Check if expense_categories table was created
SELECT 'Checking expense_categories table...' as step;
SELECT * FROM expense_categories ORDER BY name;

-- Check if indexes were created
SELECT 'Checking indexes...' as step;
SELECT indexname, tablename
FROM pg_indexes
WHERE tablename IN ('expenses', 'expense_categories')
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- Check if views were created
SELECT 'Checking views...' as step;
SELECT table_name
FROM information_schema.views
WHERE table_name LIKE 'expense%';

-- Check if functions were created
SELECT 'Checking functions...' as step;
SELECT routine_name
FROM information_schema.routines
WHERE routine_name LIKE '%expense%'
AND routine_schema = 'public';

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT 'Migration completed successfully!' as status;
SELECT 'Expense tracking has been added to your database.' as message;
SELECT 'You can now track all business expenses including inventory purchases.' as next_step;
