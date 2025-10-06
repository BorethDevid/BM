<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Order Management</h1>
      <p>Manage customer orders and track order status</p>
    </div>
    
    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading orders...</p>
    </div>
    
    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-message">
        <h3>⚠️ Connection Error</h3>
        <p>{{ error }}</p>
        <p><strong>To fix this:</strong></p>
        <ol>
          <li>Make sure your Supabase connection is working</li>
          <li>Create an <code>orders</code> table in your database</li>
          <li>Check your environment variables</li>
        </ol>
        <button class="btn btn-primary" @click="createOrdersTable">
          Create Orders Table
        </button>
      </div>
    </div>
    
    <!-- Main Content -->
    <div v-else>
      <!-- Action Bar -->
      <div class="action-bar">
        <button class="btn btn-primary" @click="openAddModal">
          <span>+</span> Add New Order
        </button>
        <button class="btn btn-secondary" @click="fetchOrders">
          Refresh
        </button>
      </div>
      
      <!-- Orders Table -->
      <div v-if="orders.length > 0" class="orders-section">
        <div class="table-container">
          <table class="orders-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Product</th>
                <th>Quantity</th>
                <th>Total</th>
                <th>Status</th>
                <th>Order Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in orders" :key="order.id">
                <td>#{{ order.id }}</td>
                <td>
                  <div class="customer-info">
                    <strong>{{ order.customer_name }}</strong>
                    <br>
                    <small>{{ order.customer_email }}</small>
                  </div>
                </td>
                <td>{{ order.product_name }}</td>
                <td>{{ order.quantity }}</td>
                <td>${{ order.total_amount.toFixed(2) }}</td>
                <td>
                  <span 
                    class="status-badge"
                    :class="{
                      'pending': order.status === 'Pending',
                      'processing': order.status === 'Processing',
                      'shipped': order.status === 'Shipped',
                      'delivered': order.status === 'Delivered',
                      'cancelled': order.status === 'Cancelled'
                    }"
                  >
                    {{ order.status }}
                  </span>
                </td>
                <td>{{ formatDate(order.created_at) }}</td>
                <td>
                  <div class="action-buttons">
                    <button 
                      class="btn btn-sm btn-edit" 
                      @click="openEditModal(order)"
                      title="Edit order"
                    >
                      ✏️
                    </button>
                    <button 
                      class="btn btn-sm btn-delete" 
                      @click="confirmDelete(order)"
                      title="Delete order"
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
        <h3>No Orders Found</h3>
        <p>Create your first order to get started!</p>
        <button class="btn btn-primary" @click="openAddModal">
          Add First Order
        </button>
      </div>
    </div>

    <!-- Add/Edit Order Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Order' : 'Add New Order' }}</h2>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>
        
        <form @submit.prevent="saveOrder" class="order-form">
          <div class="form-row">
            <div class="form-group">
              <label for="customerName">Customer Name *</label>
              <input
                id="customerName"
                v-model="orderForm.customer_name"
                type="text"
                placeholder="Enter customer name"
                required
              />
            </div>
            
            <div class="form-group">
              <label for="customerEmail">Customer Email *</label>
              <input
                id="customerEmail"
                v-model="orderForm.customer_email"
                type="email"
                placeholder="Enter customer email"
                required
              />
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="productName">Product Name *</label>
              <input
                id="productName"
                v-model="orderForm.product_name"
                type="text"
                placeholder="Enter product name"
                required
              />
            </div>
            
            <div class="form-group">
              <label for="quantity">Quantity *</label>
              <input
                id="quantity"
                v-model.number="orderForm.quantity"
                type="number"
                min="1"
                placeholder="1"
                required
              />
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="unitPrice">Unit Price *</label>
              <input
                id="unitPrice"
                v-model.number="orderForm.unit_price"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                required
              />
            </div>
            
            <div class="form-group">
              <label for="orderStatus">Status *</label>
              <select
                id="orderStatus"
                v-model="orderForm.status"
                required
              >
                <option value="">Select status</option>
                <option value="Pending">Pending</option>
                <option value="Processing">Processing</option>
                <option value="Shipped">Shipped</option>
                <option value="Delivered">Delivered</option>
                <option value="Cancelled">Cancelled</option>
              </select>
            </div>
          </div>
          
          <div class="form-group">
            <label for="notes">Notes</label>
            <textarea
              id="notes"
              v-model="orderForm.notes"
              placeholder="Enter order notes (optional)"
              rows="3"
            ></textarea>
          </div>
          
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeModal">
              Cancel
            </button>
            <button type="submit" class="btn btn-primary" :disabled="saving">
              {{ saving ? 'Saving...' : (isEditing ? 'Update Order' : 'Add Order') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="closeDeleteModal">
      <div class="modal-content delete-modal" @click.stop>
        <div class="modal-header">
          <h2>Delete Order</h2>
          <button class="modal-close" @click="closeDeleteModal">&times;</button>
        </div>
        
        <div class="delete-content">
          <p>Are you sure you want to delete order <strong>#{{ orderToDelete?.id }}</strong>?</p>
          <p class="warning">This action cannot be undone.</p>
          
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeDeleteModal">
              Cancel
            </button>
            <button 
              type="button" 
              class="btn btn-danger" 
              @click="deleteOrder"
              :disabled="deleting"
            >
              {{ deleting ? 'Deleting...' : 'Delete Order' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Order management page
interface Order {
  id: number
  customer_name: string
  customer_email: string
  product_name: string
  quantity: number
  unit_price: number
  total_amount: number
  status: string
  notes?: string
  created_at: string
}

// Reactive data
const orders = ref<Order[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const saving = ref(false)
const deleting = ref(false)

// Modal states
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const orderToDelete = ref<Order | null>(null)

// Form data
const orderForm = reactive({
  customer_name: '',
  customer_email: '',
  product_name: '',
  quantity: 1,
  unit_price: 0,
  status: '',
  notes: ''
})

// Fetch orders from Supabase
const fetchOrders = async () => {
  try {
    loading.value = true
    error.value = null
    
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('orders')
    
    if (fetchError) {
      throw fetchError
    }
    
    orders.value = (data as unknown as Order[]) || []
    
  } catch (err) {
    console.error('Error fetching orders:', err)
    error.value = 'Failed to load orders. Please check your Supabase connection.'
  } finally {
    loading.value = false
  }
}

// Create orders table (for setup)
const createOrdersTable = async () => {
  try {
    alert('Please create the orders table in your Supabase SQL editor with this SQL:\n\n' +
          'CREATE TABLE orders (\n' +
          '  id BIGSERIAL PRIMARY KEY,\n' +
          '  customer_name TEXT NOT NULL,\n' +
          '  customer_email TEXT NOT NULL,\n' +
          '  product_name TEXT NOT NULL,\n' +
          '  quantity INTEGER NOT NULL,\n' +
          '  unit_price NUMERIC NOT NULL,\n' +
          '  total_amount NUMERIC NOT NULL,\n' +
          '  status TEXT NOT NULL DEFAULT \'Pending\',\n' +
          '  notes TEXT,\n' +
          '  created_at TIMESTAMPTZ DEFAULT NOW()\n' +
          ');\n\n' +
          'ALTER TABLE orders ENABLE ROW LEVEL SECURITY;\n\n' +
          'CREATE POLICY "Allow all operations on orders" ON orders\n' +
          '  FOR ALL USING (true);')
  } catch (err) {
    console.error('Error creating table:', err)
  }
}

// Open add modal
const openAddModal = () => {
  isEditing.value = false
  Object.assign(orderForm, {
    customer_name: '',
    customer_email: '',
    product_name: '',
    quantity: 1,
    unit_price: 0,
    status: '',
    notes: ''
  })
  showModal.value = true
}

// Open edit modal
const openEditModal = (order: Order) => {
  isEditing.value = true
  Object.assign(orderForm, {
    customer_name: order.customer_name,
    customer_email: order.customer_email,
    product_name: order.product_name,
    quantity: order.quantity,
    unit_price: order.unit_price,
    status: order.status,
    notes: order.notes || ''
  })
  showModal.value = true
}

// Close modal
const closeModal = () => {
  showModal.value = false
  Object.assign(orderForm, {
    customer_name: '',
    customer_email: '',
    product_name: '',
    quantity: 1,
    unit_price: 0,
    status: '',
    notes: ''
  })
  isEditing.value = false
}

// Confirm delete
const confirmDelete = (order: Order) => {
  orderToDelete.value = order
  showDeleteModal.value = true
}

// Close delete modal
const closeDeleteModal = () => {
  showDeleteModal.value = false
  orderToDelete.value = null
}

// Save order (add or update)
const saveOrder = async () => {
  try {
    saving.value = true
    
    // Validate form
    if (!orderForm.customer_name || !orderForm.customer_email || !orderForm.product_name || !orderForm.status) {
      alert('Please fill in all required fields')
      return
    }
    
    // Calculate total amount
    const totalAmount = orderForm.quantity * orderForm.unit_price
    
    const orderData = {
      customer_name: orderForm.customer_name.trim(),
      customer_email: orderForm.customer_email.trim(),
      product_name: orderForm.product_name.trim(),
      quantity: orderForm.quantity,
      unit_price: orderForm.unit_price,
      total_amount: totalAmount,
      status: orderForm.status,
      notes: orderForm.notes.trim() || null
    }
    
    if (isEditing.value) {
      // Update existing order
      const { update } = useSupabaseDB()
      const { error } = await update('orders', orderData).eq('id', orderToDelete.value?.id)
      
      if (error) throw error
    } else {
      // Add new order
      const { insert } = useSupabaseDB()
      const { error } = await insert('orders', [orderData])
      
      if (error) throw error
    }
    
    closeModal()
    await fetchOrders()
    
  } catch (err) {
    console.error('Error saving order:', err)
    alert('Failed to save order. Please try again.')
  } finally {
    saving.value = false
  }
}

// Delete order
const deleteOrder = async () => {
  try {
    deleting.value = true
    
    if (!orderToDelete.value) return
    
    const { delete: deleteRecord } = useSupabaseDB()
    const { error } = await deleteRecord('orders').eq('id', orderToDelete.value.id)
    
    if (error) throw error
    
    closeDeleteModal()
    await fetchOrders()
    
  } catch (err) {
    console.error('Error deleting order:', err)
    alert('Failed to delete order. Please try again.')
  } finally {
    deleting.value = false
  }
}

// Format date with time
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const dateStr = date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
  const timeStr = date.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true
  })
  return `${dateStr} ${timeStr}`
}

// Fetch data on component mount
onMounted(() => {
  fetchOrders()
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

.orders-table {
  width: 100%;
  border-collapse: collapse;
}

.orders-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
}

.orders-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
}

.orders-table tr:hover {
  background: #f8f9fa;
}

.customer-info {
  line-height: 1.4;
}

.customer-info strong {
  color: #2c3e50;
  font-weight: 600;
}

.customer-info small {
  color: #7f8c8d;
  font-size: 0.85rem;
}

/* Status Badges */
.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.pending {
  background: #fff3cd;
  color: #856404;
}

.status-badge.processing {
  background: #cce5ff;
  color: #004085;
}

.status-badge.shipped {
  background: #d1ecf1;
  color: #0c5460;
}

.status-badge.delivered {
  background: #d4edda;
  color: #155724;
}

.status-badge.cancelled {
  background: #f8d7da;
  color: #721c24;
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
  max-width: 600px;
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

.order-form {
  padding: 1.5rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1.5rem;
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
.form-group select,
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
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
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
  
  .orders-table {
    min-width: 800px;
  }
  
  .form-row {
    grid-template-columns: 1fr;
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
