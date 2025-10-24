# Database Documentation

This folder contains all SQL scripts for the Business Management System database.

## 📁 Folder Structure

```
database/
├── setup/                      # Initial database setup scripts
│   └── 01-initial-setup.sql   # Complete database schema for new installations
├── migrations/                 # Migration scripts for existing databases
│   └── 01-add-multi-product-support.sql  # Add multi-product order support
└── README.md                   # This file
```

## 🚀 Quick Start

### For New Installations

If you're setting up a **brand new database**, run:

1. Open your Supabase SQL Editor
2. Copy and paste the contents of `setup/01-initial-setup.sql`
3. Execute the script
4. Done! Your database is ready to use.

### For Existing Databases

If you already have a database and want to **add multi-product support**, run:

1. Open your Supabase SQL Editor
2. Copy and paste the contents of `migrations/01-add-multi-product-support.sql`
3. Execute the script
4. Optionally run: `SELECT migrate_existing_orders();` to migrate legacy data
5. Done! Your database now supports multiple products per order.

## 📊 Database Schema

### Tables

#### 1. **products**
- Stores product catalog with pricing and inventory
- Columns: `id`, `name`, `price`, `stock_quantity`, `category`, `created_at`

#### 2. **categories**
- Product categories for organization
- Columns: `id`, `name`, `description`, `created_at`

#### 3. **orders**
- Customer orders (supports both single and multi-product)
- Columns: `id`, `customer_name`, `customer_email`, `product_name` (legacy), `quantity` (legacy), `unit_price` (legacy), `total_amount`, `status`, `channel`, `location`, `order_date`, `notes`, `created_at`

#### 4. **order_items**
- Individual products within an order (for multi-product orders)
- Columns: `id`, `order_id`, `product_id`, `quantity`, `unit_price`, `total_price`, `created_at`

#### 5. **users**
- User authentication and authorization
- Columns: `id`, `username`, `password_hash`, `role`, `is_active`, `created_at`, `updated_at`

### Views

#### 1. **order_details**
- Combines orders with their items and product details
- Useful for displaying order information with product names

#### 2. **order_totals**
- Aggregates order totals and item counts
- Useful for reports and dashboards

## 🔧 Helper Functions

### `migrate_existing_orders()`
Migrates legacy single-product orders to the new multi-product structure.

**Usage:**
```sql
SELECT migrate_existing_orders();
```

## 🔒 Security

All tables have Row Level Security (RLS) enabled with permissive policies.

**Note:** The default policies allow all operations. Customize these based on your security requirements.

## 📝 Notes

### Multi-Product vs Single-Product Orders

- **Legacy orders**: Use `product_name`, `quantity`, `unit_price` columns in `orders` table
- **Multi-product orders**: Use `order_items` table with references to `products` table

The system supports both for backward compatibility!

### Default Credentials

**Username:** Admin
**Password:** 1234

⚠️ **IMPORTANT:** Change the default admin password in production!

## 🆘 Troubleshooting

### Error: "null value in column 'product_name' violates not-null constraint"

**Solution:** Run the migration script `migrations/01-add-multi-product-support.sql` to make legacy columns nullable.

### Error: "relation 'order_items' does not exist"

**Solution:** Run the migration script `migrations/01-add-multi-product-support.sql` to create the `order_items` table.

### Error: "syntax error at or near 'NOT'"

**Solution:** Your PostgreSQL version doesn't support `CREATE POLICY IF NOT EXISTS`. The migration script has been updated to handle this.

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🔄 Version History

- **v1.0** - Initial database setup
- **v1.1** - Added multi-product order support, channel and location tracking

---

For questions or issues, please check the troubleshooting section or contact the development team.
