# Feature Addition Checklist

When adding a new feature/page to the Business Management System, make sure to update these files:

## ✅ Required Updates

### 1. Create the Feature Files
- [ ] Create the page file: `pages/[feature-name].vue`
- [ ] Create database migration: `database/migrations/[number]-[feature-name].sql`
- [ ] Create setup guide: `database/[FEATURE-NAME]-SETUP.md`

### 2. Update Navigation
- [ ] **Add to sidebar navigation**: `components/NavigationBar.vue`
  ```vue
  <NuxtLink to="/[feature-name]" class="sidebar-item">
    <span class="item-icon">[emoji]</span>
    <span class="item-text">[Feature Name]</span>
  </NuxtLink>
  ```

### 3. Update Home Page (Dashboard)
- [ ] **Add navigation card**: `pages/index.vue`
  ```vue
  <div class="dashboard-card">
    <div class="card-icon">[emoji]</div>
    <h3>[Feature Name]</h3>
    <p>[Description]</p>
    <NuxtLink to="/[feature-name]" class="card-link">Go to [Feature]</NuxtLink>
  </div>
  ```

### 4. Update Documentation
- [ ] Update `database/README.md` if adding database tables
- [ ] Update `database/INDEX.md` with new migration
- [ ] Update `database/CHANGELOG.md` with version info

## 📋 Example: Adding "Reports" Feature

### Step 1: Create Files
```bash
pages/reports.vue
database/migrations/04-add-reports.sql
database/REPORTS-SETUP.md
```

### Step 2: Update NavigationBar.vue
```vue
<NuxtLink to="/reports" class="sidebar-item">
  <span class="item-icon">📑</span>
  <span class="item-text">Reports</span>
</NuxtLink>
```

### Step 3: Update Home Page (index.vue)
```vue
<div class="dashboard-card">
  <div class="card-icon">📑</div>
  <h3>Reports</h3>
  <p>Generate business reports and analytics</p>
  <NuxtLink to="/reports" class="card-link">Go to Reports</NuxtLink>
</div>
```

### Step 4: Add Styling (Optional)
```css
.reports-card {
  border-left: 4px solid #6366f1;
}

.reports-card .card-icon {
  color: #6366f1;
  filter: drop-shadow(0 2px 4px rgba(99, 102, 241, 0.3));
}
```

## 🎨 Icon Suggestions

Choose appropriate emojis for your features:

**Financial:**
- 💰 Money/Expenses
- 📈 Income/Growth
- 💎 Premium/Profit
- 💵 Cash/Payments
- 💳 Cards/Transactions

**Inventory:**
- 📦 Stock/Products
- 📋 Lists/Inventory
- 🏭 Manufacturing
- 📊 Analytics

**Operations:**
- 🛒 Orders/Shopping
- 🚚 Shipping/Delivery
- 📱 Mobile/Apps
- 🔧 Tools/Settings
- ⚙️ Configuration

**Business:**
- 👥 Customers/Team
- 📞 Contact/Support
- 📑 Reports/Documents
- 📅 Calendar/Schedule
- 🎯 Goals/Targets

**Analysis:**
- 📊 Data/Analytics
- 📈 Growth/Trends
- 📉 Decline/Issues
- 🔍 Search/Investigation
- 📌 Important/Pinned

## 🎨 Color Palette

Use consistent colors across the app:

**Primary Colors:**
- Blue: `#3b82f6` (Links, Primary actions)
- Green: `#10b981` (Success, Income, Profit)
- Red: `#ef4444` (Danger, Expenses, Loss)
- Yellow/Orange: `#f59e0b` (Warning, Expenses)

**Secondary Colors:**
- Purple: `#8b5cf6` (Premium features)
- Indigo: `#6366f1` (Analytics)
- Pink: `#ec4899` (Marketing)
- Teal: `#14b8a6` (Finance)

**Neutral Colors:**
- Gray: `#64748b` (Text, Borders)
- Light Gray: `#f8f9fa` (Backgrounds)
- Dark: `#2c3e50` (Headings)

## 📝 File Naming Conventions

**Pages:**
- Use kebab-case: `stock-reports.vue`
- Single words: `reports.vue`

**Migrations:**
- Format: `[number]-[descriptive-name].sql`
- Example: `04-add-reports-feature.sql`

**Documentation:**
- All caps with hyphens: `REPORTS-SETUP.md`
- README files: `README.md`

## 🔄 Current Features (Reference)

### Existing Pages:
1. 🏠 **Home** (`/`) - Dashboard
2. 📦 **Stock** (`/stock`) - Inventory management
3. 📁 **Categories** (`/categories`) - Product categories
4. 🛒 **Orders** (`/orders`) - Order management
5. 💰 **Expenses** (`/expenses`) - Expense tracking
6. 📈 **Income** (`/income`) - Income & profit analytics
7. 📊 **Data** (`/data`) - Reference data

### Existing Database Tables:
- `products` - Product catalog
- `categories` - Product categories
- `orders` - Customer orders
- `order_items` - Multi-product order items
- `users` - User authentication
- `expenses` - Business expenses
- `expense_categories` - Expense categories
- `income` - Income records
- `income_categories` - Income categories

## 🎯 Best Practices

1. **Keep it consistent** - Follow existing patterns
2. **Update all touchpoints** - Navigation, home page, docs
3. **Use appropriate icons** - Choose emojis that make sense
4. **Add colors** - Use the color palette for consistency
5. **Document everything** - Write setup guides and README files
6. **Test thoroughly** - Check all navigation paths work
7. **Mobile responsive** - Ensure it works on all devices

## ⚠️ Don't Forget!

- [ ] Test the navigation from home page
- [ ] Test the sidebar navigation
- [ ] Verify the page loads without errors
- [ ] Check mobile responsiveness
- [ ] Update any relevant documentation
- [ ] Run database migrations in order
- [ ] Commit changes with clear message

## 📚 Quick Reference Links

- Navigation: `components/NavigationBar.vue`
- Home Page: `pages/index.vue`
- Database Docs: `database/README.md`
- Migrations: `database/migrations/`

---

**Remember:** Every new feature should be accessible from BOTH the sidebar navigation AND the home page dashboard!

**Last Updated:** 2025-10-24
