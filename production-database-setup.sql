-- Production Database Setup SQL
-- This file contains all the necessary CREATE TABLE statements for the production database
-- Run these statements in your production Supabase database to set up the required tables

-- ==============================================
-- 1. PRODUCTS TABLE
-- ==============================================
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================
-- 2. CATEGORIES TABLE
-- ==============================================
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================
-- 3. ORDERS TABLE
-- ==============================================
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC NOT NULL,
  total_amount NUMERIC NOT NULL,
  status TEXT NOT NULL DEFAULT 'Pending',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================
-- ROW LEVEL SECURITY (RLS) SETUP
-- ==============================================

-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for products table
CREATE POLICY "Allow all operations on products" ON products
  FOR ALL USING (true);

-- Create RLS policies for categories table
CREATE POLICY "Allow all operations on categories" ON categories
  FOR ALL USING (true);

-- Create RLS policies for orders table
CREATE POLICY "Allow all operations on orders" ON orders
  FOR ALL USING (true);

-- ==============================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ==============================================

-- Indexes for products table
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_stock_quantity ON products(stock_quantity);
CREATE INDEX idx_products_created_at ON products(created_at);

-- Indexes for categories table
CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_categories_created_at ON categories(created_at);

-- Indexes for orders table
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_product_name ON orders(product_name);

-- ==============================================
-- COMMENTS FOR DOCUMENTATION
-- ==============================================

-- Add table comments
COMMENT ON TABLE products IS 'Product inventory table storing product information and stock levels';
COMMENT ON TABLE categories IS 'Product categories for organizing products';
COMMENT ON TABLE orders IS 'Customer orders with product details and status tracking';

-- Add column comments for products table
COMMENT ON COLUMN products.id IS 'Unique identifier for the product';
COMMENT ON COLUMN products.name IS 'Product name';
COMMENT ON COLUMN products.price IS 'Product price in decimal format';
COMMENT ON COLUMN products.stock_quantity IS 'Current stock quantity available';
COMMENT ON COLUMN products.category IS 'Product category name';
COMMENT ON COLUMN products.created_at IS 'Timestamp when the product was created';

-- Add column comments for categories table
COMMENT ON COLUMN categories.id IS 'Unique identifier for the category';
COMMENT ON COLUMN categories.name IS 'Category name (must be unique)';
COMMENT ON COLUMN categories.description IS 'Optional description of the category';
COMMENT ON COLUMN categories.created_at IS 'Timestamp when the category was created';

-- Add column comments for orders table
COMMENT ON COLUMN orders.id IS 'Unique identifier for the order';
COMMENT ON COLUMN orders.customer_name IS 'Name of the customer placing the order';
COMMENT ON COLUMN orders.customer_email IS 'Email address of the customer';
COMMENT ON COLUMN orders.product_name IS 'Name of the product being ordered';
COMMENT ON COLUMN orders.quantity IS 'Quantity of the product ordered';
COMMENT ON COLUMN orders.unit_price IS 'Price per unit at the time of order';
COMMENT ON COLUMN orders.total_amount IS 'Total amount for the order (quantity * unit_price)';
COMMENT ON COLUMN orders.status IS 'Current status of the order (Pending, Processing, Shipped, Delivered, Cancelled)';
COMMENT ON COLUMN orders.notes IS 'Optional notes or special instructions for the order';
COMMENT ON COLUMN orders.created_at IS 'Timestamp when the order was created';

-- ==============================================
-- VERIFICATION QUERIES (Optional - for testing)
-- ==============================================

-- Uncomment these queries to verify the tables were created successfully:

-- SELECT table_name, column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name IN ('products', 'categories', 'orders') 
-- ORDER BY table_name, ordinal_position;

-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
-- FROM pg_policies 
-- WHERE tablename IN ('products', 'categories', 'orders');

-- SELECT indexname, tablename, indexdef 
-- FROM pg_indexes 
-- WHERE tablename IN ('products', 'categories', 'orders');
