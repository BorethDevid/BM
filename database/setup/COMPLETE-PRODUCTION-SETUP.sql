-- ==============================================
-- COMPLETE PRODUCTION SETUP
-- ==============================================
-- This script sets up the COMPLETE database from scratch
-- Includes: Base tables + Expenses + Income/Profit tracking
-- Run this AFTER running 00-clean-slate.sql
-- ==============================================

-- ==============================================
-- PART 1: CORE TABLES
-- ==============================================

-- Products table
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL CHECK (price >= 0),
  stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_name ON products(name);

COMMENT ON TABLE products IS 'Product catalog with inventory tracking';

-- Categories table
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE categories IS 'Product categories for organization';

-- Orders table
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  product_name TEXT,
  quantity INTEGER,
  unit_price NUMERIC,
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL DEFAULT 'Pending',
  channel TEXT,
  location TEXT,
  order_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orders_customer_name ON orders(customer_name);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_channel ON orders(channel);
CREATE INDEX idx_orders_location ON orders(location);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_created_at ON orders(created_at);

COMMENT ON TABLE orders IS 'Customer orders with support for both single and multi-product orders';

-- Order items table (multi-product support)
CREATE TABLE order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
  total_price NUMERIC NOT NULL CHECK (total_price >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_created_at ON order_items(created_at);

COMMENT ON TABLE order_items IS 'Individual products within an order - supports multiple products per order';

-- Users table
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_active ON users(is_active);

COMMENT ON TABLE users IS 'User authentication and authorization';

-- Insert default admin user (password: 1234)
INSERT INTO users (username, password_hash, role)
VALUES ('Admin', '1234', 'admin');

-- ==============================================
-- PART 2: EXPENSE TRACKING
-- ==============================================

-- Expense categories
CREATE TABLE expense_categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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
  ('Other', 'Miscellaneous expenses', '💰', '#64748b');

-- Expenses table
CREATE TABLE expenses (
  id BIGSERIAL PRIMARY KEY,
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
  product_name TEXT,
  quantity INTEGER CHECK (quantity > 0),
  unit_cost NUMERIC NOT NULL CHECK (unit_cost >= 0),
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
  supplier_name TEXT,
  supplier_contact TEXT,
  payment_method TEXT,
  payment_status TEXT NOT NULL DEFAULT 'Paid',
  receipt_number TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_product_id ON expenses(product_id);
CREATE INDEX idx_expenses_supplier_name ON expenses(supplier_name);
CREATE INDEX idx_expenses_payment_status ON expenses(payment_status);
CREATE INDEX idx_expenses_created_at ON expenses(created_at);

COMMENT ON TABLE expenses IS 'Track all business expenses including goods purchased for resale';

-- ==============================================
-- PART 3: INCOME & PROFIT TRACKING
-- ==============================================

-- Income categories
CREATE TABLE income_categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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
  ('Other Income', 'Miscellaneous income', '💸', '#64748b');

-- Income table
CREATE TABLE income (
  id BIGSERIAL PRIMARY KEY,
  income_date DATE NOT NULL DEFAULT CURRENT_DATE,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL,
  order_number TEXT,
  amount NUMERIC NOT NULL CHECK (amount >= 0),
  cost NUMERIC DEFAULT 0 CHECK (cost >= 0),
  profit NUMERIC GENERATED ALWAYS AS (amount - cost) STORED,
  source TEXT,
  payment_method TEXT,
  payment_status TEXT NOT NULL DEFAULT 'Received',
  reference_number TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_income_income_date ON income(income_date);
CREATE INDEX idx_income_category ON income(category);
CREATE INDEX idx_income_order_id ON income(order_id);
CREATE INDEX idx_income_payment_status ON income(payment_status);
CREATE INDEX idx_income_created_at ON income(created_at);

COMMENT ON TABLE income IS 'Track all business income and revenue streams';

-- ==============================================
-- PART 4: ROW LEVEL SECURITY
-- ==============================================

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE income ENABLE ROW LEVEL SECURITY;
ALTER TABLE income_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations on products" ON products FOR ALL USING (true);
CREATE POLICY "Allow all operations on categories" ON categories FOR ALL USING (true);
CREATE POLICY "Allow all operations on orders" ON orders FOR ALL USING (true);
CREATE POLICY "Allow all operations on order_items" ON order_items FOR ALL USING (true);
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);
CREATE POLICY "Allow all operations on expenses" ON expenses FOR ALL USING (true);
CREATE POLICY "Allow all operations on expense_categories" ON expense_categories FOR ALL USING (true);
CREATE POLICY "Allow all operations on income" ON income FOR ALL USING (true);
CREATE POLICY "Allow all operations on income_categories" ON income_categories FOR ALL USING (true);

-- ==============================================
-- PART 5: VIEWS
-- ==============================================

-- Order views
CREATE VIEW order_details AS
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
  oi.total_price
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
ORDER BY o.id DESC, oi.id;

CREATE VIEW order_totals AS
SELECT
  o.id as order_id,
  o.customer_name,
  o.customer_email,
  o.status,
  o.order_date,
  o.created_at,
  COUNT(oi.id) as item_count,
  COALESCE(SUM(oi.total_price), o.total_amount) as total_amount
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.customer_name, o.customer_email, o.status, o.order_date, o.created_at, o.total_amount
ORDER BY o.id DESC;

-- Expense views
CREATE VIEW expense_details AS
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

CREATE VIEW expense_summary_by_category AS
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

CREATE VIEW expense_summary_by_month AS
SELECT
  DATE_TRUNC('month', expense_date) as month,
  COUNT(*) as expense_count,
  SUM(total_amount) as total_spent,
  AVG(total_amount) as avg_expense
FROM expenses
GROUP BY DATE_TRUNC('month', expense_date)
ORDER BY month DESC;

CREATE VIEW expense_summary_by_supplier AS
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

-- Income views
CREATE VIEW income_with_orders AS
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

CREATE VIEW income_summary_by_category AS
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

CREATE VIEW income_summary_by_month AS
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

CREATE VIEW income_summary_by_day AS
SELECT
  income_date,
  COUNT(*) as transaction_count,
  SUM(amount) as total_revenue,
  SUM(cost) as total_cost,
  SUM(profit) as total_profit
FROM income
GROUP BY income_date
ORDER BY income_date DESC;

CREATE VIEW profit_loss_summary AS
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
  SELECT income_date as date, amount as revenue, 0 as expenses FROM income
  UNION ALL
  SELECT expense_date as date, 0 as revenue, total_amount as expenses FROM expenses
) combined
GROUP BY DATE_TRUNC('month', date)
ORDER BY period DESC;

CREATE VIEW business_performance AS
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
-- PART 6: FUNCTIONS
-- ==============================================

-- Updated_at trigger function
CREATE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Expense triggers
CREATE FUNCTION update_product_cost_from_expense()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.product_id IS NOT NULL AND NEW.quantity IS NOT NULL AND NEW.quantity > 0 THEN
    UPDATE products
    SET stock_quantity = stock_quantity + NEW.quantity
    WHERE id = NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_product_from_expense
  AFTER INSERT ON expenses
  FOR EACH ROW
  WHEN (NEW.product_id IS NOT NULL AND NEW.quantity IS NOT NULL)
  EXECUTE FUNCTION update_product_cost_from_expense();

CREATE TRIGGER update_expenses_updated_at
  BEFORE UPDATE ON expenses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Income triggers
CREATE TRIGGER update_income_updated_at
  BEFORE UPDATE ON income
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Analytics functions
CREATE FUNCTION get_expense_stats(
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

CREATE FUNCTION get_income_stats(
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

CREATE FUNCTION get_profit_loss(
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
-- PART 7: VERIFICATION
-- ==============================================

SELECT 'Checking tables...' as step;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;

SELECT 'Checking views...' as step;
SELECT table_name FROM information_schema.views WHERE table_schema = 'public' ORDER BY table_name;

SELECT 'Checking functions...' as step;
SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION' ORDER BY routine_name;

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT '✅ Production database setup completed successfully!' as status;
SELECT '🎉 All tables, views, and functions have been created.' as message;
SELECT '👤 Default admin user created (username: Admin, password: 1234)' as credentials;
SELECT '⚠️ IMPORTANT: Change the admin password immediately!' as warning;
