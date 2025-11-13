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
        <div class="products-header">
          <h2>Products Inventory</h2>
          <div class="category-filter">
            <label>Filter by Category:</label>
            <div class="multiselect-wrapper">
              <div class="multiselect-container" @click="toggleDropdown" ref="multiselectRef">
                <div class="multiselect-input">
                  <div class="selected-tags">
                    <span v-if="selectedCategories.length === 0" class="placeholder">
                      All Categories
                    </span>
                    <span
                      v-for="category in selectedCategories"
                      :key="category"
                      class="tag"
                    >
                      {{ category }}
                      <button
                        @click.stop="removeCategory(category)"
                        class="tag-remove"
                        aria-label="Remove category"
                      >
                        ×
                      </button>
                    </span>
                  </div>
                  <div class="multiselect-arrow" :class="{ open: isDropdownOpen }">
                    ▼
                  </div>
                </div>

                <div v-if="isDropdownOpen" class="multiselect-dropdown" @click.stop>
                  <div class="search-box">
                    <input
                      v-model="searchQuery"
                      type="text"
                      placeholder="Search categories..."
                      class="search-input"
                      @click.stop
                      ref="searchInputRef"
                    />
                  </div>
                  <div class="options-list">
                    <label
                      v-for="category in filteredCategories"
                      :key="category.id"
                      class="option-item"
                    >
                      <input
                        type="checkbox"
                        :value="category.name"
                        :checked="selectedCategories.includes(category.name)"
                        @change="toggleCategory(category.name)"
                        class="option-checkbox"
                      />
                      <span class="option-label">{{ category.name }}</span>
                    </label>
                    <div v-if="filteredCategories.length === 0" class="no-results">
                      No categories found
                    </div>
                  </div>
                  <div class="dropdown-footer">
                    <button @click.stop="clearAll" class="btn-clear">Clear All</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="products-table-container">
          <table class="products-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in filteredProducts" :key="product.id">
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
                <td>
                  <div class="action-buttons">
                    <button 
                      class="btn btn-sm btn-edit" 
                      @click="openEditModal(product)"
                      title="Edit product"
                    >
                      ✏️
                    </button>
                    <button 
                      class="btn btn-sm btn-delete" 
                      @click="confirmDelete(product)"
                      title="Delete product"
                    >
                      🗑️
                    </button>
                  </div>
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
      </div>
      
      <div class="stock-actions">
        <button class="btn btn-primary" @click="addNewProduct">
          Add New Product
        </button>
        <button class="btn btn-secondary" @click="fetchProducts">
          Refresh Data
        </button>
      </div>
    </div>

    <!-- Add/Edit Product Modal -->
    <div v-if="showAddModal || showEditModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ showEditModal ? 'Edit Product' : 'Add New Product' }}</h2>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>
        
        <form @submit.prevent="saveNewProduct" class="product-form">
          <div class="form-group">
            <label for="productName">Product Name *</label>
            <input
              id="productName"
              v-model="newProduct.name"
              type="text"
              placeholder="Enter product name"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="productPrice">Price *</label>
            <input
              id="productPrice"
              v-model.number="newProduct.price"
              type="number"
              step="0.01"
              min="0"
              placeholder="0.00"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="productStock">Stock Quantity</label>
            <input
              id="productStock"
              v-model.number="newProduct.stock_quantity"
              type="number"
              min="0"
              placeholder="0"
            />
          </div>
          
          <div class="form-group">
            <label for="productCategory">Category *</label>
            <select
              id="productCategory"
              v-model="newProduct.category"
              required
            >
              <option value="">Select a category</option>
              <option v-for="category in categories" :key="category.id" :value="category.name">
                {{ category.name }}
              </option>
            </select>
            <p v-if="categories.length === 0" class="form-help">
              No categories found. <NuxtLink to="/categories" class="link">Create categories first</NuxtLink>
            </p>
          </div>
          
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeModal">
              Cancel
            </button>
            <button type="submit" class="btn btn-primary" :disabled="saving">
              {{ saving ? 'Saving...' : (showEditModal ? 'Update Product' : 'Add Product') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="closeDeleteModal">
      <div class="modal-content delete-modal" @click.stop>
        <div class="modal-header">
          <h2>Delete Product</h2>
          <button class="modal-close" @click="closeDeleteModal">&times;</button>
        </div>
        
        <div class="delete-content">
          <p>Are you sure you want to delete the product <strong>"{{ productToDelete?.name }}"</strong>?</p>
          <p class="warning">This action cannot be undone.</p>
          
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeDeleteModal">
              Cancel
            </button>
            <button 
              type="button" 
              class="btn btn-danger" 
              @click="deleteProduct"
              :disabled="deleting"
            >
              {{ deleting ? 'Deleting...' : 'Delete Product' }}
            </button>
          </div>
        </div>
      </div>
    </div>
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

// Computed properties for filtered statistics
const totalProducts = computed(() => {
  return selectedCategories.value.length > 0
    ? filteredProducts.value.length
    : stockData.totalProducts
})

const lowStockItems = computed(() => {
  return selectedCategories.value.length > 0
    ? filteredProducts.value.filter((p: Product) => p.stock_quantity > 0 && p.stock_quantity < 10).length
    : stockData.lowStockItems
})

const outOfStockItems = computed(() => {
  return selectedCategories.value.length > 0
    ? filteredProducts.value.filter((p: Product) => p.stock_quantity === 0).length
    : stockData.outOfStockItems
})


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

// Multi-select category filter
const selectedCategories = ref<string[]>([])
const isDropdownOpen = ref(false)
const searchQuery = ref('')
const multiselectRef = ref<HTMLElement | null>(null)
const searchInputRef = ref<HTMLInputElement | null>(null)

// Computed property for filtered categories based on search
const filteredCategories = computed(() => {
  if (!searchQuery.value) {
    return categories.value
  }
  const query = searchQuery.value.toLowerCase()
  return categories.value.filter(cat =>
    cat.name.toLowerCase().includes(query)
  )
})

// Computed property for filtered products based on selected categories
const filteredProducts = computed(() => {
  if (selectedCategories.value.length === 0) {
    return products.value
  }
  return products.value.filter(product =>
    selectedCategories.value.includes(product.category)
  )
})

// Multi-select functions
const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value
  if (isDropdownOpen.value) {
    nextTick(() => {
      searchInputRef.value?.focus()
    })
  }
}

const toggleCategory = (categoryName: string) => {
  const index = selectedCategories.value.indexOf(categoryName)
  if (index > -1) {
    selectedCategories.value.splice(index, 1)
  } else {
    selectedCategories.value.push(categoryName)
  }
}

const removeCategory = (categoryName: string) => {
  const index = selectedCategories.value.indexOf(categoryName)
  if (index > -1) {
    selectedCategories.value.splice(index, 1)
  }
}

const clearAll = () => {
  selectedCategories.value = []
  searchQuery.value = ''
}

// Close dropdown when clicking outside
const handleClickOutside = (event: MouseEvent) => {
  if (multiselectRef.value && !multiselectRef.value.contains(event.target as Node)) {
    isDropdownOpen.value = false
    searchQuery.value = ''
  }
}

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

// Fetch data on component mount
onMounted(async () => {
  await Promise.all([
    fetchProducts(),
    fetchCategories()
  ])

  // Add click outside listener for multiselect
  document.addEventListener('click', handleClickOutside)
})

// Cleanup on unmount
onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.page-container {
  width: 100%;
  padding: 0;
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

.products-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.products-section h2 {
  color: #2c3e50;
  margin: 0;
}

.category-filter {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.category-filter label {
  color: #2c3e50;
  font-weight: 600;
  font-size: 0.95rem;
  white-space: nowrap;
}

/* Multi-select Container */
.multiselect-wrapper {
  position: relative;
  min-width: 300px;
  max-width: 500px;
}

.multiselect-container {
  position: relative;
  cursor: pointer;
}

.multiselect-input {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 10px;
  background: white;
  min-height: 44px;
  transition: all 0.3s ease;
  gap: 0.5rem;
}

.multiselect-input:hover {
  border-color: #3498db;
  box-shadow: 0 2px 8px rgba(52, 152, 219, 0.15);
}

.selected-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  flex: 1;
  align-items: center;
}

.placeholder {
  color: #7f8c8d;
  font-size: 0.95rem;
}

.tag {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.3rem 0.6rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 500;
  animation: tagAppear 0.2s ease;
}

@keyframes tagAppear {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.tag-remove {
  background: rgba(255, 255, 255, 0.3);
  border: none;
  color: white;
  cursor: pointer;
  padding: 0;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  line-height: 1;
  transition: all 0.2s ease;
}

.tag-remove:hover {
  background: rgba(255, 255, 255, 0.5);
  transform: rotate(90deg);
}

.multiselect-arrow {
  color: #7f8c8d;
  font-size: 0.7rem;
  transition: transform 0.3s ease;
  margin-left: auto;
  padding-left: 0.5rem;
}

.multiselect-arrow.open {
  transform: rotate(180deg);
}

/* Dropdown */
.multiselect-dropdown {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  right: 0;
  background: white;
  border: 2px solid #3498db;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-height: 400px;
  display: flex;
  flex-direction: column;
  animation: dropdownSlide 0.3s ease;
}

@keyframes dropdownSlide {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.search-box {
  padding: 0.75rem;
  border-bottom: 1px solid #e9ecef;
  background: #f8f9fa;
  border-radius: 10px 10px 0 0;
}

.search-input {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 0.9rem;
  transition: all 0.3s ease;
  background: white;
}

.search-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.search-input::placeholder {
  color: #adb5bd;
}

.options-list {
  overflow-y: auto;
  max-height: 250px;
  padding: 0.5rem;
}

.option-item {
  display: flex;
  align-items: center;
  padding: 0.65rem 0.75rem;
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.2s ease;
  gap: 0.75rem;
}

.option-item:hover {
  background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
  transform: translateX(4px);
}

.option-checkbox {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: #667eea;
}

.option-label {
  flex: 1;
  color: #2c3e50;
  font-size: 0.9rem;
  user-select: none;
}

.no-results {
  padding: 2rem 1rem;
  text-align: center;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.dropdown-footer {
  padding: 0.75rem;
  border-top: 1px solid #e9ecef;
  background: #f8f9fa;
  border-radius: 0 0 10px 10px;
}

.btn-clear {
  width: 100%;
  padding: 0.5rem;
  background: linear-gradient(135deg, #fc5c7d 0%, #6a82fb 100%);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-clear:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(252, 92, 125, 0.3);
}

.btn-clear:active {
  transform: translateY(0);
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

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #dee2e6;
}

.modal-header h2 {
  margin: 0;
  color: #2c3e50;
  font-size: 1.5rem;
}

.modal-close {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #7f8c8d;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  color: #e74c3c;
}

.product-form {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #2c3e50;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-help {
  margin-top: 0.5rem;
  font-size: 0.9rem;
  color: #7f8c8d;
}

.form-help .link {
  color: #3498db;
  text-decoration: none;
  font-weight: 600;
}

.form-help .link:hover {
  text-decoration: underline;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.btn-sm {
  padding: 0.5rem;
  font-size: 0.9rem;
  min-width: auto;
}

.btn-edit {
  background-color: #ffc107;
  color: #212529;
}

.btn-edit:hover {
  background-color: #e0a800;
}

.btn-delete {
  background-color: #dc3545;
  color: white;
}

.btn-delete:hover {
  background-color: #c82333;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}

.btn-danger:hover {
  background-color: #c82333;
}

/* Delete Modal */
.delete-modal {
  max-width: 400px;
}

.delete-content {
  padding: 1.5rem;
}

.delete-content p {
  margin-bottom: 1rem;
  color: #495057;
}

.warning {
  color: #dc3545;
  font-weight: 600;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
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
  
  .modal-content {
    width: 95%;
    margin: 1rem;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .form-actions .btn {
    width: 100%;
  }

  .products-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .category-filter {
    width: 100%;
    flex-direction: column;
    align-items: flex-start;
  }

  .multiselect-wrapper {
    width: 100%;
    min-width: auto;
    max-width: none;
  }

  .multiselect-input {
    min-height: 50px;
  }

  .tag {
    font-size: 0.8rem;
    padding: 0.25rem 0.5rem;
  }
}
</style>

