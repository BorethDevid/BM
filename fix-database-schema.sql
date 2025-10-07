-- Fix Database Schema - Add Missing Columns
-- Run these queries in your Supabase SQL Editor to add the missing columns

-- ==============================================
-- STEP 1: ADD MISSING COLUMNS TO ORDERS TABLE
-- ==============================================

-- Add channel column to orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS channel TEXT;

-- Add location column to orders table  
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS location TEXT;

-- ==============================================
-- STEP 2: VERIFY COLUMNS WERE ADDED
-- ==============================================

-- Check if the columns exist
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND column_name IN ('channel', 'location')
ORDER BY column_name;

-- ==============================================
-- STEP 3: ADD COMMENTS FOR DOCUMENTATION
-- ==============================================

-- Add comments for the new columns
COMMENT ON COLUMN orders.channel IS 'Marketing channel where the order was placed (Facebook, Instagram, Telegram, TikTok)';
COMMENT ON COLUMN orders.location IS 'Delivery location - Cambodia province or city';

-- ==============================================
-- STEP 4: VERIFY COMPLETE TABLE STRUCTURE
-- ==============================================

-- Check the complete orders table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
ORDER BY ordinal_position;

-- ==============================================
-- TROUBLESHOOTING NOTES
-- ==============================================

-- If you still get errors after running the above queries:
-- 1. Make sure you're running these queries in the correct database
-- 2. Check that you have the necessary permissions to alter tables
-- 3. Verify the table name is exactly 'orders' (case-sensitive)
-- 4. Try running the queries one by one instead of all at once

-- ==============================================
-- ALTERNATIVE: DROP AND RECREATE (USE WITH CAUTION)
-- ==============================================

-- ONLY use this if the above doesn't work and you have no important data:
-- 
-- DROP TABLE IF EXISTS orders;
-- 
-- CREATE TABLE orders (
--   id BIGSERIAL PRIMARY KEY,
--   customer_name TEXT NOT NULL,
--   customer_email TEXT NOT NULL,
--   product_name TEXT NOT NULL,
--   quantity INTEGER NOT NULL,
--   unit_price NUMERIC NOT NULL,
--   total_amount NUMERIC NOT NULL,
--   status TEXT NOT NULL DEFAULT 'Pending',
--   channel TEXT,
--   location TEXT,
--   notes TEXT,
--   created_at TIMESTAMPTZ DEFAULT NOW()
-- );
-- 
-- ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
-- 
-- CREATE POLICY "Allow all operations on orders" ON orders
--   FOR ALL USING (true);
