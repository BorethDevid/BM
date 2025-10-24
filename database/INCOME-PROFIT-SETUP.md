# Income & Profit Tracking Setup Guide

## Overview

Track all your business income, calculate profits, and analyze your business performance with comprehensive analytics.

## 🚀 Quick Setup

### Step 1: Run the Migration

1. Open your Supabase SQL Editor
2. Copy and paste: `database/migrations/03-add-income-profit-tracking.sql`
3. Execute the script
4. ✅ Done! Income tracking is ready.

### Step 2: Access the Income Page

1. Navigate to "📈 Income" from the sidebar
2. Start tracking your business income and profits!

## 📊 Features

### 1. Real-Time Profit Analytics

**Summary Dashboard:**
- **Total Revenue** - All income from all sources
- **Total Expenses** - All business costs
- **Net Profit** - Revenue minus all expenses
- **Average Profit** - Average profit per transaction
- **Profit Margin** - Percentage profitability

### 2. Income Categories (10 Pre-defined)

- 💰 **Product Sales** - Revenue from product sales
- 🔧 **Service Revenue** - Revenue from services
- 💵 **Commission** - Commission income
- 🏢 **Rental Income** - Income from rentals
- 📈 **Interest** - Interest income
- 💎 **Investment Returns** - Investment income
- 👔 **Consulting** - Consulting fees
- 🔗 **Affiliate Income** - Affiliate marketing
- 📚 **Royalties** - Royalty income
- 💸 **Other Income** - Miscellaneous

### 3. Automatic Profit Calculation

For each income record:
- **Revenue Amount** - How much you received
- **Cost** - Associated costs (optional)
- **Profit** - Automatically calculated (Revenue - Cost)

### 4. Business Performance Views

The system includes powerful database views:

**Available Views:**
- `income_with_orders` - Income linked to orders
- `income_summary_by_category` - Category breakdown
- `income_summary_by_month` - Monthly trends
- `income_summary_by_day` - Daily summary
- `profit_loss_summary` - P&L by period
- `business_performance` - Overall metrics

### 5. Advanced Analytics Functions

**Get Income Statistics:**
```sql
-- All time
SELECT * FROM get_income_stats();

-- Specific period
SELECT * FROM get_income_stats('2024-01-01', '2024-12-31');
```

**Get Profit & Loss:**
```sql
-- This month
SELECT * FROM get_profit_loss(
  DATE_TRUNC('month', CURRENT_DATE)::date,
  CURRENT_DATE
);

-- This year
SELECT * FROM get_profit_loss('2024-01-01', '2024-12-31');
```

## 💡 How to Use

### Adding Income from Sales

1. Click "Add Income"
2. Fill in:
   - **Income Date**: When you received payment
   - **Category**: Select "Product Sales"
   - **Description**: What was sold
   - **Source**: Customer name
   - **Revenue Amount**: Total received
   - **Cost**: What it cost you (optional)
   - **Payment Status**: Received/Pending/Partial
3. Click "Add Income"
4. ✅ Profit calculated automatically!

### Adding Other Income

1. Click "Add Income"
2. Select appropriate category
3. Enter amount and details
4. Leave cost as 0 if not applicable
5. Save!

### Understanding Profit Calculations

**Gross Profit:**
```
Gross Profit = Total Revenue - Direct Costs
```

**Net Profit:**
```
Net Profit = Gross Profit - Total Expenses
```

**Profit Margin:**
```
Profit Margin = (Net Profit / Total Revenue) × 100
```

## 📈 Dashboard Metrics Explained

### Total Revenue
All money received from all income sources.

### Total Expenses
All business costs from the expenses table.

### Net Profit
Your actual profit after all expenses:
- **Green** = Profitable ✅
- **Red** = Loss ❌

### Avg Profit/Sale
Average profit per income transaction (useful for pricing strategy).

## 🔗 Integration Features

### Optional: Auto-Create Income from Orders

The migration includes a trigger function that can automatically create income records when orders are marked as "Completed":

To enable:
```sql
-- Uncomment these lines in the migration script:
CREATE TRIGGER trigger_create_income_from_order
  AFTER INSERT OR UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION create_income_from_order();
```

This will:
- Monitor order status changes
- When order → "Completed"
- Automatically create income record
- Link to the order
- Use order amount as revenue

## 📊 Reports You Can Generate

### 1. Monthly P&L Statement
```sql
SELECT
  to_char(period, 'YYYY-MM') as month,
  total_revenue,
  total_expenses,
  net_profit,
  profit_margin
FROM profit_loss_summary
ORDER BY period DESC
LIMIT 12;
```

### 2. Category Performance
```sql
SELECT
  category,
  total_revenue,
  total_profit,
  transaction_count,
  avg_profit
FROM income_summary_by_category
ORDER BY total_profit DESC;
```

### 3. Daily Revenue Trend
```sql
SELECT
  income_date,
  total_revenue,
  total_profit,
  transaction_count
FROM income_summary_by_day
WHERE income_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY income_date DESC;
```

### 4. Overall Business Health
```sql
SELECT * FROM business_performance;
```

## 🎯 Best Practices

1. **Track Everything** - Record all income, even small amounts
2. **Include Costs** - Always add costs for accurate profit calculation
3. **Be Consistent** - Use same categories consistently
4. **Daily Entry** - Enter income daily, not monthly
5. **Review Weekly** - Check your profit margins weekly
6. **Monitor Trends** - Watch for patterns in profitable categories
7. **Set Goals** - Use data to set realistic revenue targets

## 🔧 Customization

### Add New Category

```sql
INSERT INTO income_categories (name, description, icon, color)
VALUES ('Your Category', 'Description', '🎯', '#hexcolor');
```

### Popular Colors
- Green (Profit): `#10b981`
- Blue (Revenue): `#3b82f6`
- Purple (Premium): `#8b5cf6`
- Gold (Premium): `#f59e0b`

## 📱 Mobile Friendly

The income page is fully responsive and works great on:
- Desktop computers
- Tablets
- Mobile phones

## 🆘 Troubleshooting

### Issue: Profit not calculating
**Solution:** Profit is calculated automatically using a GENERATED column. If you see issues, check that both `amount` and `cost` are set.

### Issue: Can't see expenses in net profit
**Solution:** Make sure you've run both migrations:
1. Expense tracking migration
2. Income tracking migration

### Issue: Views not showing data
**Solution:** Check that you have data in both `income` and `expenses` tables.

## 🎓 Understanding Your Numbers

### What is a Good Profit Margin?

**Retail Business:**
- 5-10%: Low
- 10-20%: Average
- 20-30%: Good
- 30%+: Excellent

**Service Business:**
- 10-20%: Average
- 20-40%: Good
- 40%+: Excellent

### When to Be Concerned

- **Negative Net Profit**: Expenses exceed revenue
- **Declining Margin**: Profit percentage decreasing
- **Low Revenue**: Insufficient sales volume

### Growth Indicators

- **Increasing Revenue**: More sales
- **Stable/Rising Margin**: Efficient operations
- **More Transactions**: Business growing

## 📚 Database Schema

### income Table
```sql
- id (BIGSERIAL PRIMARY KEY)
- income_date (DATE)
- category (TEXT)
- description (TEXT)
- order_id (BIGINT, optional)
- amount (NUMERIC) - Revenue
- cost (NUMERIC) - Direct cost
- profit (NUMERIC) - Auto-calculated
- source (TEXT) - Customer/source
- payment_method (TEXT)
- payment_status (TEXT)
- reference_number (TEXT)
- notes (TEXT)
- created_at, updated_at
```

## 🎯 Next Steps

1. ✅ Run the migration
2. ✅ Add your first income record
3. ✅ Link costs for accurate profit
4. ✅ Review your dashboard
5. ✅ Set up regular reporting schedule
6. ✅ Monitor and grow your business!

---

**Happy profit tracking! 📈💰**
