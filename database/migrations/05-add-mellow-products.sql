-- ==============================================
-- MIGRATION: Add Mellow Products
-- ==============================================
-- Creates the mellow_products table used by the "Mellow Product" page.
-- Stores product pricing breakdown (Yuan / USD) and two product images
-- (CN shop picture and bag picture) as data URLs in text columns.
-- Date: 2026
-- ==============================================

-- ==============================================
-- STEP 1: Create mellow_products table
-- ==============================================

CREATE TABLE IF NOT EXISTS mellow_products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  qty INTEGER DEFAULT 0,
  price_buy_yuan NUMERIC DEFAULT 0,           -- Price Buy ¥
  price_buy_usd NUMERIC DEFAULT 0,            -- Price Buy $
  price_delivery_usd NUMERIC DEFAULT 0,       -- Price Delivery $
  price_total_per_unit_usd NUMERIC DEFAULT 0, -- Price Total / Unit $
  price_sell_usd NUMERIC DEFAULT 0,           -- Price Sell $
  type_shop TEXT,                             -- Type Shop
  pic_cn_shop TEXT,                           -- Pic CN Shop (data URL)
  pic_bag TEXT,                               -- Pic Bag (data URL)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================
-- STEP 2: Add indexes
-- ==============================================

CREATE INDEX IF NOT EXISTS idx_mellow_products_name ON mellow_products(name);
CREATE INDEX IF NOT EXISTS idx_mellow_products_created_at ON mellow_products(created_at);

-- ==============================================
-- STEP 3: Add column comments
-- ==============================================

COMMENT ON TABLE mellow_products IS 'Mellow products with pricing breakdown and product images';
COMMENT ON COLUMN mellow_products.name IS 'Product name';
COMMENT ON COLUMN mellow_products.qty IS 'Quantity';
COMMENT ON COLUMN mellow_products.price_buy_yuan IS 'Buy price in Chinese Yuan (¥)';
COMMENT ON COLUMN mellow_products.price_buy_usd IS 'Buy price in USD ($)';
COMMENT ON COLUMN mellow_products.price_delivery_usd IS 'Delivery price in USD ($)';
COMMENT ON COLUMN mellow_products.price_total_per_unit_usd IS 'Total price per unit in USD ($)';
COMMENT ON COLUMN mellow_products.price_sell_usd IS 'Sell price in USD ($)';
COMMENT ON COLUMN mellow_products.type_shop IS 'Shop type / source';
COMMENT ON COLUMN mellow_products.pic_cn_shop IS 'CN shop picture stored as a data URL';
COMMENT ON COLUMN mellow_products.pic_bag IS 'Bag picture stored as a data URL';

-- ==============================================
-- STEP 4: Enable Row Level Security
-- ==============================================

ALTER TABLE mellow_products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all operations on mellow_products" ON mellow_products;

CREATE POLICY "Allow all operations on mellow_products" ON mellow_products
  FOR ALL USING (true);

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT 'Migration completed successfully!' as status;
SELECT 'mellow_products table is ready.' as message;
