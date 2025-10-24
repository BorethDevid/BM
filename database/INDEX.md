# Database Files Index

Quick reference to find what you need.

## 📖 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `QUICK-START.md` | Fast setup guide | Start here first! |
| `README.md` | Complete technical documentation | Need detailed info |
| `MULTI-PRODUCT-ORDERS-GUIDE.md` | Multi-product feature guide | Understanding the feature |
| `CHANGELOG.md` | Version history | Track changes |
| `INDEX.md` | This file | Navigation |

## 💾 SQL Scripts

### Setup Scripts (Fresh Installation)

| File | Purpose | Size | Run Once |
|------|---------|------|----------|
| `setup/01-initial-setup.sql` | Complete database schema | ~300 lines | ✅ Yes |

**Includes:**
- All tables (products, orders, categories, users, order_items)
- All indexes for performance
- All RLS policies
- Helpful views (order_details, order_totals)
- Helper functions
- Default admin user

### Migration Scripts (Existing Database)

| File | Purpose | Size | Run Once |
|------|---------|------|----------|
| `migrations/01-add-multi-product-support.sql` | Add multi-product orders | ~250 lines | ✅ Yes |

**Includes:**
- Make legacy columns nullable
- Create order_items table
- Add channel, location, order_date columns
- Create indexes
- Create views
- Migration helper function

## 🎯 Common Tasks

### Task: Set up a new database
1. Open: `QUICK-START.md`
2. Run: `setup/01-initial-setup.sql`

### Task: Add multi-product support
1. Open: `QUICK-START.md`
2. Run: `migrations/01-add-multi-product-support.sql`

### Task: Understand database structure
1. Read: `README.md` → "Database Schema" section

### Task: Migrate legacy orders
1. Run: `SELECT migrate_existing_orders();`
2. See: `README.md` → "Helper Functions" section

### Task: Troubleshoot issues
1. Check: `README.md` → "Troubleshooting" section
2. Check: `QUICK-START.md` → "Common Issues" section

## 🔍 What's Inside Each SQL File?

### `setup/01-initial-setup.sql`
```
1. Create products table
2. Create categories table
3. Create orders table (with multi-product support)
4. Create order_items table
5. Create users table
6. Add all indexes
7. Create views (order_details, order_totals)
8. Enable RLS policies
9. Create helper functions
10. Insert default admin user
11. Verification queries
```

### `migrations/01-add-multi-product-support.sql`
```
1. Make legacy columns nullable
2. Add new columns (channel, location, order_date)
3. Create order_items table
4. Add indexes
5. Enable RLS policies
6. Create views
7. Create migration function
8. Verification queries
```

## 📊 File Statistics

| Category | Count | Total Lines |
|----------|-------|-------------|
| Documentation | 5 files | ~800 lines |
| Setup Scripts | 1 file | ~300 lines |
| Migration Scripts | 1 file | ~250 lines |
| **Total** | **7 files** | **~1350 lines** |

## 🎓 Learning Path

**Beginner:**
1. Start with `QUICK-START.md`
2. Run the appropriate SQL script
3. Done!

**Intermediate:**
1. Read `README.md` for full understanding
2. Review `MULTI-PRODUCT-ORDERS-GUIDE.md`
3. Understand the migration path

**Advanced:**
1. Study the SQL scripts themselves
2. Customize RLS policies for your needs
3. Add your own migrations

## 💡 Pro Tips

- ✅ Always read `QUICK-START.md` first
- ✅ Backup before running migrations
- ✅ Test in development environment first
- ✅ Read script comments - they explain everything
- ✅ Check verification queries after running scripts
- ✅ Keep this database folder organized - don't add loose files

## 🆘 Quick Help

**Something not working?**
1. Check `README.md` → Troubleshooting
2. Check `QUICK-START.md` → Common Issues
3. Review the SQL script comments

**Need to add something?**
1. Create a new numbered migration file
2. Follow the same structure as existing files
3. Update this INDEX.md
4. Update CHANGELOG.md

---

**Last Updated:** 2025-10-24
**Maintained by:** Development Team
