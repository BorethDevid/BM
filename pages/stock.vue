<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Stock Management</h1>
      <p>Manage your inventory and stock levels</p>
    </div>
    
    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading products from Supabase...</p>
    </div>
    
    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-message">
        <h3>⚠️ Connection Error</h3>
        <p>{{ error }}</p>
        <p><strong>To fix this:</strong></p>
        <ol>
          <li>Create a <code>.env</code> file with your Supabase credentials</li>
          <li>Set up a <code>products</code> table in your Supabase database</li>
          <li>Make sure your Supabase project is running</li>
        </ol>
        <button class="btn btn-primary" @click="addSampleProducts">
          Add Sample Products (Demo)
        </button>
      </div>
    </div>
    
    <!-- Main Content -->
    <div v-else>
      <div class="stock-grid">
        <div class="stock-card">
          <h3>Total Products</h3>
          <div class="stock-number">{{ totalProducts }}</div>
          <p class="stock-description">Items in inventory</p>
        </div>
        
        <div class="stock-card">
          <h3>Low Stock</h3>
          <div class="stock-number low-stock">{{ lowStockItems }}</div>
          <p class="stock-description">Items need restocking</p>
        </div>
        
        <div class="stock-card">
          <h3>Out of Stock</h3>
          <div class="stock-number out-of-stock">{{ outOfStockItems }}</div>
          <p class="stock-description">Items unavailable</p>
        </div>
      </div>
      
      <!-- Products Table -->
      <div v-if="products.length > 0" class="products-section">
        <h2>Products Inventory</h2>
        <div class="products-table-container">
          <table class="products-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in products" :key="product.id">
                <td>{{ product.name }}</td>
                <td>{{ product.category }}</td>
                <td>${{ product.price.toFixed(2) }}</td>
                <td>{{ product.stock_quantity }}</td>
                <td>
                  <span 
                    class="status-badge"
                    :class="{
                      'out-of-stock': product.stock_quantity === 0,
                      'low-stock': product.stock_quantity > 0 && product.stock_quantity < 10,
                      'in-stock': product.stock_quantity >= 10
                    }"
                  >
                    {{ 
                      product.stock_quantity === 0 ? 'Out of Stock' :
                      product.stock_quantity < 10 ? 'Low Stock' : 'In Stock'
                    }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Empty State -->
      <div v-else class="empty-state">
        <h3>No Products Found</h3>
        <p>Your inventory is empty. Add some products to get started!</p>
        <button class="btn btn-primary" @click="addSampleProducts">
          Add Sample Products
        </button>
      </div>
      
      <div class="stock-actions">
        <button class="btn btn-primary" @click="addNewProduct">
          Add New Product
        </button>
        <button class="btn btn-secondary" @click="fetchProducts">
          Refresh Data
        </button>
        <button class="btn btn-info" @click="addSampleProducts">
          Add Sample Products
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Stock management page with Supabase integration
interface Product {
  id: number
  name: string
  price: number
  stock_quantity: number
  category: string
  created_at: string
}

interface StockData {
  totalProducts: number
  lowStockItems: number
  outOfStockItems: number
}

// Reactive data
const products = ref<Product[]>([])
const stockData = reactive<StockData>({
  totalProducts: 0,
  lowStockItems: 0,
  outOfStockItems: 0
})
const loading = ref(true)
const error = ref<string | null>(null)

// Computed properties
const { totalProducts, lowStockItems, outOfStockItems } = toRefs(stockData)

// Fetch products from Supabase
const fetchProducts = async () => {
  try {
    loading.value = true
    error.value = null
    
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('products')
    
    if (fetchError) {
      throw fetchError
    }
    
    products.value = Array.isArray(data) ? (data as unknown as Product[]) : []
    
    // Calculate stock statistics
    stockData.totalProducts = products.value.length
    stockData.lowStockItems = products.value.filter((p: Product) => p.stock_quantity > 0 && p.stock_quantity < 10).length
    stockData.outOfStockItems = products.value.filter((p: Product) => p.stock_quantity === 0).length
    
  } catch (err) {
    console.error('Error fetching products:', err)
    error.value = 'Failed to load products. Please check your Supabase connection.'
    
    // Fallback data for demo
    stockData.totalProducts = 0
    stockData.lowStockItems = 0
    stockData.outOfStockItems = 0
  } finally {
    loading.value = false
  }
}

// Add sample products to Supabase (for demo purposes)
const addSampleProducts = async () => {
  try {
    const { insert } = useSupabaseDB()
    
    const sampleProducts = [
      { name: 'Laptop Pro 15"', price: 1299.99, stock_quantity: 25, category: 'Electronics' },
      { name: 'Wireless Mouse', price: 29.99, stock_quantity: 150, category: 'Accessories' },
      { name: 'Mechanical Keyboard', price: 89.99, stock_quantity: 5, category: 'Accessories' },
      { name: 'Monitor 27"', price: 399.99, stock_quantity: 0, category: 'Electronics' },
      { name: 'USB-C Cable', price: 19.99, stock_quantity: 200, category: 'Accessories' },
      { name: 'Gaming Headset', price: 149.99, stock_quantity: 8, category: 'Audio' }
    ]
    
    const { error } = await insert('products', sampleProducts)
    
    if (error) {
      console.error('Error adding sample products:', error)
    } else {
      console.log('Sample products added successfully!')
      await fetchProducts() // Refresh the data
    }
  } catch (err) {
    console.error('Error adding sample products:', err)
  }
}

const addNewProduct = (): void => {
  console.log('Adding new product...')
  // Add product logic here
}

const viewInventory = (): void => {
  console.log('Viewing full inventory...')
  // View inventory logic here
}

// Fetch data on component mount
onMounted(() => {
  fetchProducts()
})
</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.page-header {
  text-align: center;
  margin-bottom: 3rem;
}

.page-header h1 {
  color: #2c3e50;
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
}

.page-header p {
  color: #7f8c8d;
  font-size: 1.1rem;
}

.stock-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.stock-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  text-align: center;
  transition: transform 0.3s ease;
}

.stock-card:hover {
  transform: translateY(-5px);
}

.stock-card h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1.2rem;
}

.stock-number {
  font-size: 3rem;
  font-weight: bold;
  margin-bottom: 0.5rem;
  color: #27ae60;
}

.stock-number.low-stock {
  color: #f39c12;
}

.stock-number.out-of-stock {
  color: #e74c3c;
}

.stock-description {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.stock-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  padding: 0.75rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover {
  background-color: #2980b9;
  transform: translateY(-2px);
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn-secondary:hover {
  background-color: #7f8c8d;
  transform: translateY(-2px);
}

.btn-info {
  background-color: #17a2b8;
  color: white;
}

.btn-info:hover {
  background-color: #138496;
  transform: translateY(-2px);
}

/* Loading State */
.loading-container {
  text-align: center;
  padding: 4rem 2rem;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Error State */
.error-container {
  display: flex;
  justify-content: center;
  padding: 2rem;
}

.error-message {
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  padding: 2rem;
  max-width: 600px;
  text-align: left;
}

.error-message h3 {
  color: #721c24;
  margin-bottom: 1rem;
}

.error-message p {
  color: #721c24;
  margin-bottom: 1rem;
}

.error-message ol {
  color: #721c24;
  margin: 1rem 0;
  padding-left: 1.5rem;
}

.error-message code {
  background: #e9ecef;
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
}

/* Products Section */
.products-section {
  margin: 3rem 0;
}

.products-section h2 {
  color: #2c3e50;
  margin-bottom: 1.5rem;
  text-align: center;
}

.products-table-container {
  overflow-x: auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.products-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}

.products-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
}

.products-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
}

.products-table tr:hover {
  background: #f8f9fa;
}

/* Status Badges */
.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.in-stock {
  background: #d4edda;
  color: #155724;
}

.status-badge.low-stock {
  background: #fff3cd;
  color: #856404;
}

.status-badge.out-of-stock {
  background: #f8d7da;
  color: #721c24;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin: 2rem 0;
}

.empty-state h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.empty-state p {
  color: #7f8c8d;
  margin-bottom: 2rem;
}

/* Responsive design */
@media (max-width: 768px) {
  .page-container {
    padding: 1rem;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
  
  .stock-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .stock-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .btn {
    width: 100%;
    max-width: 300px;
  }
}
</style>

