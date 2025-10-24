-- ==============================================
-- MIGRATION: Add Multi-Product Order Support
-- ==============================================
-- This migration adds support for multiple products per order
-- Run this if you have an existing database that only supports single products
-- Date: 2025
-- ==============================================

-- ==============================================
-- STEP 1: Make legacy columns nullable
-- ==============================================
-- Allow product_name, quantity, and unit_price to be NULL
-- This enables multi-product orders via order_items table

ALTER TABLE orders
ALTER COLUMN product_name DROP NOT NULL;

ALTER TABLE orders
ALTER COLUMN quantity DROP NOT NULL;

ALTER TABLE orders
ALTER COLUMN unit_price DROP NOT NULL;

-- ==============================================
-- STEP 2: Add new columns to orders table
-- ==============================================

-- Add channel column for marketing channel tracking
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS channel TEXT;

-- Add location column for delivery location
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS location TEXT;

-- Add order_date column for custom order dates
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS order_date DATE DEFAULT CURRENT_DATE;

-- ==============================================
-- STEP 3: Create order_items table
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

-- ==============================================
-- STEP 4: Add indexes
-- ==============================================

-- Indexes for order_items table
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_created_at ON order_items(created_at);

-- Indexes for new orders columns
CREATE INDEX IF NOT EXISTS idx_orders_channel ON orders(channel);
CREATE INDEX IF NOT EXISTS idx_orders_location ON orders(location);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);

-- ==============================================
-- STEP 5: Add table and column comments
-- ==============================================

COMMENT ON TABLE order_items IS 'Individual products within an order - supports multiple products per order';
COMMENT ON COLUMN order_items.order_id IS 'Reference to parent order';
COMMENT ON COLUMN order_items.product_id IS 'Reference to product';
COMMENT ON COLUMN order_items.quantity IS 'Quantity ordered';
COMMENT ON COLUMN order_items.unit_price IS 'Price per unit at time of order';
COMMENT ON COLUMN order_items.total_price IS 'Total price (quantity * unit_price)';

COMMENT ON COLUMN orders.channel IS 'Marketing channel (Facebook, Instagram, Telegram, TikTok)';
COMMENT ON COLUMN orders.location IS 'Delivery location (Cambodia province/city)';
COMMENT ON COLUMN orders.order_date IS 'Custom order date (if null, use created_at)';

-- ==============================================
-- STEP 6: Enable Row Level Security
-- ==============================================

-- Enable RLS on order_items table
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Drop policy if it exists, then create it
DROP POLICY IF EXISTS "Allow all operations on order_items" ON order_items;

-- Create RLS policy
CREATE POLICY "Allow all operations on order_items" ON order_items
  FOR ALL USING (true);

-- ==============================================
-- STEP 7: Create helpful views
-- ==============================================

-- Drop views if they exist
DROP VIEW IF EXISTS order_details CASCADE;
DROP VIEW IF EXISTS order_totals CASCADE;

-- Create view for order details with product information
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

-- Create view for order totals
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

-- ==============================================
-- STEP 8: Migration helper function
-- ==============================================

-- Drop function if it exists
DROP FUNCTION IF EXISTS migrate_existing_orders();

-- Create function to migrate existing single-product orders
CREATE FUNCTION migrate_existing_orders()
RETURNS void AS $$
DECLARE
  order_record RECORD;
  product_record RECORD;
BEGIN
  -- Loop through existing orders that don't have order_items
  FOR order_record IN
    SELECT o.id, o.product_name, o.quantity, o.unit_price, o.total_amount
    FROM orders o
    WHERE NOT EXISTS (
      SELECT 1 FROM order_items oi WHERE oi.order_id = o.id
    )
    AND o.product_name IS NOT NULL
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
-- STEP 9: Verification queries
-- ==============================================

-- Check if constraints were removed
SELECT 'Checking orders table columns...' as step;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'orders'
AND column_name IN ('product_name', 'quantity', 'unit_price', 'channel', 'location', 'order_date')
ORDER BY column_name;

-- Check if order_items table was created
SELECT 'Checking order_items table...' as step;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'order_items'
ORDER BY ordinal_position;

-- Check if indexes were created
SELECT 'Checking indexes...' as step;
SELECT indexname, tablename
FROM pg_indexes
WHERE tablename IN ('order_items', 'orders')
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- Check if views were created
SELECT 'Checking views...' as step;
SELECT table_name
FROM information_schema.views
WHERE table_name IN ('order_details', 'order_totals');

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT 'Migration completed successfully!' as status;
SELECT 'Multi-product order support has been added to your database.' as message;
SELECT 'Run: SELECT migrate_existing_orders(); to migrate legacy orders to the new structure.' as next_step;
