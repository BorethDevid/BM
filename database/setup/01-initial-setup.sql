-- ==============================================
-- INITIAL DATABASE SETUP
-- ==============================================
-- This script sets up the complete database schema for the Business Management System
-- Run this script ONCE when setting up a new database
-- Author: Business Management Team
-- Last Updated: 2025
-- ==============================================

-- ==============================================
-- 1. PRODUCTS TABLE
-- ==============================================
CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL CHECK (price >= 0),
  stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);

-- Add comments for documentation
COMMENT ON TABLE products IS 'Product catalog with inventory tracking';
COMMENT ON COLUMN products.name IS 'Product name';
COMMENT ON COLUMN products.price IS 'Product selling price';
COMMENT ON COLUMN products.stock_quantity IS 'Current stock quantity';
COMMENT ON COLUMN products.category IS 'Product category';

-- ==============================================
-- 2. CATEGORIES TABLE
-- ==============================================
CREATE TABLE IF NOT EXISTS categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments for documentation
COMMENT ON TABLE categories IS 'Product categories for organization';

-- ==============================================
-- 3. ORDERS TABLE
-- ==============================================
CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,

  -- Legacy single-product columns (kept for backward compatibility)
  product_name TEXT,
  quantity INTEGER,
  unit_price NUMERIC,

  -- Order information
  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL DEFAULT 'Pending',
  channel TEXT,
  location TEXT,
  order_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_customer_name ON orders(customer_name);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_channel ON orders(channel);
CREATE INDEX IF NOT EXISTS idx_orders_location ON orders(location);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- Add comments for documentation
COMMENT ON TABLE orders IS 'Customer orders with support for both single and multi-product orders';
COMMENT ON COLUMN orders.customer_name IS 'Customer name';
COMMENT ON COLUMN orders.customer_email IS 'Customer contact information';
COMMENT ON COLUMN orders.product_name IS 'Legacy single-product name (nullable for multi-product orders)';
COMMENT ON COLUMN orders.channel IS 'Marketing channel (Facebook, Instagram, Telegram, TikTok)';
COMMENT ON COLUMN orders.location IS 'Delivery location (Cambodia province/city)';
COMMENT ON COLUMN orders.order_date IS 'Custom order date (if null, use created_at)';

-- ==============================================
-- 4. ORDER ITEMS TABLE (Multi-Product Support)
-- ==============================================
CREATE TABLE IF NOT EXISTS order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
  total_price NUMERIC NOT NULL CHECK (total_price >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_created_at ON order_items(created_at);

-- Add comments for documentation
COMMENT ON TABLE order_items IS 'Individual products within an order - supports multiple products per order';
COMMENT ON COLUMN order_items.order_id IS 'Reference to parent order';
COMMENT ON COLUMN order_items.product_id IS 'Reference to product';
COMMENT ON COLUMN order_items.quantity IS 'Quantity ordered';
COMMENT ON COLUMN order_items.unit_price IS 'Price per unit at time of order';
COMMENT ON COLUMN order_items.total_price IS 'Total price (quantity * unit_price)';

-- ==============================================
-- 5. USERS TABLE (Authentication)
-- ==============================================
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- Add comments for documentation
COMMENT ON TABLE users IS 'User authentication and authorization';
COMMENT ON COLUMN users.password_hash IS 'Hashed password (never store plain text)';

-- Insert default admin user (password: 1234)
-- IMPORTANT: Change this password in production!
INSERT INTO users (username, password_hash, role)
VALUES ('Admin', '1234', 'admin')
ON CONFLICT (username) DO NOTHING;

-- ==============================================
-- 6. HELPFUL VIEWS
-- ==============================================

-- View: Order details with product information
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
  oi.total_price
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
ORDER BY o.id DESC, oi.id;

-- View: Order totals
CREATE OR REPLACE VIEW order_totals AS
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

-- ==============================================
-- 7. ROW LEVEL SECURITY (RLS)
-- ==============================================

-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow all operations on products" ON products;
DROP POLICY IF EXISTS "Allow all operations on categories" ON categories;
DROP POLICY IF EXISTS "Allow all operations on orders" ON orders;
DROP POLICY IF EXISTS "Allow all operations on order_items" ON order_items;
DROP POLICY IF EXISTS "Allow all operations on users" ON users;

-- Create policies (allow all operations - customize based on your needs)
CREATE POLICY "Allow all operations on products" ON products
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on categories" ON categories
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on orders" ON orders
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on order_items" ON order_items
  FOR ALL USING (true);

CREATE POLICY "Allow all operations on users" ON users
  FOR ALL USING (true);

-- ==============================================
-- 8. HELPER FUNCTIONS
-- ==============================================

-- Function to migrate legacy single-product orders to multi-product structure
CREATE OR REPLACE FUNCTION migrate_legacy_orders()
RETURNS void AS $$
DECLARE
  order_record RECORD;
  product_record RECORD;
BEGIN
  -- Loop through orders that have product_name but no order_items
  FOR order_record IN
    SELECT o.id, o.product_name, o.quantity, o.unit_price, o.total_amount
    FROM orders o
    WHERE o.product_name IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM order_items oi WHERE oi.order_id = o.id
    )
  LOOP
    -- Find the product by name
    SELECT id INTO product_record
    FROM products
    WHERE name = order_record.product_name
    LIMIT 1;

    -- If product found, create order_item
    IF product_record.id IS NOT NULL THEN
      INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
      VALUES (
        order_record.id,
        product_record.id,
        order_record.quantity,
        order_record.unit_price,
        order_record.total_amount
      );
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ==============================================
-- 9. VERIFICATION
-- ==============================================

-- Check all tables were created
SELECT 'Tables created successfully:' as status;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check all views were created
SELECT 'Views created successfully:' as status;
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================
SELECT 'Database setup completed successfully!' as status;
SELECT 'You can now start using the Business Management System.' as message;
