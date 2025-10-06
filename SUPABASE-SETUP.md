# Supabase Database Setup Guide

## Step 1: Create Your Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click "New Project"
4. Choose your organization and give your project a name
5. Set a database password (save this securely!)
6. Choose a region close to you
7. Click "Create new project"

## Step 2: Get Your Project Credentials

1. Once your project is created, go to **Settings** → **API**
2. Copy your **Project URL** and **anon/public key**
3. These will be used in your `.env` file

## Step 3: Create the Products Table

1. Go to **Table Editor** in your Supabase dashboard
2. Click **"Create a new table"**
3. Use these settings:

### Table Configuration:
- **Name**: `products`
- **Description**: `Product inventory table`
- **Enable RLS**: ✅ (checked)

### Columns:
| Column Name | Type | Default Value | Nullable | Primary Key |
|-------------|------|---------------|----------|-------------|
| `id` | `int8` | `auto` | ❌ | ✅ |
| `name` | `text` | - | ❌ | ❌ |
| `price` | `numeric` | - | ❌ | ❌ |
| `stock_quantity` | `int4` | `0` | ❌ | ❌ |
| `category` | `text` | - | ❌ | ❌ |
| `created_at` | `timestamptz` | `now()` | ❌ | ❌ |

### SQL to Create Table:
```sql
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows all operations for now (for demo purposes)
CREATE POLICY "Allow all operations on products" ON products
  FOR ALL USING (true);
```

## Step 4: Set Up Environment Variables

1. Create a `.env` file in your project root:
```bash
# Copy the example file
cp .env.example .env
```

2. Edit `.env` with your actual values:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

## Step 5: Test the Connection

1. Start your development server:
```bash
npm run dev
```

2. Navigate to `/stock` page
3. You should see either:
   - **Success**: Products loaded from Supabase
   - **Error**: Connection error with setup instructions

## Step 6: Add Sample Data (Optional)

### Option 1: Using SQL Editor (Recommended)

1. Go to your Supabase dashboard
2. Navigate to **SQL Editor**
3. Create a new query and paste this script:

```sql
-- Insert sample products data
INSERT INTO products (name, price, stock_quantity, category) VALUES
('Laptop Pro 15"', 1299.99, 25, 'Electronics'),
('Wireless Mouse', 29.99, 150, 'Accessories'),
('Mechanical Keyboard', 89.99, 5, 'Accessories'),
('Monitor 27"', 399.99, 0, 'Electronics'),
('USB-C Cable', 19.99, 200, 'Accessories'),
('Gaming Headset', 149.99, 8, 'Audio'),
('Smartphone', 699.99, 15, 'Electronics'),
('Bluetooth Speaker', 79.99, 30, 'Audio'),
('Laptop Stand', 49.99, 12, 'Accessories'),
('Webcam HD', 99.99, 8, 'Electronics'),
('Desk Lamp', 39.99, 50, 'Furniture'),
('Coffee Mug', 12.99, 100, 'Miscellaneous');
```

4. Click **"Run"** to execute the script

### Option 2: Using Table Editor

1. Go to your Supabase dashboard
2. Navigate to **Table Editor** → **products**
3. Click **"Insert"** → **"Insert row"**
4. Add products one by one:

| name | price | stock_quantity | category |
|------|-------|----------------|----------|
| Laptop Pro 15" | 1299.99 | 25 | Electronics |
| Wireless Mouse | 29.99 | 150 | Accessories |
| Mechanical Keyboard | 89.99 | 5 | Accessories |
| Monitor 27" | 399.99 | 0 | Electronics |
| USB-C Cable | 19.99 | 200 | Accessories |
| Gaming Headset | 149.99 | 8 | Audio |
| Smartphone | 699.99 | 15 | Electronics |
| Bluetooth Speaker | 79.99 | 30 | Audio |
| Laptop Stand | 49.99 | 12 | Accessories |
| Webcam HD | 99.99 | 8 | Electronics |
| Desk Lamp | 39.99 | 50 | Furniture |
| Coffee Mug | 12.99 | 100 | Miscellaneous |

## Troubleshooting

### Common Issues:

1. **"Failed to load products" error**:
   - Check your `.env` file has correct values
   - Verify your Supabase project is running
   - Make sure the `products` table exists

2. **"Table doesn't exist" error**:
   - Create the `products` table in Supabase
   - Check the table name is exactly `products`

3. **"Permission denied" error**:
   - Check your RLS policies
   - Make sure the anon key has proper permissions

### Getting Help:
- Check the browser console for detailed error messages
- Verify your Supabase project is active
- Test your connection in the Supabase dashboard

## Next Steps

Once everything is working:
1. Customize the products table structure for your needs
2. Add more sophisticated RLS policies
3. Implement user authentication
4. Add more features to your stock management system
