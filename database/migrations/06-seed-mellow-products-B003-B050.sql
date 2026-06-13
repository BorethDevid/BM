-- ==============================================
-- SEED: Mellow Products B003 - B050
-- ==============================================
-- Inserts 48 mellow products named B003 through B050 (zero-padded to 3 digits).
-- Numeric pricing fields default to 0 and images are left NULL so they can be
-- filled in later from the "Mellow Product" page (Edit modal).
--
-- Requires: 05-add-mellow-products.sql (creates the mellow_products table).
-- Safe to re-run: skips any name that already exists.
-- Date: 2026
-- ==============================================

INSERT INTO mellow_products (
  name,
  qty,
  price_buy_yuan,
  price_buy_usd,
  price_delivery_usd,
  price_total_per_unit_usd,
  price_sell_usd,
  type_shop,
  pic_cn_shop,
  pic_bag
)
SELECT
  'B' || LPAD(g::text, 3, '0') AS name,
  0   AS qty,
  0   AS price_buy_yuan,
  0   AS price_buy_usd,
  0   AS price_delivery_usd,
  0   AS price_total_per_unit_usd,
  0   AS price_sell_usd,
  NULL AS type_shop,
  NULL AS pic_cn_shop,
  NULL AS pic_bag
FROM generate_series(3, 50) AS g
WHERE NOT EXISTS (
  SELECT 1 FROM mellow_products mp
  WHERE mp.name = 'B' || LPAD(g::text, 3, '0')
);

-- ==============================================
-- VERIFY
-- ==============================================
SELECT COUNT(*) AS seeded_count
FROM mellow_products
WHERE name BETWEEN 'B003' AND 'B050';

SELECT 'Seed completed: B003 - B050 inserted.' AS status;
