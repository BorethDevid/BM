<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Stock Management</h1>
      <p>Manage your inventory and stock levels</p>
    </div>
    
    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <el-card class="loading-card">
        <div class="loading-content">
          <span class="loading-icon" style="font-size: 48px;">⏳</span>
          <h3>Loading Products</h3>
          <p>Fetching data from Supabase...</p>
        </div>
      </el-card>
    </div>
    
    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <el-alert
        title="Connection Error"
        type="error"
        :description="error"
        show-icon
        :closable="false"
        class="error-alert"
      >
        <template #default>
          <div class="error-content">
            <h4>To fix this:</h4>
            <ol>
              <li>Create a <code>.env</code> file with your Supabase credentials</li>
              <li>Set up a <code>products</code> table in your Supabase database</li>
              <li>Make sure your Supabase project is running</li>
            </ol>
          </div>
        </template>
      </el-alert>
    </div>
    
    <!-- Main Content -->
    <div v-else>
      <el-row :gutter="24" class="stock-grid">
        <el-col :xs="24" :sm="8" :md="8" :lg="8" :xl="8">
          <el-card class="stock-card total-card" shadow="hover">
            <div class="stock-content">
              <div class="stock-icon">
                <span style="font-size: 32px;">📦</span>
              </div>
              <div class="stock-info">
                <h3>Total Products</h3>
                <div class="stock-number">{{ totalProducts }}</div>
                <p class="stock-description">Items in inventory</p>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="8" :md="8" :lg="8" :xl="8">
          <el-card class="stock-card low-stock-card" shadow="hover">
            <div class="stock-content">
              <div class="stock-icon">
                <span style="font-size: 32px;">⚠️</span>
              </div>
              <div class="stock-info">
                <h3>Low Stock</h3>
                <div class="stock-number low-stock">{{ lowStockItems }}</div>
                <p class="stock-description">Items need restocking</p>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="8" :md="8" :lg="8" :xl="8">
          <el-card class="stock-card out-of-stock-card" shadow="hover">
            <div class="stock-content">
              <div class="stock-icon">
                <span style="font-size: 32px;">❌</span>
              </div>
              <div class="stock-info">
                <h3>Out of Stock</h3>
                <div class="stock-number out-of-stock">{{ outOfStockItems }}</div>
                <p class="stock-description">Items unavailable</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- Products Table -->
      <div v-if="products.length > 0" class="products-section">
        <el-card class="products-card" shadow="hover">
          <template #header>
            <div class="products-header">
              <h2>
                <span>📋</span>
                Products Inventory
              </h2>
              <el-button type="primary" @click="addNewProduct">
                <span>➕</span>
                Add Product
              </el-button>
            </div>
          </template>
          
          <el-table 
            :data="products" 
            stripe 
            style="width: 100%"
            class="products-table"
            :row-class-name="getRowClassName"
          >
            <el-table-column prop="name" label="Product Name" min-width="150">
              <template #default="{ row }">
                <div class="product-name">
                  <span>📦</span>
                  <span>{{ row.name }}</span>
                </div>
              </template>
            </el-table-column>
            
            <el-table-column prop="category" label="Category" min-width="120">
              <template #default="{ row }">
                <el-tag type="info" size="small">{{ row.category }}</el-tag>
              </template>
            </el-table-column>
            
            <el-table-column prop="price" label="Price" min-width="100" align="right">
              <template #default="{ row }">
                <span class="price">${{ row.price.toFixed(2) }}</span>
              </template>
            </el-table-column>
            
            <el-table-column prop="stock_quantity" label="Stock" min-width="100" align="center">
              <template #default="{ row }">
                <el-tag 
                  :type="getStockTagType(row.stock_quantity)"
                  size="small"
                >
                  {{ row.stock_quantity }}
                </el-tag>
              </template>
            </el-table-column>
            
            <el-table-column label="Status" min-width="120" align="center">
              <template #default="{ row }">
                <el-tag 
                  :type="getStatusTagType(row.stock_quantity)"
                  size="small"
                >
                  {{ getStockStatus(row.stock_quantity) }}
                </el-tag>
              </template>
            </el-table-column>
            
            <el-table-column label="Actions" min-width="120" align="center">
              <template #default="{ row }">
                <el-button-group>
                  <el-button 
                    type="primary" 
                    size="small" 
                    @click="openEditModal(row)"
                    title="Edit product"
                  >
                    <span>✏️</span>
                  </el-button>
                  <el-button 
                    type="danger" 
                    size="small" 
                    @click="confirmDelete(row)"
                    title="Delete product"
                  >
                    <span>🗑️</span>
                  </el-button>
                </el-button-group>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>
      
      <!-- Empty State -->
      <div v-else class="empty-state">
        <el-card class="empty-card" shadow="hover">
          <div class="empty-content">
            <span class="empty-icon" style="font-size: 64px;">📦</span>
            <h3>No Products Found</h3>
            <p>Your inventory is empty. Add some products to get started!</p>
            <el-button type="primary" size="large" @click="addNewProduct">
              <span>➕</span>
              Add Your First Product
            </el-button>
          </div>
        </el-card>
      </div>
      
      <div class="stock-actions" v-if="products.length > 0">
        <el-button type="primary" @click="addNewProduct">
          <span>➕</span>
          Add New Product
        </el-button>
        <el-button type="default" @click="fetchProducts">
          <span>🔄</span>
          Refresh Data
        </el-button>
      </div>
    </div>

    <!-- Add/Edit Product Modal -->
    <el-dialog
      :model-value="showAddModal || showEditModal"
      :title="showEditModal ? 'Edit Product' : 'Add New Product'"
      width="500px"
      :close-on-click-modal="false"
      @close="closeModal"
    >
      <el-form 
        :model="newProduct" 
        :rules="formRules" 
        ref="productForm"
        label-width="120px"
        @submit.prevent="saveNewProduct"
      >
        <el-form-item label="Product Name" prop="name">
          <el-input
            v-model="newProduct.name"
            placeholder="Enter product name"
            clearable
          />
        </el-form-item>
        
        <el-form-item label="Price" prop="price">
          <el-input-number
            v-model="newProduct.price"
            :min="0"
            :precision="2"
            :step="0.01"
            placeholder="0.00"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="Stock Quantity" prop="stock_quantity">
          <el-input-number
            v-model="newProduct.stock_quantity"
            :min="0"
            placeholder="0"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="Category" prop="category">
          <el-select
            v-model="newProduct.category"
            placeholder="Select a category"
            style="width: 100%"
            clearable
          >
            <el-option
              v-for="category in categories"
              :key="category.id"
              :label="category.name"
              :value="category.name"
            />
          </el-select>
          <div v-if="categories.length === 0" class="form-help">
            <el-alert
              title="No categories found"
              type="warning"
              :closable="false"
              show-icon
            >
              <template #default>
                <NuxtLink to="/categories" class="link">Create categories first</NuxtLink>
              </template>
            </el-alert>
          </div>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeModal">Cancel</el-button>
          <el-button 
            type="primary" 
            @click="saveNewProduct"
            :loading="saving"
          >
            {{ showEditModal ? 'Update Product' : 'Add Product' }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- Delete Confirmation Modal -->
    <el-dialog
      :model-value="showDeleteModal"
      title="Delete Product"
      width="400px"
      :close-on-click-modal="false"
      @close="closeDeleteModal"
    >
      <div class="delete-content">
        <el-alert
          title="Warning"
          type="warning"
          :closable="false"
          show-icon
        >
          <template #default>
            <p>Are you sure you want to delete the product <strong>"{{ productToDelete?.name }}"</strong>?</p>
            <p class="warning-text">This action cannot be undone.</p>
          </template>
        </el-alert>
      </div>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeDeleteModal">Cancel</el-button>
          <el-button 
            type="danger" 
            @click="deleteProduct"
            :loading="deleting"
          >
            Delete Product
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
// Apply authentication middleware
definePageMeta({
  middleware: 'auth'
})

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


// Fetch categories from Supabase
const fetchCategories = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('categories')
    
    if (fetchError) {
      console.error('Error fetching categories:', fetchError)
      return
    }
    
    categories.value = (data as unknown as Array<{id: number, name: string, description?: string}>) || []
  } catch (err) {
    console.error('Error fetching categories:', err)
  }
}

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


// Add new product modal state
const showAddModal = ref(false)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const editingProduct = ref<Product | null>(null)
const productToDelete = ref<Product | null>(null)
const saving = ref(false)
const deleting = ref(false)

const newProduct = reactive({
  name: '',
  price: 0,
  stock_quantity: 0,
  category: ''
})

// Fetch categories from database
const categories = ref<Array<{id: number, name: string, description?: string}>>([])

// Add new product function
const addNewProduct = (): void => {
  showAddModal.value = true
}

// Save new product
const saveNewProduct = async () => {
  try {
    saving.value = true
    
    // Validate form
    if (!newProduct.name || !newProduct.category || newProduct.price <= 0) {
      alert('Please fill in all required fields with valid values')
      return
    }

    if (showEditModal.value) {
      // Update existing product
      await updateProduct()
    } else {
      // Add new product
      const { insert } = useSupabaseDB()
      const { error } = await insert('products', [newProduct])
      
      if (error) {
        console.error('Error adding product:', error)
        alert('Failed to add product. Please try again.')
      } else {
        console.log('Product added successfully!')
        closeModal()
        // Refresh the data
        await Promise.all([
          fetchProducts(),
          fetchCategories()
        ])
      }
    }
  } catch (err) {
    console.error('Error saving product:', err)
    alert('Failed to save product. Please try again.')
  } finally {
    saving.value = false
  }
}

// Open edit modal
const openEditModal = (product: Product) => {
  editingProduct.value = product
  newProduct.name = product.name
  newProduct.price = product.price
  newProduct.stock_quantity = product.stock_quantity
  newProduct.category = product.category
  showEditModal.value = true
}

// Confirm delete
const confirmDelete = (product: Product) => {
  productToDelete.value = product
  showDeleteModal.value = true
}

// Close modals
const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  // Reset form
  Object.assign(newProduct, {
    name: '',
    price: 0,
    stock_quantity: 0,
    category: ''
  })
  editingProduct.value = null
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  productToDelete.value = null
}

// Update product
const updateProduct = async () => {
  try {
    saving.value = true
    
    if (!editingProduct.value) return
    
    if (!newProduct.name.trim()) {
      alert('Please enter a product name')
      return
    }
    
    const { update } = useSupabaseDB()
    const { error } = await update('products', {
      name: newProduct.name.trim(),
      price: newProduct.price,
      stock_quantity: newProduct.stock_quantity,
      category: newProduct.category
    }).eq('id', editingProduct.value.id)
    
    if (error) throw error
    
    closeModal()
    await Promise.all([
      fetchProducts(),
      fetchCategories()
    ])
    
  } catch (err) {
    console.error('Error updating product:', err)
    alert('Failed to update product. Please try again.')
  } finally {
    saving.value = false
  }
}

// Delete product
const deleteProduct = async () => {
  try {
    deleting.value = true
    
    if (!productToDelete.value) return
    
    const { delete: deleteRecord } = useSupabaseDB()
    const { error } = await deleteRecord('products').eq('id', productToDelete.value.id)
    
    if (error) throw error
    
    closeDeleteModal()
    await fetchProducts()
    
  } catch (err) {
    console.error('Error deleting product:', err)
    alert('Failed to delete product. Please try again.')
  } finally {
    deleting.value = false
  }
}

const viewInventory = (): void => {
  console.log('Viewing full inventory...')
  // View inventory logic here
}

// Form validation rules
const formRules = {
  name: [
    { required: true, message: 'Please enter product name', trigger: 'blur' },
    { min: 2, max: 100, message: 'Length should be 2 to 100', trigger: 'blur' }
  ],
  price: [
    { required: true, message: 'Please enter product price', trigger: 'blur' },
    { type: 'number' as const, min: 0, message: 'Price must be greater than 0', trigger: 'blur' }
  ],
  category: [
    { required: true, message: 'Please select a category', trigger: 'change' }
  ]
}

// Helper functions for table display
const getRowClassName = ({ row }: { row: Product }) => {
  if (row.stock_quantity === 0) return 'out-of-stock-row'
  if (row.stock_quantity < 10) return 'low-stock-row'
  return 'in-stock-row'
}

const getStockTagType = (stock: number) => {
  if (stock === 0) return 'danger'
  if (stock < 10) return 'warning'
  return 'success'
}

const getStatusTagType = (stock: number) => {
  if (stock === 0) return 'danger'
  if (stock < 10) return 'warning'
  return 'success'
}

const getStockStatus = (stock: number) => {
  if (stock === 0) return 'Out of Stock'
  if (stock < 10) return 'Low Stock'
  return 'In Stock'
}

// Fetch data on component mount
onMounted(async () => {
  await Promise.all([
    fetchProducts(),
    fetchCategories()
  ])
})
</script>

<style scoped>
.page-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
  background: #f8fafc;
  min-height: 100vh;
}

.page-header {
  text-align: center;
  margin-bottom: 3rem;
}

.page-header h1 {
  color: #1e293b;
  font-size: 3.2rem;
  margin-bottom: 0.5rem;
  font-weight: 800;
  letter-spacing: -0.025em;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.page-header p {
  color: #64748b;
  font-size: 1.3rem;
  font-weight: 500;
  letter-spacing: 0.025em;
}

.stock-grid {
  margin-bottom: 2rem;
  display: flex;
  align-items: stretch;
}

.stock-grid .el-col {
  display: flex;
  flex-direction: column;
}

.stock-card {
  border-radius: 20px;
  border: none;
  overflow: hidden;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* Ensure Element Plus card body takes full height */
:deep(.stock-card .el-card__body) {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.stock-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #3b82f6, #10b981);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.stock-card:hover::before {
  opacity: 1;
}

.stock-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.stock-content {
  display: flex;
  align-items: center;
  padding: 2.5rem;
  gap: 2rem;
  flex: 1;
  height: 100%;
}

.stock-icon {
  width: 90px;
  height: 90px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  position: relative;
  overflow: hidden;
}

.stock-icon::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(255, 255, 255, 0.1), transparent);
  border-radius: 20px;
}

.total-card .stock-icon {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 8px 16px rgba(59, 130, 246, 0.3);
}

.low-stock-card .stock-icon {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: white;
  box-shadow: 0 8px 16px rgba(245, 158, 11, 0.3);
}

.out-of-stock-card .stock-icon {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  color: white;
  box-shadow: 0 8px 16px rgba(239, 68, 68, 0.3);
}

.stock-info {
  flex: 1;
  text-align: left;
}

.stock-info h3 {
  color: #1e293b;
  margin: 0 0 0.5rem 0;
  font-size: 1.3rem;
  font-weight: 700;
  letter-spacing: -0.025em;
}

.stock-number {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 0.25rem;
  color: #10b981;
  letter-spacing: -0.05em;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.stock-number.low-stock {
  color: #f59e0b;
}

.stock-number.out-of-stock {
  color: #ef4444;
}

.stock-description {
  color: #7f8c8d;
  font-size: 0.9rem;
  margin: 0;
}

.stock-actions {
  display: flex;
  gap: 1.5rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 3rem;
}

.stock-actions .el-button {
  height: 56px;
  padding: 0 2rem;
  font-weight: 600;
  font-size: 1rem;
  letter-spacing: 0.025em;
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.stock-actions .el-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.stock-actions .el-button:hover::before {
  left: 100%;
}

.stock-actions .el-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}

/* Table Action Buttons */
:deep(.el-button-group .el-button) {
  border-radius: 12px !important;
  margin: 0 2px !important;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
  position: relative !important;
  overflow: hidden !important;
}

:deep(.el-button-group .el-button::before) {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.3s;
}

:deep(.el-button-group .el-button:hover::before) {
  left: 100%;
}

:deep(.el-button-group .el-button:hover) {
  transform: translateY(-2px) !important;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15) !important;
}

:deep(.el-button-group .el-button--primary) {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8) !important;
  border: none !important;
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3) !important;
}

:deep(.el-button-group .el-button--danger) {
  background: linear-gradient(135deg, #ef4444, #dc2626) !important;
  border: none !important;
  box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3) !important;
}

/* Products Section */
.products-section {
  margin-top: 2rem;
}

.products-card {
  border-radius: 20px;
  border: none;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.products-card:hover {
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
}

.products-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 0;
}

.products-header h2 {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 0;
  color: #1e293b;
  font-size: 1.8rem;
  font-weight: 700;
  letter-spacing: -0.025em;
}

/* Table Styling */
:deep(.el-table) {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

:deep(.el-table__header) {
  background: linear-gradient(135deg, #f8fafc, #e2e8f0);
}

:deep(.el-table__header th) {
  background: transparent !important;
  color: #1e293b !important;
  font-weight: 700 !important;
  font-size: 0.95rem !important;
  letter-spacing: 0.025em !important;
  border-bottom: 2px solid #e2e8f0 !important;
}

:deep(.el-table__body tr) {
  transition: all 0.3s ease;
}

:deep(.el-table__body tr:hover) {
  background: #f8fafc !important;
  transform: scale(1.01);
}

:deep(.el-table__body td) {
  border-bottom: 1px solid #f1f5f9 !important;
  padding: 1rem 0.75rem !important;
}

.product-name {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: #1e293b;
}

.price {
  font-weight: 700;
  color: #10b981;
  font-size: 1.1rem;
  letter-spacing: 0.025em;
}

/* Table row styling */
:deep(.out-of-stock-row) {
  background-color: #fef2f2;
}

:deep(.low-stock-row) {
  background-color: #fffbeb;
}

:deep(.in-stock-row) {
  background-color: #f0fdf4;
}

/* Loading State */
.loading-container {
  display: flex;
  justify-content: center;
  padding: 4rem 2rem;
}

.loading-card {
  border-radius: 16px;
  border: none;
  max-width: 400px;
  width: 100%;
}

.loading-content {
  text-align: center;
  padding: 2rem;
}

.loading-icon {
  color: #3498db;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-content h3 {
  color: #2c3e50;
  margin: 0 0 0.5rem 0;
  font-size: 1.5rem;
}

.loading-content p {
  color: #7f8c8d;
  margin: 0;
}

/* Error State */
.error-container {
  display: flex;
  justify-content: center;
  padding: 2rem;
}

.error-alert {
  max-width: 600px;
  width: 100%;
  border-radius: 12px;
}

.error-content h4 {
  color: #721c24;
  margin: 1rem 0 0.5rem 0;
}

.error-content ol {
  color: #721c24;
  margin: 0.5rem 0;
  padding-left: 1.5rem;
}

.error-content code {
  background: #e9ecef;
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
}

/* Empty State */
.empty-state {
  display: flex;
  justify-content: center;
  padding: 4rem 2rem;
}

.empty-card {
  border-radius: 16px;
  border: none;
  max-width: 500px;
  width: 100%;
}

.empty-content {
  text-align: center;
  padding: 3rem 2rem;
}

.empty-icon {
  color: #bdc3c7;
  margin-bottom: 1.5rem;
}

.empty-content h3 {
  color: #2c3e50;
  margin: 0 0 1rem 0;
  font-size: 1.5rem;
}

.empty-content p {
  color: #7f8c8d;
  margin: 0 0 2rem 0;
  line-height: 1.6;
}

/* Form Help */
.form-help {
  margin-top: 1rem;
}

.form-help .link {
  color: #3498db;
  text-decoration: none;
  font-weight: 600;
}

.form-help .link:hover {
  text-decoration: underline;
}

/* Dialog customization */
:deep(.el-dialog) {
  border-radius: 16px;
}

:deep(.el-dialog__header) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 16px 16px 0 0;
  padding: 1.5rem;
}

:deep(.el-dialog__title) {
  color: white;
  font-weight: 600;
}

:deep(.el-dialog__headerbtn .el-dialog__close) {
  color: white;
  font-size: 1.5rem;
}

:deep(.el-dialog__body) {
  padding: 2rem;
}

:deep(.el-dialog__footer) {
  padding: 1rem 2rem 2rem;
  border-top: 1px solid #f0f0f0;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

/* Delete content */
.delete-content {
  padding: 1rem 0;
}

.warning-text {
  color: #e6a23c;
  font-weight: 600;
  margin: 0.5rem 0 0 0;
}

/* Responsive design */
@media (max-width: 768px) {
  .page-container {
    padding: 1rem;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
  
  .stock-content {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }
  
  .stock-info {
    text-align: center;
  }
  
  .stock-number {
    font-size: 2rem;
  }
  
  .products-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .products-header h2 {
    font-size: 1.3rem;
  }
  
  .stock-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .stock-actions .el-button {
    width: 100%;
    max-width: 300px;
  }
  
  :deep(.el-dialog) {
    width: 95% !important;
    margin: 1rem;
  }
  
  :deep(.el-dialog__body) {
    padding: 1rem;
  }
  
  :deep(.el-dialog__footer) {
    padding: 1rem;
  }
  
  .dialog-footer {
    flex-direction: column;
  }
  
  .dialog-footer .el-button {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .page-header h1 {
    font-size: 1.8rem;
  }
  
  .stock-icon {
    width: 50px;
    height: 50px;
  }
  
  .stock-number {
    font-size: 1.8rem;
  }
  
  .products-header h2 {
    font-size: 1.2rem;
  }
  
  .empty-content {
    padding: 2rem 1rem;
  }
}
</style>

