-- Complete Database Update Script
-- Run this script to add all missing columns to the orders table

-- ==============================================
-- 1. ADD MISSING COLUMNS
-- ==============================================

-- Add channel column if it doesn't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS channel TEXT;

-- Add location column if it doesn't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS location TEXT;

-- Add order_date column if it doesn't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS order_date DATE;

-- ==============================================
-- 2. ADD COMMENTS FOR DOCUMENTATION
-- ==============================================

COMMENT ON COLUMN orders.channel IS 'Marketing channel where the order was placed (Facebook, Instagram, Telegram, TikTok)';
COMMENT ON COLUMN orders.location IS 'Delivery location - Cambodia province or city';
COMMENT ON COLUMN orders.order_date IS 'Custom order date specified by user (optional)';

-- ==============================================
-- 3. ADD INDEXES FOR PERFORMANCE
-- ==============================================

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_channel ON orders(channel);
CREATE INDEX IF NOT EXISTS idx_orders_location ON orders(location);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);

-- ==============================================
-- 4. VERIFICATION QUERIES
-- ==============================================

-- Check if all columns exist
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND column_name IN ('channel', 'location', 'order_date')
ORDER BY column_name;

-- Check the complete table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
ORDER BY ordinal_position;

-- ==============================================
-- 5. SAMPLE DATA TEST (Optional)
-- ==============================================

-- Test insert with all new fields (uncomment to test)
-- INSERT INTO orders (
--   customer_name, 
--   customer_email, 
--   product_name, 
--   quantity, 
--   unit_price, 
--   total_amount, 
--   status, 
--   channel, 
--   location, 
--   order_date,
--   notes
-- ) VALUES (
--   'Test Customer',
--   'test@example.com',
--   'Test Product',
--   1,
--   10.00,
--   10.00,
--   'Pending',
--   'Facebook',
--   'Phnom Penh',
--   '2024-01-15',
--   'Test order with all fields'
-- );

-- ==============================================
-- NOTES
-- ==============================================

-- 1. All new columns are optional (nullable)
-- 2. Existing orders will have NULL values for new fields
-- 3. The application will handle missing columns gracefully
-- 4. Run this script in your Supabase SQL Editor
-- 5. No data will be lost - this only adds new columns
