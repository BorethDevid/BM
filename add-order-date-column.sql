-- Add Order Date Column
-- Run this query to add the order_date field to the orders table

-- Add order_date column to orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS order_date DATE;

-- Add comment for documentation
COMMENT ON COLUMN orders.order_date IS 'Custom order date specified by user (optional)';

-- Create index for better performance when filtering by order date
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);

-- Verification query (optional - uncomment to test)
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'orders' 
-- AND column_name = 'order_date';

-- ==============================================
-- NOTES
-- ==============================================

-- 1. The order_date column is optional (nullable)
-- 2. If order_date is NULL, the system will use created_at for display
-- 3. Users can specify any date up to today (enforced by frontend)
-- 4. The column uses DATE type for better performance and storage
-- 5. An index is added for efficient date-based queries
