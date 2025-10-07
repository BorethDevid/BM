-- Database Update Queries
-- Run these queries to add the new channel and location fields to existing tables

-- ==============================================
-- 1. UPDATE ORDERS TABLE
-- ==============================================

-- Add channel column to orders table
ALTER TABLE orders 
ADD COLUMN channel TEXT;

-- Add location column to orders table  
ALTER TABLE orders 
ADD COLUMN location TEXT;

-- Add comments for the new columns
COMMENT ON COLUMN orders.channel IS 'Marketing channel where the order was placed (Facebook, Instagram, Telegram, TikTok)';
COMMENT ON COLUMN orders.location IS 'Delivery location - Cambodia province or city';

-- ==============================================
-- 2. UPDATE ROW LEVEL SECURITY (RLS)
-- ==============================================

-- The existing RLS policies should automatically cover the new columns
-- No additional RLS policy changes needed since we're using "FOR ALL USING (true)"

-- ==============================================
-- 3. VERIFICATION QUERIES
-- ==============================================

-- Uncomment these queries to verify the changes were applied successfully:

-- Check if the new columns were added
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'orders' 
-- AND column_name IN ('channel', 'location')
-- ORDER BY column_name;

-- Check the complete table structure
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns 
-- WHERE table_name = 'orders' 
-- ORDER BY ordinal_position;

-- ==============================================
-- 4. OPTIONAL: ADD INDEXES FOR PERFORMANCE
-- ==============================================

-- Add indexes for the new columns if you plan to filter/search by them frequently
-- CREATE INDEX idx_orders_channel ON orders(channel);
-- CREATE INDEX idx_orders_location ON orders(location);

-- ==============================================
-- 5. SAMPLE DATA INSERT (Optional)
-- ==============================================

-- Example of how to insert data with the new fields:
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
--   notes
-- ) VALUES (
--   'John Doe',
--   'john@example.com',
--   'Sample Product',
--   2,
--   25.99,
--   51.98,
--   'Pending',
--   'Facebook',
--   'Phnom Penh',
--   'Sample order with new fields'
-- );

-- ==============================================
-- NOTES
-- ==============================================

-- 1. Both new columns are optional (nullable) so existing orders won't be affected
-- 2. The columns will be empty (NULL) for existing orders until updated
-- 3. New orders can include channel and location information
-- 4. The application will handle the new fields automatically
-- 5. No data migration is required - existing orders remain intact
