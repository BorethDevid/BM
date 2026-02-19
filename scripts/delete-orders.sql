-- ============================================================
-- delete-orders.sql
-- BM - Order Management: Delete Script
-- ============================================================
-- Run this directly in Supabase SQL Editor (Dashboard > SQL Editor)
--
-- HOW TO USE:
--   1. Open Supabase Dashboard → SQL Editor
--   2. Paste this file
--   3. Uncomment ONLY the block you want to run
--   4. Click "Run"
--
-- SAFETY TIP: Run the matching SELECT block first to preview
--             what will be deleted before executing DELETE.
-- ============================================================


-- ============================================================
-- SECTION 1: DELETE ALL ORDERS
-- Removes every order and all associated order items.
-- ============================================================

-- Preview first (run this to see what will be deleted):
-- SELECT id, customer_name, customer_email, status, total_amount, created_at
-- FROM orders
-- ORDER BY created_at DESC;

-- Then delete (uncomment to execute):
-- DELETE FROM order_items;
-- DELETE FROM orders;


-- ============================================================
-- SECTION 2: DELETE A SINGLE ORDER BY ID
-- Replace 0 with the actual order ID.
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, status, total_amount, created_at
-- FROM orders
-- WHERE id = 0;

-- Delete:
-- DELETE FROM order_items WHERE order_id = 0;
-- DELETE FROM orders      WHERE id       = 0;


-- ============================================================
-- SECTION 3: DELETE ORDERS BY STATUS
-- Valid values: 'Pending' | 'Processing' | 'Shipped' | 'Delivered' | 'Cancelled'
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, status, total_amount, created_at
-- FROM orders
-- WHERE status = 'Cancelled'
-- ORDER BY created_at DESC;

-- Delete:
-- DELETE FROM order_items
-- WHERE order_id IN (SELECT id FROM orders WHERE status = 'Cancelled');
--
-- DELETE FROM orders WHERE status = 'Cancelled';


-- ============================================================
-- SECTION 4: DELETE ORDERS CREATED BEFORE A DATE
-- Replace '2024-01-01' with your target cutoff date.
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, status, total_amount, created_at
-- FROM orders
-- WHERE created_at < '2024-01-01'
-- ORDER BY created_at DESC;

-- Delete:
-- DELETE FROM order_items
-- WHERE order_id IN (SELECT id FROM orders WHERE created_at < '2024-01-01');
--
-- DELETE FROM orders WHERE created_at < '2024-01-01';


-- ============================================================
-- SECTION 5: DELETE ORDERS WITHIN A DATE RANGE
-- Replace the dates with your desired range.
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, status, total_amount, created_at
-- FROM orders
-- WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31'
-- ORDER BY created_at DESC;

-- Delete:
-- DELETE FROM order_items
-- WHERE order_id IN (
--   SELECT id FROM orders
--   WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31'
-- );
--
-- DELETE FROM orders
-- WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';


-- ============================================================
-- SECTION 6: DELETE ORDERS BY CHANNEL
-- Valid values: 'Facebook' | 'Instagram' | 'Telegram' | 'TikTok'
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, channel, status, total_amount, created_at
-- FROM orders
-- WHERE channel = 'Facebook'
-- ORDER BY created_at DESC;

-- Delete:
-- DELETE FROM order_items
-- WHERE order_id IN (SELECT id FROM orders WHERE channel = 'Facebook');
--
-- DELETE FROM orders WHERE channel = 'Facebook';


-- ============================================================
-- SECTION 7: DELETE ORDERS BY LOCATION
-- Example: 'Phnom Penh'
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, location, status, total_amount, created_at
-- FROM orders
-- WHERE location = 'Phnom Penh'
-- ORDER BY created_at DESC;

-- Delete:
-- DELETE FROM order_items
-- WHERE order_id IN (SELECT id FROM orders WHERE location = 'Phnom Penh');
--
-- DELETE FROM orders WHERE location = 'Phnom Penh';


-- ============================================================
-- SECTION 8: DELETE ORDERS BY MULTIPLE CONDITIONS
-- Combine filters as needed.
-- ============================================================

-- Preview:
-- SELECT id, customer_name, customer_email, status, channel, total_amount, created_at
-- FROM orders
-- WHERE status  = 'Cancelled'
--   AND channel = 'Facebook'
--   AND created_at < '2024-06-01'
-- ORDER BY created_at DESC;

-- Delete:
-- DELETE FROM order_items
-- WHERE order_id IN (
--   SELECT id FROM orders
--   WHERE status  = 'Cancelled'
--     AND channel = 'Facebook'
--     AND created_at < '2024-06-01'
-- );
--
-- DELETE FROM orders
-- WHERE status  = 'Cancelled'
--   AND channel = 'Facebook'
--   AND created_at < '2024-06-01';


-- ============================================================
-- SECTION 9: RESET & RESTART IDs FROM 1  (use after --all)
-- Only run this after deleting ALL orders if you want IDs
-- to restart from 1.
-- ============================================================

-- ALTER SEQUENCE orders_id_seq      RESTART WITH 1;
-- ALTER SEQUENCE order_items_id_seq RESTART WITH 1;
