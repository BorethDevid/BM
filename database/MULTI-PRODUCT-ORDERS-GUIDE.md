# Multi-Product Orders Setup Guide

## Overview

This guide will help you implement the multi-product orders feature that allows customers to add multiple products to a single order instead of being limited to one product per order.

## What's New

### 🎯 Key Features
- **Multiple Products per Order**: Add as many products as needed to a single order
- **Dynamic Product Management**: Add/remove products with a user-friendly interface
- **Real-time Calculations**: Automatic total calculations for each product and overall order
- **Backward Compatibility**: Existing single-product orders continue to work
- **Enhanced UI**: Clean, intuitive interface for managing multiple products

### 🏗️ Database Changes
- **New Table**: `order_items` - stores individual products within an order
- **Enhanced Views**: `order_details` and `order_totals` for better data access
- **Migration Support**: Automatic migration of existing orders to new structure

## Setup Instructions

### Step 1: Database Migration

1. **Run the Migration Script**
   ```sql
   -- Execute the migration script in your Supabase SQL Editor
   -- File: multi-product-orders-migration.sql
   ```

2. **Verify Migration**
   ```sql
   -- Check if order_items table was created
   SELECT table_name, column_name, data_type 
   FROM information_schema.columns 
   WHERE table_name = 'order_items' 
   ORDER BY ordinal_position;
   ```

3. **Migrate Existing Data** (Optional)
   ```sql
   -- Run this to migrate existing single-product orders
   SELECT migrate_existing_orders();
   ```

### Step 2: Application Updates

The following files have been updated:

#### ✅ Updated Files
- **`pages/orders.vue`** - Complete rewrite with multi-product support
- **`multi-product-orders-migration.sql`** - Database migration script

#### 🔧 Key Changes Made

1. **Interface Updates**
   ```typescript
   interface Order {
     // ... existing fields
     items?: OrderItem[] // New: array of order items
   }

   interface OrderItem {
     id: number
     order_id: number
     product_id: number
     product_name: string
     quantity: number
     unit_price: number
     total_price: number
   }
   ```

2. **Form Structure**
   ```typescript
   const orderForm = reactive({
     // ... customer info
     items: [] as Array<{
       product_id: string
       product_name: string
       quantity: number
       unit_price: number
       total_price: number
     }>
   })
   ```

3. **New Functions**
   - `addProductItem()` - Add new product to order
   - `removeProductItem()` - Remove product from order
   - `updateItemTotal()` - Calculate item total
   - `getOrderTotal()` - Calculate overall order total
   - `isProductAlreadySelected()` - Prevent duplicate products

### Step 3: Testing the Implementation

#### Test Scenarios

1. **Create New Multi-Product Order**
   - Click "Add New Order"
   - Add customer information
   - Click "Add Product" to add multiple products
   - Verify totals calculate correctly
   - Save the order

2. **Edit Existing Order**
   - Open an existing order for editing
   - Add/remove products
   - Verify changes are saved correctly

3. **View Orders Table**
   - Check that multiple products display correctly
   - Verify total quantities and amounts

#### Expected Behavior

- ✅ **Add Products**: Click "Add Product" to add new products
- ✅ **Remove Products**: Click "Remove" to remove products (minimum 1 required)
- ✅ **Auto-calculations**: Totals update automatically when quantities/prices change
- ✅ **Product Validation**: Cannot select the same product twice
- ✅ **Order Summary**: Shows total items, quantities, and order total
- ✅ **Backward Compatibility**: Existing single-product orders still work

## Database Schema

### New Tables

#### `order_items`
```sql
CREATE TABLE order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),
  total_price NUMERIC NOT NULL CHECK (total_price >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### New Views

#### `order_details`
```sql
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
ORDER BY o.id, oi.id;
```

#### `order_totals`
```sql
CREATE OR REPLACE VIEW order_totals AS
SELECT 
  o.id as order_id,
  o.customer_name,
  o.customer_email,
  o.status,
  o.order_date,
  o.created_at,
  COUNT(oi.id) as item_count,
  COALESCE(SUM(oi.total_price), 0) as total_amount
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.customer_name, o.customer_email, o.status, o.order_date, o.created_at
ORDER BY o.id;
```

## UI Components

### Multi-Product Form Section
- **Product Items**: Dynamic list of products with individual controls
- **Add/Remove Buttons**: Easy product management
- **Real-time Totals**: Automatic calculation display
- **Order Summary**: Overview of total items and amounts

### Table Display
- **Multi-Product View**: Shows all products in an order
- **Quantity Totals**: Displays total quantities across all products
- **Backward Compatibility**: Handles both old and new order formats

## Troubleshooting

### Common Issues

1. **"Database schema error: Missing column"**
   - **Solution**: Run the migration script first
   - **Check**: Verify `order_items` table exists

2. **"Order details view not available"**
   - **Solution**: This is normal - the system falls back to basic orders
   - **Fix**: Run the migration script to create the views

3. **Existing orders not showing products**
   - **Solution**: Run `SELECT migrate_existing_orders();` to migrate old data

4. **Products not loading in dropdown**
   - **Check**: Ensure products table has data
   - **Verify**: Products are properly loaded in the application

### Migration Verification

```sql
-- Check migration status
SELECT 
  'order_items' as table_name,
  COUNT(*) as record_count
FROM order_items
UNION ALL
SELECT 
  'orders' as table_name,
  COUNT(*) as record_count
FROM orders;

-- Check if views exist
SELECT table_name 
FROM information_schema.views 
WHERE table_name IN ('order_details', 'order_totals');
```

## Performance Considerations

### Indexes Added
- `idx_order_items_order_id` - Fast order lookups
- `idx_order_items_product_id` - Fast product lookups
- `idx_order_items_created_at` - Time-based queries

### Query Optimization
- Views provide optimized data access
- Proper foreign key relationships ensure data integrity
- Cascade deletes maintain referential integrity

## Future Enhancements

### Potential Improvements
1. **Bulk Product Import**: Import multiple products from CSV
2. **Product Templates**: Save common product combinations
3. **Advanced Pricing**: Discounts, taxes, shipping costs
4. **Inventory Integration**: Real-time stock checking
5. **Order Workflow**: Status tracking per product

### API Extensions
- RESTful endpoints for order items
- Bulk operations for order management
- Real-time inventory updates

## Support

If you encounter any issues:

1. **Check the migration**: Ensure all database changes are applied
2. **Verify data**: Check that products and orders exist
3. **Review logs**: Check browser console for JavaScript errors
4. **Test step by step**: Create a simple order first, then add complexity

## Summary

The multi-product orders feature transforms your order management system from single-product to multi-product support while maintaining full backward compatibility. The implementation includes:

- ✅ **Database migration** with proper relationships
- ✅ **Enhanced UI** with dynamic product management
- ✅ **Real-time calculations** and validation
- ✅ **Backward compatibility** with existing orders
- ✅ **Comprehensive testing** and error handling

Your order management system is now ready to handle complex orders with multiple products! 🎉
