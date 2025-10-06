<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Category Management</h1>
      <p>Manage product categories and organize your inventory</p>
    </div>
    
    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading categories...</p>
    </div>
    
    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-message">
        <h3>⚠️ Connection Error</h3>
        <p>{{ error }}</p>
        <p><strong>To fix this:</strong></p>
        <ol>
          <li>Make sure your Supabase connection is working</li>
          <li>Create a <code>categories</code> table in your database</li>
          <li>Check your environment variables</li>
        </ol>
        <button class="btn btn-primary" @click="createCategoriesTable">
          Create Categories Table
        </button>
      </div>
    </div>
    
    <!-- Main Content -->
    <div v-else>
      <!-- Action Bar -->
      <div class="action-bar">
        <button class="btn btn-primary" @click="openAddModal">
          <span>+</span> Add New Category
        </button>
        <button class="btn btn-secondary" @click="fetchCategories">
          Refresh
        </button>
      </div>
      
      <!-- Categories Table -->
      <div v-if="categories.length > 0" class="categories-section">
        <div class="table-container">
          <table class="categories-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
                <th>Product Count</th>
                <th>Created</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="category in categories" :key="category.id">
                <td>{{ category.id }}</td>
                <td>
                  <span class="category-name">{{ category.name }}</span>
                </td>
                <td>{{ category.description || 'No description' }}</td>
                <td>
                  <span class="product-count">{{ getProductCount(category.name) }}</span>
                </td>
                <td>{{ formatDate(category.created_at) }}</td>
                <td>
                  <div class="action-buttons">
                    <button 
                      class="btn btn-sm btn-edit" 
                      @click="openEditModal(category)"
                      title="Edit category"
                    >
                      ✏️
                    </button>
                    <button 
                      class="btn btn-sm btn-delete" 
                      @click="confirmDelete(category)"
                      title="Delete category"
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
        <h3>No Categories Found</h3>
        <p>Create your first category to organize your products!</p>
        <button class="btn btn-primary" @click="openAddModal">
          Add First Category
        </button>
      </div>
    </div>

    <!-- Add/Edit Category Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Category' : 'Add New Category' }}</h2>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>
        
        <form @submit.prevent="saveCategory" class="category-form">
          <div class="form-group">
            <label for="categoryName">Category Name *</label>
            <input
              id="categoryName"
              v-model="categoryForm.name"
              type="text"
              placeholder="Enter category name"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="categoryDescription">Description</label>
            <textarea
              id="categoryDescription"
              v-model="categoryForm.description"
              placeholder="Enter category description (optional)"
              rows="3"
            ></textarea>
          </div>
          
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeModal">
              Cancel
            </button>
            <button type="submit" class="btn btn-primary" :disabled="saving">
              {{ saving ? 'Saving...' : (isEditing ? 'Update Category' : 'Add Category') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="closeDeleteModal">
      <div class="modal-content delete-modal" @click.stop>
        <div class="modal-header">
          <h2>Delete Category</h2>
          <button class="modal-close" @click="closeDeleteModal">&times;</button>
        </div>
        
        <div class="delete-content">
          <p>Are you sure you want to delete the category <strong>"{{ categoryToDelete?.name }}"</strong>?</p>
          <p class="warning">This action cannot be undone.</p>
          
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeDeleteModal">
              Cancel
            </button>
            <button 
              type="button" 
              class="btn btn-danger" 
              @click="deleteCategory"
              :disabled="deleting"
            >
              {{ deleting ? 'Deleting...' : 'Delete Category' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Category management page
interface Category {
  id: number
  name: string
  description?: string
  created_at: string
}

interface Product {
  id: number
  name: string
  category: string
  price: number
  stock_quantity: number
}

// Reactive data
const categories = ref<Category[]>([])
const products = ref<Product[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const saving = ref(false)
const deleting = ref(false)

// Modal states
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const categoryToDelete = ref<Category | null>(null)

// Form data
const categoryForm = reactive({
  name: '',
  description: ''
})

// Fetch categories from Supabase
const fetchCategories = async () => {
  try {
    loading.value = true
    error.value = null
    
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('categories')
    
    if (fetchError) {
      throw fetchError
    }
    
    categories.value = (data as unknown as Category[]) || []
    
    // Also fetch products to show counts
    const { data: productsData, error: productsError } = await select('products')
    if (!productsError && productsData) {
      products.value = (productsData as unknown as Product[]) || []
    }
    
  } catch (err) {
    console.error('Error fetching categories:', err)
    error.value = 'Failed to load categories. Please check your Supabase connection.'
  } finally {
    loading.value = false
  }
}

// Create categories table (for setup)
const createCategoriesTable = async () => {
  try {
    const supabase = useSupabase()
    
    // This would typically be done via SQL editor in Supabase
    alert('Please create the categories table in your Supabase SQL editor with this SQL:\n\n' +
          'CREATE TABLE categories (\n' +
          '  id BIGSERIAL PRIMARY KEY,\n' +
          '  name TEXT NOT NULL UNIQUE,\n' +
          '  description TEXT,\n' +
          '  created_at TIMESTAMPTZ DEFAULT NOW()\n' +
          ');\n\n' +
          'ALTER TABLE categories ENABLE ROW LEVEL SECURITY;\n\n' +
          'CREATE POLICY "Allow all operations on categories" ON categories\n' +
          '  FOR ALL USING (true);')
  } catch (err) {
    console.error('Error creating table:', err)
  }
}

// Open add modal
const openAddModal = () => {
  isEditing.value = false
  categoryForm.name = ''
  categoryForm.description = ''
  showModal.value = true
}

// Open edit modal
const openEditModal = (category: Category) => {
  isEditing.value = true
  categoryForm.name = category.name
  categoryForm.description = category.description || ''
  showModal.value = true
}

// Close modal
const closeModal = () => {
  showModal.value = false
  categoryForm.name = ''
  categoryForm.description = ''
}

// Save category (add or update)
const saveCategory = async () => {
  try {
    saving.value = true
    
    if (!categoryForm.name.trim()) {
      alert('Please enter a category name')
      return
    }
    
    const { insert, update } = useSupabaseDB()
    
    if (isEditing.value) {
      // Update existing category
      const categoryToUpdate = categories.value.find(c => c.name === categoryForm.name)
      if (categoryToUpdate) {
        const { error } = await update('categories', {
          description: categoryForm.description
        }).eq('id', categoryToUpdate.id)
        
        if (error) throw error
      }
    } else {
      // Add new category
      const { error } = await insert('categories', [{
        name: categoryForm.name.trim(),
        description: categoryForm.description.trim() || null
      }])
      
      if (error) throw error
    }
    
    closeModal()
    await fetchCategories()
    
  } catch (err) {
    console.error('Error saving category:', err)
    alert('Failed to save category. Please try again.')
  } finally {
    saving.value = false
  }
}

// Confirm delete
const confirmDelete = (category: Category) => {
  categoryToDelete.value = category
  showDeleteModal.value = true
}

// Close delete modal
const closeDeleteModal = () => {
  showDeleteModal.value = false
  categoryToDelete.value = null
}

// Delete category
const deleteCategory = async () => {
  try {
    deleting.value = true
    
    if (!categoryToDelete.value) return
    
    const { delete: deleteRecord } = useSupabaseDB()
    const { error } = await deleteRecord('categories').eq('id', categoryToDelete.value.id)
    
    if (error) throw error
    
    closeDeleteModal()
    await fetchCategories()
    
  } catch (err) {
    console.error('Error deleting category:', err)
    alert('Failed to delete category. Please try again.')
  } finally {
    deleting.value = false
  }
}

// Get product count for category
const getProductCount = (categoryName: string) => {
  return products.value.filter(p => p.category === categoryName).length
}

// Format date
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString()
}

// Fetch data on component mount
onMounted(() => {
  fetchCategories()
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

/* Action Bar */
.action-bar {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  justify-content: space-between;
  align-items: center;
}

.action-bar .btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
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

/* Table Styles */
.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.categories-table {
  width: 100%;
  border-collapse: collapse;
}

.categories-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
}

.categories-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
}

.categories-table tr:hover {
  background: #f8f9fa;
}

.category-name {
  font-weight: 600;
  color: #2c3e50;
}

.product-count {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.25rem 0.5rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

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

.delete-modal {
  max-width: 400px;
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

.category-form {
  padding: 1.5rem;
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
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

/* Button Styles */
.btn {
  padding: 0.75rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover:not(:disabled) {
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

/* Responsive design */
@media (max-width: 768px) {
  .page-container {
    padding: 1rem;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
  
  .action-bar {
    flex-direction: column;
    align-items: stretch;
  }
  
  .table-container {
    overflow-x: auto;
  }
  
  .categories-table {
    min-width: 600px;
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
}
</style>
