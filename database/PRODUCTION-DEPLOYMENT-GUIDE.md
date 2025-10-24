# Production Deployment Guide

## ⚠️ Important: Read This First!

This guide will help you **completely reset your database** and set up everything from scratch for production.

**WARNING:** This process will **DELETE ALL EXISTING DATA**. Make sure you:
1. ✅ Have backed up any important data
2. ✅ Are certain you want to start fresh
3. ✅ Are ready to proceed

## 📋 What This Will Do

1. **Drop everything** - Remove all existing tables, views, and functions
2. **Create fresh database** - Set up all tables from scratch
3. **Load default data** - Insert default categories and admin user
4. **Enable all features** - Orders, Expenses, Income tracking, etc.

## 🚀 Deployment Steps

### Option 1: Complete Fresh Setup (Recommended)

Use this if you want to delete everything and start clean.

#### Step 1: Clean Slate (Delete Everything)

1. **Open Supabase SQL Editor**
2. **Copy the entire contents** of:
   ```
   database/setup/00-clean-slate.sql
   ```
3. **Paste into SQL Editor**
4. **Review the script** - Make sure you understand it will delete ALL data
5. **Execute** ✅

**What this does:**
- Drops all views
- Drops all functions
- Drops all triggers
- Drops all tables
- Verifies everything is gone

#### Step 2: Complete Setup (Create Everything)

1. **Still in Supabase SQL Editor**
2. **Copy the entire contents** of:
   ```
   database/setup/COMPLETE-PRODUCTION-SETUP.sql
   ```
3. **Paste into SQL Editor**
4. **Execute** ✅

**What this creates:**
- ✅ All 9 core tables (products, categories, orders, order_items, users, expenses, expense_categories, income, income_categories)
- ✅ All 12 views for analytics
- ✅ All helper functions
- ✅ All triggers for automation
- ✅ Row Level Security policies
- ✅ Indexes for performance
- ✅ Default expense categories (10 categories)
- ✅ Default income categories (10 categories)
- ✅ Default admin user (username: Admin, password: 1234)

### Option 2: Keep Existing Data (Not Recommended for Clean Slate)

If you want to keep existing data and just add new features, run individual migration scripts instead.

## ✅ Verification

After running the complete setup, verify everything is working:

### 1. Check Tables
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Expected tables (9 total):**
- categories
- expense_categories
- expenses
- income
- income_categories
- order_items
- orders
- products
- users

### 2. Check Views
```sql
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;
```

**Expected views (12 total):**
- business_performance
- expense_details
- expense_summary_by_category
- expense_summary_by_month
- expense_summary_by_supplier
- income_summary_by_category
- income_summary_by_day
- income_summary_by_month
- income_with_orders
- order_details
- order_totals
- profit_loss_summary

### 3. Check Functions
```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
ORDER BY routine_name;
```

**Expected functions (5 total):**
- get_expense_stats
- get_income_stats
- get_profit_loss
- update_product_cost_from_expense
- update_updated_at_column

### 4. Check Default Data

**Expense Categories:**
```sql
SELECT * FROM expense_categories ORDER BY name;
```
Should return 10 categories.

**Income Categories:**
```sql
SELECT * FROM income_categories ORDER BY name;
```
Should return 10 categories.

**Admin User:**
```sql
SELECT id, username, role, is_active FROM users WHERE username = 'Admin';
```
Should return 1 row.

## 🔐 Post-Deployment Security

### CRITICAL: Change Admin Password

The default admin password is `1234` - **CHANGE THIS IMMEDIATELY!**

1. Log into your application
2. Go to user settings (or update directly in database)
3. Change to a strong password

**OR Update in Database:**
```sql
UPDATE users
SET password_hash = 'your-new-hashed-password'
WHERE username = 'Admin';
```

### Review RLS Policies

The current setup uses permissive policies (`USING (true)`). For production, you may want to implement stricter policies based on user authentication.

**Example stricter policy:**
```sql
-- Drop existing policy
DROP POLICY "Allow all operations on products" ON products;

-- Create authenticated-only policy
CREATE POLICY "Authenticated users can manage products" ON products
  FOR ALL
  USING (auth.role() = 'authenticated');
```

## 📊 What You Get

### Complete Feature Set

After deployment, you'll have:

1. **📦 Stock Management**
   - Product catalog
   - Inventory tracking
   - Categories

2. **🛒 Order Management**
   - Single-product orders
   - Multi-product orders
   - Order tracking
   - Customer management

3. **💰 Expense Tracking**
   - Track all business expenses
   - Category-based organization
   - Supplier management
   - Automatic stock updates for inventory purchases

4. **📈 Income & Profit Analytics**
   - Track revenue
   - Calculate profits
   - P&L statements
   - Business performance metrics

5. **👥 User Management**
   - Admin authentication
   - Role-based access

## 🎯 Testing Your Deployment

After setup, test each feature:

### 1. Test Products
```sql
-- Insert test product
INSERT INTO products (name, price, stock_quantity, category)
VALUES ('Test Product', 99.99, 100, 'Test Category');

-- Verify
SELECT * FROM products;
```

### 2. Test Orders
```sql
-- Insert test order
INSERT INTO orders (customer_name, customer_email, total_amount, status)
VALUES ('Test Customer', 'test@example.com', 99.99, 'Pending');

-- Verify
SELECT * FROM orders;
```

### 3. Test Expenses
```sql
-- Insert test expense
INSERT INTO expenses (category, description, unit_cost, total_amount)
VALUES ('Other', 'Test Expense', 50.00, 50.00);

-- Verify
SELECT * FROM expenses;
```

### 4. Test Income
```sql
-- Insert test income
INSERT INTO income (category, description, amount, cost)
VALUES ('Other Income', 'Test Revenue', 200.00, 50.00);

-- Verify
SELECT * FROM income;
SELECT * FROM business_performance;
```

## 🔄 Rollback Plan

If something goes wrong, you can:

1. **Re-run 00-clean-slate.sql** to start over
2. **Restore from backup** if you created one
3. **Run individual migrations** instead of complete setup

## 📝 Database Backup (Before Deployment)

### Using Supabase Dashboard

1. Go to your Supabase project
2. Click "Database" → "Backups"
3. Create a manual backup
4. Wait for backup to complete
5. **Then proceed with deployment**

### Using pg_dump (Alternative)

```bash
pg_dump -h your-db-host -U postgres -d your-database > backup.sql
```

## 🎉 Success Checklist

After deployment, verify:

- [ ] All 9 tables created
- [ ] All 12 views working
- [ ] All 5 functions present
- [ ] 10 expense categories loaded
- [ ] 10 income categories loaded
- [ ] Admin user exists
- [ ] Application loads without errors
- [ ] Can create test records
- [ ] RLS policies working
- [ ] **Admin password changed** ⚠️

## 📚 File Reference

**Deployment Scripts:**
- `database/setup/00-clean-slate.sql` - Delete everything
- `database/setup/COMPLETE-PRODUCTION-SETUP.sql` - Create everything
- `database/setup/01-initial-setup.sql` - Alternative: Base setup only

**Migration Scripts (Alternative):**
- `database/migrations/01-add-multi-product-support.sql`
- `database/migrations/02-add-expense-tracking.sql`
- `database/migrations/03-add-income-profit-tracking.sql`

## 🆘 Troubleshooting

### Issue: Script fails partway through

**Solution:**
1. Run `00-clean-slate.sql` again
2. Re-run `COMPLETE-PRODUCTION-SETUP.sql`

### Issue: Tables already exist error

**Solution:**
Run `00-clean-slate.sql` first to drop everything.

### Issue: Permission denied errors

**Solution:**
Make sure you're using the postgres/admin role in Supabase.

### Issue: Views not creating

**Solution:**
Check that all dependent tables exist first. The complete setup script runs in the correct order.

## 📞 Support

If you encounter issues:
1. Check the verification queries above
2. Review error messages carefully
3. Check Supabase logs
4. Ensure you ran scripts in correct order

## 🎯 Next Steps After Deployment

1. ✅ Change admin password
2. ✅ Test all features in application
3. ✅ Add your first products
4. ✅ Create categories
5. ✅ Start tracking expenses and income
6. ✅ Review security policies
7. ✅ Set up regular backups
8. ✅ Monitor application performance

---

**Ready to deploy? Follow the steps above carefully!** 🚀

**Last Updated:** 2025-10-24
