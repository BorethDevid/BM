# Quick Start Guide

## 🎯 Choose Your Path

### Path 1: New Installation (Fresh Database)
**If you're setting up a brand new database:**

1. Open Supabase SQL Editor
2. Copy all contents from: `setup/01-initial-setup.sql`
3. Paste and execute
4. ✅ Done! Database is ready.

---

### Path 2: Existing Database (Add Multi-Product Support)
**If you already have a database:**

1. Open Supabase SQL Editor
2. Copy all contents from: `migrations/01-add-multi-product-support.sql`
3. Paste and execute
4. (Optional) Run: `SELECT migrate_existing_orders();`
5. ✅ Done! Multi-product support added.

---

## 📝 What's Included

### Setup Scripts
- `setup/01-initial-setup.sql` - Complete database schema (products, orders, users, etc.)

### Migration Scripts
- `migrations/01-add-multi-product-support.sql` - Adds order_items table and multi-product features

### Documentation
- `README.md` - Complete database documentation
- `MULTI-PRODUCT-ORDERS-GUIDE.md` - Detailed guide for multi-product orders
- `QUICK-START.md` - This file!

---

## 🔑 Default Login

**Username:** Admin
**Password:** 1234

⚠️ **Change this password immediately in production!**

---

## 🆘 Common Issues

### Issue: "null value in column 'product_name' violates not-null constraint"
**Fix:** Run the migration script (Path 2 above)

### Issue: "relation 'order_items' does not exist"
**Fix:** Run the migration script (Path 2 above)

### Issue: "syntax error at or near 'NOT'"
**Fix:** The updated migration script fixes this - just re-run it

---

## 📚 Need More Help?

- Check `README.md` for detailed documentation
- Review `MULTI-PRODUCT-ORDERS-GUIDE.md` for feature details
- Check the troubleshooting section in README.md

---

## ✨ Quick Tips

1. **Always backup** your database before running migrations
2. **Test in development** environment first
3. **Check verification queries** at the end of each script
4. **Read the comments** in SQL files - they explain what each step does

---

**Happy coding! 🚀**
