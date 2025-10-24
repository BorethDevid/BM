# Expense Tracking Setup Guide

## Overview

Track all your business expenses including goods purchased for resale. This feature helps you:
- Monitor spending across different categories
- Track inventory purchases with automatic stock updates
- Manage supplier information
- Generate expense reports

## 🚀 Quick Setup

### Step 1: Run the Migration

1. Open your Supabase SQL Editor
2. Copy and paste the contents of: `database/migrations/02-add-expense-tracking.sql`
3. Execute the script
4. ✅ Done! Expense tracking is ready.

### Step 2: Access the Expenses Page

1. Navigate to the Expenses page from the sidebar (💰 Expenses)
2. Start adding your business expenses!

## 📊 Features

### 1. Expense Categories

The system comes with pre-defined categories:
- 📦 **Inventory Purchase** - Goods purchased for resale
- 🏭 **Raw Materials** - Materials for production
- 🚚 **Shipping & Delivery** - Shipping costs
- 📦 **Packaging** - Packaging materials
- 📢 **Marketing** - Marketing and advertising
- 💡 **Utilities** - Electricity, water, internet
- 🏢 **Rent** - Office or warehouse rent
- 👥 **Salaries** - Employee salaries
- 🔧 **Equipment** - Equipment and tools
- 💰 **Other** - Miscellaneous expenses

### 2. Automatic Stock Updates

When you add an expense linked to a product:
- The product's stock quantity is automatically increased
- Perfect for tracking inventory purchases
- Cost tracking for better profit analysis

### 3. Supplier Management

Track supplier information:
- Supplier name
- Contact information
- Purchase history
- Total spent per supplier

### 4. Payment Tracking

Monitor payment status:
- **Paid** - Fully paid expenses
- **Pending** - Awaiting payment
- **Partial** - Partially paid

## 💡 How to Use

### Adding an Inventory Purchase

1. Click "Add Expense"
2. Fill in the details:
   - **Expense Date**: When you made the purchase
   - **Category**: Select "Inventory Purchase"
   - **Description**: Brief description
   - **Supplier**: Who you bought from
   - **Product**: Select the product from dropdown
   - **Quantity**: How many units purchased
   - **Unit Cost**: Cost per unit
   - **Total Amount**: Auto-calculated
   - **Payment Status**: Paid, Pending, or Partial

3. Click "Add Expense"
4. ✅ Stock is automatically updated!

### Adding a General Expense

1. Click "Add Expense"
2. Fill in the details:
   - **Expense Date**: When the expense occurred
   - **Category**: Select appropriate category
   - **Description**: What the expense was for
   - **Unit Cost**: Set to the full amount
   - **Total Amount**: Same as unit cost

3. Leave the "Product Information" section empty
4. Click "Add Expense"

## 📈 Dashboard & Reports

The expense page shows:

### Summary Cards
- **Total Expenses**: All-time total spending
- **Total Records**: Number of expense entries
- **This Month**: Current month's expenses
- **Average**: Average expense amount

### Views Available

1. **expense_details** - Detailed expense information with product data
2. **expense_summary_by_category** - Spending breakdown by category
3. **expense_summary_by_month** - Monthly expense trends
4. **expense_summary_by_supplier** - Supplier spending analysis

### Query Examples

```sql
-- Get all expenses with product information
SELECT * FROM expense_details ORDER BY expense_date DESC;

-- See spending by category
SELECT * FROM expense_summary_by_category;

-- Monthly expense trends
SELECT * FROM expense_summary_by_month;

-- Top suppliers
SELECT * FROM expense_summary_by_supplier;

-- Get expense statistics for a date range
SELECT * FROM get_expense_stats('2024-01-01', '2024-12-31');
```

## 🔧 Advanced Features

### Automatic Stock Updates

The system includes a trigger that automatically updates product stock when you add an expense with a product link:

```sql
-- This happens automatically when you add an expense with a product
UPDATE products
SET stock_quantity = stock_quantity + [purchased_quantity]
WHERE id = [product_id];
```

### Helper Functions

**Get Expense Statistics:**
```sql
-- Get stats for all time
SELECT * FROM get_expense_stats();

-- Get stats for a specific period
SELECT * FROM get_expense_stats('2024-01-01', '2024-03-31');
```

## 📝 Best Practices

1. **Be Consistent**: Enter expenses regularly, don't wait until month-end
2. **Use Categories**: Properly categorize for better reporting
3. **Link Products**: Always link inventory purchases to products
4. **Track Suppliers**: Maintain supplier information for future reference
5. **Add Notes**: Include relevant details in the notes field
6. **Keep Receipts**: Store receipt numbers for audit trail

## 🎨 Customization

### Adding New Categories

```sql
INSERT INTO expense_categories (name, description, icon, color)
VALUES ('Your Category', 'Description here', '🎯', '#yourcolor');
```

### Common Color Codes
- Blue: `#3b82f6`
- Green: `#10b981`
- Red: `#ef4444`
- Yellow: `#f59e0b`
- Purple: `#8b5cf6`

## 🔒 Security

- All tables have Row Level Security (RLS) enabled
- Access controlled through Supabase authentication
- Data is protected with proper policies

## 📊 Reports You Can Generate

1. **Profit Analysis**: Compare expenses vs revenue
2. **Category Breakdown**: See where money is spent
3. **Supplier Analysis**: Identify best suppliers
4. **Monthly Trends**: Track spending patterns
5. **Inventory Costs**: Calculate true product costs

## 🆘 Troubleshooting

### Issue: Expenses not saving
**Solution:** Check Supabase connection and ensure migration ran successfully

### Issue: Stock not updating
**Solution:** Ensure you've linked the expense to a product and entered a quantity

### Issue: Categories not showing
**Solution:** Run the migration script which inserts default categories

## 📚 Database Schema

### expenses Table
```sql
- id (BIGSERIAL PRIMARY KEY)
- expense_date (DATE)
- category (TEXT)
- description (TEXT)
- product_id (BIGINT, optional)
- product_name (TEXT)
- quantity (INTEGER)
- unit_cost (NUMERIC)
- total_amount (NUMERIC)
- supplier_name (TEXT)
- supplier_contact (TEXT)
- payment_method (TEXT)
- payment_status (TEXT)
- receipt_number (TEXT)
- notes (TEXT)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

### expense_categories Table
```sql
- id (BIGSERIAL PRIMARY KEY)
- name (TEXT UNIQUE)
- description (TEXT)
- icon (TEXT)
- color (TEXT)
- created_at (TIMESTAMPTZ)
```

## 🎯 Next Steps

1. Run the migration script
2. Add your first expense
3. Link inventory purchases to products
4. Explore the reports and views
5. Customize categories if needed

---

**Happy expense tracking! 💰**
