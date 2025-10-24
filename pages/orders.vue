<template>
  <div class="page-container" :class="{ 'expanded': isTableExpanded }">
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
        <div class="action-left">
          <button class="btn btn-primary" @click="openAddModal">
            <span>+</span> Add New Order
          </button>
          <button class="btn btn-secondary" @click="fetchOrders">
            Refresh
          </button>
          <button class="btn btn-outline" @click="toggleFilters">
            <span>🔍</span> Filters
          </button>
        </div>
        <div class="action-right">
          <button class="btn btn-outline" @click="toggleTableWidth">
            <span>{{ isTableExpanded ? '⬅️' : '➡️' }}</span> {{ isTableExpanded ? 'Collapse' : 'Expand' }}
          </button>
          <button class="btn btn-outline" @click="toggleColumnMenu">
            <span>👁️</span> Columns
          </button>
        </div>
      </div>
      
      <!-- Filter Panel -->
      <div v-if="showFilters" class="filter-panel">
        <div class="filter-header">
          <h3>🔍 Filter Orders</h3>
          <button class="btn btn-sm btn-outline" @click="clearFilters">
            Clear All
          </button>
        </div>
        
        <div class="filter-grid">
          <!-- Date Range -->
          <div class="filter-group">
            <label>Date Range</label>
            <div class="date-range">
              <input 
                type="date" 
                v-model="filters.dateFrom" 
                placeholder="From Date"
                class="form-input"
                title="From Date"
              />
              <input 
                type="date" 
                v-model="filters.dateTo" 
                placeholder="To Date"
                class="form-input"
                title="To Date"
              />
            </div>
          </div>
          
          <!-- Status Filter - COMMENTED OUT -->
          <!-- <div class="filter-group">
            <label>Status</label>
            <select v-model="filters.status" class="form-select">
              <option value="">All Statuses</option>
              <option value="Pending">Pending</option>
              <option value="Processing">Processing</option>
              <option value="Shipped">Shipped</option>
              <option value="Delivered">Delivered</option>
              <option value="Cancelled">Cancelled</option>
            </select>
          </div> -->
          
          <!-- Channel Filter - COMMENTED OUT -->
          <!-- <div class="filter-group">
            <label>Channel</label>
            <select v-model="filters.channel" class="form-select">
              <option value="">All Channels</option>
              <option v-for="channel in socialChannels" :key="channel.name" :value="channel.name">
                {{ channel.name }}
              </option>
            </select>
          </div> -->
          
          <!-- Location Filter - COMMENTED OUT -->
          <!-- <div class="filter-group">
            <label>Location</label>
            <select v-model="filters.location" class="form-select">
              <option value="">All Locations</option>
              <option v-for="province in cambodiaProvinces" :key="province.name" :value="province.name">
                {{ province.name }}
              </option>
            </select>
          </div> -->
          
          <!-- Customer Name Search - COMMENTED OUT -->
          <!-- <div class="filter-group">
            <label>Customer Name</label>
            <input 
              type="text" 
              v-model="filters.customerName" 
              placeholder="Search customer name..."
              class="form-input"
            />
          </div> -->
          
          <!-- Product Name Search - COMMENTED OUT -->
          <!-- <div class="filter-group">
            <label>Product Name</label>
            <input 
              type="text" 
              v-model="filters.productName" 
              placeholder="Search product name..."
              class="form-input"
            />
          </div> -->
          
          <!-- Amount Range - COMMENTED OUT -->
          <!-- <div class="filter-group">
            <label>Amount Range</label>
            <div class="amount-range">
              <input 
                type="number" 
                v-model="filters.minAmount" 
                placeholder="Min Amount"
                class="form-input"
                step="0.01"
                min="0"
              />
              <input 
                type="number" 
                v-model="filters.maxAmount" 
                placeholder="Max Amount"
                class="form-input"
                step="0.01"
                min="0"
              />
            </div>
          </div> -->
        </div>
        
        <div class="filter-footer">
          <div class="filter-stats">
            <span v-if="!filtersApplied">
              Showing all {{ totalOrders }} orders
            </span>
            <span v-else>
              Showing {{ filteredOrders.length }} of {{ totalOrders }} orders (filtered)
            </span>
          </div>
          <div class="filter-actions">
            <button class="btn btn-sm btn-outline" @click="clearFilters">
              Clear
            </button>
            <button class="btn btn-sm btn-primary" @click="applyFilters">
              Apply Filters
            </button>
          </div>
        </div>
      </div>
      
      <!-- Column Toggle Menu -->
      <div v-if="showColumnMenu" class="column-menu">
        <div class="column-menu-header">
          <h3>Show/Hide Columns</h3>
          <button class="menu-close" @click="toggleColumnMenu">&times;</button>
        </div>
        <div class="column-options">
          <label v-for="column in availableColumns" :key="column.key" class="column-option">
            <input 
              type="checkbox" 
              :checked="getColumnVisibility(column.key)"
              @change="toggleColumn(column.key)"
            />
            <span class="column-label">{{ column.label }}</span>
          </label>
        </div>
        <div class="column-menu-actions">
          <button class="btn btn-sm btn-secondary" @click="showAllColumns">Show All</button>
          <button class="btn btn-sm btn-secondary" @click="hideAllColumns">Hide All</button>
          <button class="btn btn-sm btn-primary" @click="resetColumns">Reset</button>
        </div>
      </div>
      
      <!-- Orders Table -->
      <div v-if="orders.length > 0" class="orders-section">
        <div class="table-container">
          <table class="orders-table">
            <thead>
              <tr>
                <th
                  v-for="columnKey in columnOrder"
                  :key="columnKey"
                  v-show="getColumnVisibility(columnKey)"
                  :draggable="true"
                  @dragstart="handleDragStart($event, columnKey)"
                  @dragover="handleDragOver($event, columnKey)"
                  @dragleave="handleDragLeave"
                  @drop="handleDrop($event, columnKey)"
                  @dragend="handleDragEnd"
                  :class="{
                    'dragging': draggedColumn === columnKey,
                    'drag-over': dragOverColumn === columnKey,
                    'sticky-column': columnKey === 'actions'
                  }"
                  class="draggable-header"
                >
                  <div class="header-content">
                    <span class="drag-handle">⋮⋮</span>
                    <span class="header-text">{{ getColumnLabel(columnKey) }}</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in filteredOrders" :key="order.id">
                <td
                  v-for="columnKey in columnOrder"
                  :key="columnKey"
                  v-show="getColumnVisibility(columnKey)"
                  :class="{
                    'sticky-column': columnKey === 'actions'
                  }"
                >
                  <!-- Order ID -->
                  <span v-if="columnKey === 'orderId'">#{{ order.id }}</span>
                  
                  <!-- Customer -->
                  <div v-else-if="columnKey === 'customer'" class="customer-info">
                    <strong>{{ order.customer_name }}</strong>
                    <br>
                    <small>{{ order.customer_email }}</small>
                  </div>
                  
                  <!-- Product -->
                  <div v-else-if="columnKey === 'product'" class="product-info">
                    <div v-if="order.items && order.items.length > 0" class="multi-products">
                      <div v-for="(item, index) in order.items" :key="index" class="product-item-display">
                        <span class="product-name">{{ item.product_name }}</span>
                        <span class="product-quantity">({{ item.quantity }})</span>
                      </div>
                    </div>
                    <span v-else-if="order.product_name" class="single-product">
                      {{ order.product_name }}
                    </span>
                    <span v-else class="no-data">-</span>
                  </div>
                  
                  <!-- Quantity -->
                  <span v-else-if="columnKey === 'quantity'">
                    <span v-if="order.items && order.items.length > 0">
                      {{ getTotalQuantityForOrder(order) }}
                    </span>
                    <span v-else>{{ order.quantity || 0 }}</span>
                  </span>
                  
                  <!-- Total -->
                  <span v-else-if="columnKey === 'total'">${{ order.total_amount.toFixed(2) }}</span>
                  
                  <!-- Status -->
                  <span 
                    v-else-if="columnKey === 'status'"
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
                  
                  <!-- Channel -->
                  <span v-else-if="columnKey === 'channel'">
                    <span v-if="order.channel" class="channel-badge">
                      {{ order.channel }}
                    </span>
                    <span v-else class="no-data">-</span>
                  </span>
                  
                  <!-- Location -->
                  <span v-else-if="columnKey === 'location'">
                    <span v-if="order.location" class="location-badge">
                      {{ order.location }}
                    </span>
                    <span v-else class="no-data">-</span>
                  </span>
                  
                  <!-- Order Date -->
                  <span v-else-if="columnKey === 'orderDate'">
                    {{ order.order_date ? formatDate(order.order_date) : formatDate(order.created_at) }}
                  </span>
                  
                  <!-- Actions -->
                  <div v-else-if="columnKey === 'actions'" class="action-buttons">
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
              <label for="customerEmail">Customer Info *</label>
              <input
                id="customerEmail"
                v-model="orderForm.customer_email"
                type="text"
                placeholder="Enter customer information"
                required
              />
            </div>
          </div>
          
          <!-- Products Section -->
          <div class="form-section">
            <div class="form-section-header">
              <h3>Products *</h3>
              <button type="button" class="btn btn-sm btn-primary" @click="addProductItem">
                + Add Product
              </button>
            </div>
            
            <div v-if="orderForm.items.length === 0" class="empty-products">
              <p>No products added yet. Click "Add Product" to get started.</p>
            </div>
            
            <div v-else class="product-items">
              <div 
                v-for="(item, index) in orderForm.items" 
                :key="index" 
                class="product-item"
              >
                <div class="product-item-header">
                  <h4>Product {{ index + 1 }}</h4>
                  <button 
                    type="button" 
                    class="btn btn-sm btn-danger" 
                    @click="removeProductItem(index)"
                    :disabled="orderForm.items.length === 1"
                  >
                    Remove
                  </button>
                </div>
                
                <div class="form-row">
                  <div class="form-group">
                    <label :for="`productSelect_${index}`">Product *</label>
                    <div class="product-select-container">
                      <select
                        :id="`productSelect_${index}`"
                        v-model="item.product_id"
                        @change="onProductSelect(index)"
                        required
                        class="product-select"
                      >
                        <option value="">Select a product</option>
                        <option 
                          v-for="product in products" 
                          :key="product.id" 
                          :value="product.id"
                          :disabled="isProductAlreadySelected(product.id, index)"
                        >
                          {{ product.name }} - ${{ product.price.toFixed(2) }} (Stock: {{ product.stock_quantity }})
                        </option>
                      </select>
                      <button 
                        type="button" 
                        class="btn btn-sm btn-outline refresh-product-btn"
                        @click="onProductSelect(index)"
                        title="Refresh product details"
                      >
                        🔄
                      </button>
                    </div>
                    <div v-if="item.product_id && !item.product_name" class="form-help error">
                      ⚠️ Product name not set. Click the refresh button or reselect the product.
                    </div>
                  </div>
                  
                  <div class="form-group">
                    <label :for="`quantity_${index}`">Quantity *</label>
                    <input
                      :id="`quantity_${index}`"
                      v-model.number="item.quantity"
                      type="number"
                      min="1"
                      placeholder="1"
                      @input="updateItemTotal(index)"
                      required
                    />
                  </div>
                </div>
                
                <div class="form-row">
                  <div class="form-group">
                    <label :for="`unitPrice_${index}`">Unit Price *</label>
                    <input
                      :id="`unitPrice_${index}`"
                      v-model.number="item.unit_price"
                      type="number"
                      step="0.01"
                      min="0"
                      placeholder="0.00"
                      @input="updateItemTotal(index)"
                      required
                    />
                  </div>
                  
                  <div class="form-group">
                    <label :for="`totalPrice_${index}`">Total Price</label>
                    <input
                      :id="`totalPrice_${index}`"
                      v-model.number="item.total_price"
                      type="number"
                      step="0.01"
                      readonly
                      class="readonly-input"
                    />
                  </div>
                </div>
              </div>
            </div>
            
            <div v-if="orderForm.items.length > 0" class="order-summary">
              <div class="summary-row">
                <span class="summary-label">Total Items:</span>
                <span class="summary-value">{{ orderForm.items.length }}</span>
              </div>
              <div class="summary-row">
                <span class="summary-label">Total Quantity:</span>
                <span class="summary-value">{{ getTotalQuantity() }}</span>
              </div>
              <div class="summary-row total-row">
                <span class="summary-label">Order Total:</span>
                <span class="summary-value">${{ getOrderTotal().toFixed(2) }}</span>
              </div>
            </div>
          </div>
          
          <div class="form-row">
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
            
            <div class="form-group">
              <!-- Empty div for layout balance -->
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="channel">Channel</label>
              <select
                id="channel"
                v-model="orderForm.channel"
              >
                <option value="">Select channel</option>
                <option 
                  v-for="channel in socialChannels" 
                  :key="channel.name" 
                  :value="channel.name"
                >
                  {{ channel.icon }} {{ channel.name }}
                </option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="location">Location</label>
              <select
                id="location"
                v-model="orderForm.location"
              >
                <option value="">Select location</option>
                <option 
                  v-for="province in cambodiaProvinces" 
                  :key="province.name" 
                  :value="province.name"
                >
                  {{ province.name }} ({{ province.type }})
                </option>
              </select>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="orderDate">Order Date</label>
              <input
                id="orderDate"
                v-model="orderForm.order_date"
                type="date"
                :max="getCurrentDate()"
                placeholder="Select order date"
              />
            </div>
            
            <div class="form-group">
              <!-- Empty div for layout balance -->
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
  product_name?: string // Keep for backward compatibility
  quantity?: number // Keep for backward compatibility
  unit_price?: number // Keep for backward compatibility
  total_amount: number
  status: string
  channel?: string
  location?: string
  order_date?: string
  notes?: string
  created_at: string
  items?: OrderItem[] // New: array of order items
}

interface OrderItem {
  id: number
  order_id: number
  product_id: number
  product_name: string
  quantity: number
  unit_price: number
  total_price: number
}

// Hardcoded data interfaces
interface Province {
  name: string
  type: 'Province' | 'City'
  description: string
}

interface Channel {
  name: string
  type: string
  description: string
  icon: string
}


// Reactive data
const orders = ref<Order[]>([])
const products = ref<Array<{id: number, name: string, price: number, stock_quantity: number}>>([])
const loading = ref(true)
const error = ref<string | null>(null)
const saving = ref(false)
const deleting = ref(false)

// Modal states
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const orderToEdit = ref<Order | null>(null)
const orderToDelete = ref<Order | null>(null)

// Table width state
const isTableExpanded = ref(false)

// Column visibility states
const showColumnMenu = ref(false)
const visibleColumns = ref({
  orderId: true,
  customer: true,
  product: true,
  quantity: true,
  total: true,
  status: true,
  channel: false, // Hidden by default
  location: false, // Hidden by default
  orderDate: true,
  actions: true
})

// Column order state
const columnOrder = ref([
  'orderId',
  'customer', 
  'product',
  'quantity',
  'total',
  'status',
  'channel',
  'location',
  'orderDate',
  'actions'
])

// Filter states
const showFilters = ref(false)
const filtersApplied = ref(false) // Track if filters are currently applied
const filters = ref({
  dateFrom: '',
  dateTo: '',
  status: '',
  channel: '',
  location: '',
  customerName: '',
  productName: '',
  minAmount: '',
  maxAmount: ''
})


// Drag and drop states
const draggedColumn = ref<string | null>(null)
const dragOverColumn = ref<string | null>(null)

// Default column visibility (for reset function)
const defaultColumnVisibility = {
  orderId: true,
  customer: true,
  product: true,
  quantity: true,
  total: true,
  status: true,
  channel: false,
  location: false,
  orderDate: true,
  actions: true
}

// Available columns configuration
const availableColumns = [
  { key: 'orderId', label: 'Order ID' },
  { key: 'customer', label: 'Customer' },
  { key: 'product', label: 'Product' },
  { key: 'quantity', label: 'Quantity' },
  { key: 'total', label: 'Total' },
  { key: 'status', label: 'Status' },
  { key: 'channel', label: 'Channel' },
  { key: 'location', label: 'Location' },
  { key: 'orderDate', label: 'Order Date' },
  { key: 'actions', label: 'Actions' }
]

// Form data
const orderForm = reactive({
  customer_name: '',
  customer_email: '',
  status: '',
  channel: '',
  location: '',
  order_date: '',
  notes: '',
  items: [] as Array<{
    id?: number
    product_id: string
    product_name: string
    quantity: number
    unit_price: number
    total_price: number
  }>
})

// Hardcoded data for filter dropdowns
const socialChannels = ref([
  { name: "Facebook", type: "Social Network", description: "World's largest social networking platform", icon: "📘" },
  { name: "Instagram", type: "Photo Sharing", description: "Visual content sharing and social networking", icon: "📷" },
  { name: "Telegram", type: "Messaging", description: "Secure messaging and communication platform", icon: "✈️" },
  { name: "TikTok", type: "Video Platform", description: "Short-form video content and entertainment", icon: "🎵" }
])

const cambodiaProvinces = ref([
  { name: "Phnom Penh", type: "City", description: "Capital city and largest urban center" },
  { name: "Battambang", type: "Province", description: "Northwestern province known for agriculture" },
  { name: "Siem Reap", type: "Province", description: "Home to the famous Angkor temples" },
  { name: "Kampong Cham", type: "Province", description: "Eastern province along the Mekong River" },
  { name: "Kampong Thom", type: "Province", description: "Central province with historical significance" },
  { name: "Kampong Chhnang", type: "Province", description: "Central province known for pottery" },
  { name: "Kampong Speu", type: "Province", description: "Southwestern province with agricultural focus" },
  { name: "Kandal", type: "Province", description: "Province surrounding Phnom Penh" },
  { name: "Koh Kong", type: "Province", description: "Southwestern coastal province" },
  { name: "Kratie", type: "Province", description: "Northeastern province along the Mekong" },
  { name: "Mondulkiri", type: "Province", description: "Eastern highland province" },
  { name: "Oddar Meanchey", type: "Province", description: "Northern border province" },
  { name: "Pailin", type: "Province", description: "Western province with gem mining history" },
  { name: "Preah Vihear", type: "Province", description: "Northern province with ancient temples" },
  { name: "Prey Veng", type: "Province", description: "Southeastern agricultural province" },
  { name: "Pursat", type: "Province", description: "Central province with Cardamom Mountains" },
  { name: "Ratanakiri", type: "Province", description: "Northeastern highland province" },
  { name: "Sihanoukville", type: "Province", description: "Coastal province with beaches and ports" },
  { name: "Stung Treng", type: "Province", description: "Northern province along the Mekong" },
  { name: "Svay Rieng", type: "Province", description: "Southeastern border province" },
  { name: "Takeo", type: "Province", description: "Southern province with historical sites" },
  { name: "Kampot", type: "Province", description: "Southern province known for pepper" },
  { name: "Kep", type: "Province", description: "Small coastal province" },
  { name: "Tboung Khmum", type: "Province", description: "Eastern province split from Kampong Cham" },
  { name: "Preah Sihanouk", type: "Province", description: "Coastal province with major port" }
])

// Fetch products from Supabase
const fetchProducts = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('products')
    
    if (fetchError) {
      console.error('Error fetching products:', fetchError)
      return
    }
    
    products.value = (data as unknown as Array<{id: number, name: string, price: number, stock_quantity: number}>) || []
  } catch (err) {
    console.error('Error fetching products:', err)
  }
}

// Fetch orders from Supabase with order items
const fetchOrders = async () => {
  try {
    loading.value = true
    error.value = null
    
    const { select } = useSupabaseDB()
    
    // First, try to fetch orders with order items using the view
    try {
      const { data: orderDetails, error: viewError } = await select('order_details')
      
      if (!viewError && orderDetails) {
        // Group order details by order_id
        const ordersMap = new Map()
        
        orderDetails.forEach((detail: any) => {
          if (!ordersMap.has(detail.order_id)) {
            ordersMap.set(detail.order_id, {
              id: detail.order_id,
              customer_name: detail.customer_name,
              customer_email: detail.customer_email,
              status: detail.status,
              channel: detail.channel,
              location: detail.location,
              order_date: detail.order_date,
              notes: detail.notes,
              created_at: detail.created_at,
              total_amount: 0,
              items: []
            })
          }
          
          const order = ordersMap.get(detail.order_id)
          
          // Add item if it exists
          if (detail.item_id) {
            order.items.push({
              id: detail.item_id,
              order_id: detail.order_id,
              product_id: detail.product_id,
              product_name: detail.product_name,
              quantity: detail.quantity,
              unit_price: detail.unit_price,
              total_price: detail.total_price
            })
            order.total_amount += detail.total_price
          }
        })
        
        orders.value = Array.from(ordersMap.values())
        return
      }
    } catch (viewErr) {
      console.log('Order details view not available, falling back to basic orders query')
    }
    
    // Fallback: fetch basic orders (for backward compatibility)
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

// Handle product selection for multi-product orders
const onProductSelect = (index: number) => {
  const item = orderForm.items[index]
  if (!item) return
  
  console.log('Product selection for item:', index, 'product_id:', item.product_id) // Debug log
  console.log('Available products:', products.value) // Debug log
  
  // Try different comparison methods to find the product
  let selectedProduct = products.value.find((p: {id: number, name: string, price: number, stock_quantity: number}) => 
    p.id.toString() === item.product_id.toString()
  )
  
  // If not found, try with number comparison
  if (!selectedProduct) {
    selectedProduct = products.value.find((p: {id: number, name: string, price: number, stock_quantity: number}) => 
      p.id === parseInt(item.product_id)
    )
  }
  
  // If still not found, try with string comparison (convert id to string)
  if (!selectedProduct) {
    selectedProduct = products.value.find((p: {id: number, name: string, price: number, stock_quantity: number}) => 
      p.id.toString() === item.product_id.toString()
    )
  }
  
  console.log('Found selected product:', selectedProduct) // Debug log
  
  if (selectedProduct) {
    item.product_name = selectedProduct.name
    item.unit_price = selectedProduct.price
    updateItemTotal(index)
    console.log('Updated item:', item) // Debug log
  } else {
    // Reset if no product selected
    item.product_name = ''
    item.unit_price = 0
    item.total_price = 0
    console.log('No product found, reset item') // Debug log
  }
}

// Add a new product item to the order
const addProductItem = () => {
  orderForm.items.push({
    product_id: '',
    product_name: '',
    quantity: 1,
    unit_price: 0,
    total_price: 0
  })
}

// Remove a product item from the order
const removeProductItem = (index: number) => {
  if (orderForm.items.length > 1) {
    orderForm.items.splice(index, 1)
  }
}

// Check if a product is already selected in another item
const isProductAlreadySelected = (productId: number, currentIndex: number) => {
  return orderForm.items.some((item: any, index: number) => 
    index !== currentIndex && item.product_id === productId.toString()
  )
}

// Update the total price for a specific item
const updateItemTotal = (index: number) => {
  const item = orderForm.items[index]
  if (item) {
    item.total_price = item.quantity * item.unit_price
  }
}

// Get total quantity across all items
const getTotalQuantity = () => {
  return orderForm.items.reduce((total: number, item: any) => total + item.quantity, 0)
}

// Get total order amount
const getOrderTotal = () => {
  return orderForm.items.reduce((total: number, item: any) => total + item.total_price, 0)
}

// Get total quantity for an order (for display in table)
const getTotalQuantityForOrder = (order: Order) => {
  if (order.items && order.items.length > 0) {
    return order.items.reduce((total, item) => total + item.quantity, 0)
  }
  return order.quantity || 0
}

// Watch for changes in product_id to auto-update product_name
watch(() => orderForm.items, (newItems: any) => {
  if (newItems) {
    newItems.forEach((item: any, index: number) => {
      if (item.product_id && !item.product_name) {
        // Auto-update product name if product_id is set but product_name is missing
        onProductSelect(index)
      }
    })
  }
}, { deep: true })


// Open add modal
const openAddModal = () => {
  isEditing.value = false
  Object.assign(orderForm, {
    customer_name: '',
    customer_email: '',
    status: '',
    channel: '',
    location: '',
    order_date: getCurrentDate(), // Set default to today
    notes: '',
    items: [{
      product_id: '',
      product_name: '',
      quantity: 1,
      unit_price: 0,
      total_price: 0
    }]
  })
  showModal.value = true
  
  // Ensure products are loaded
  if (products.value.length === 0) {
    fetchProducts()
  }
}

// Open edit modal
const openEditModal = (order: Order) => {
  isEditing.value = true
  orderToEdit.value = order // Store the order being edited
  
  // Handle both new multi-product structure and legacy single-product structure
  let items = []
  
  if (order.items && order.items.length > 0) {
    // New multi-product structure
    items = order.items.map(item => ({
      id: item.id,
      product_id: item.product_id.toString(),
      product_name: item.product_name,
      quantity: item.quantity,
      unit_price: item.unit_price,
      total_price: item.total_price
    }))
  } else if (order.product_name) {
    // Legacy single-product structure - convert to new format
    const product = products.value.find((p: {id: number, name: string, price: number, stock_quantity: number}) => p.name === order.product_name)
    items = [{
      product_id: product?.id.toString() || '',
      product_name: order.product_name,
      quantity: order.quantity || 1,
      unit_price: order.unit_price || 0,
      total_price: (order.quantity || 1) * (order.unit_price || 0)
    }]
  } else {
    // Default empty item
    items = [{
      product_id: '',
      product_name: '',
      quantity: 1,
      unit_price: 0,
      total_price: 0
    }]
  }
  
  Object.assign(orderForm, {
    customer_name: order.customer_name,
    customer_email: order.customer_email,
    status: order.status,
    channel: order.channel || '',
    location: order.location || '',
    order_date: order.order_date || '',
    notes: order.notes || '',
    items: items
  })
  showModal.value = true
}

// Close modal
const closeModal = () => {
  showModal.value = false
  Object.assign(orderForm, {
    customer_name: '',
    customer_email: '',
    status: '',
    channel: '',
    location: '',
    order_date: '',
    notes: '',
    items: []
  })
  isEditing.value = false
  orderToEdit.value = null // Clear the order being edited
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

// Column toggle functions
const toggleColumnMenu = () => {
  showColumnMenu.value = !showColumnMenu.value
}

const getColumnVisibility = (columnKey: string) => {
  return visibleColumns.value[columnKey as keyof typeof visibleColumns.value]
}

const toggleColumn = (columnKey: string) => {
  const key = columnKey as keyof typeof visibleColumns.value
  visibleColumns.value[key] = !visibleColumns.value[key]
  saveColumnPreferences()
}

const showAllColumns = () => {
  Object.keys(visibleColumns.value).forEach(key => {
    (visibleColumns.value as any)[key] = true
  })
  saveColumnPreferences()
}

const hideAllColumns = () => {
  Object.keys(visibleColumns.value).forEach(key => {
    (visibleColumns.value as any)[key] = false
  })
  saveColumnPreferences()
}

const resetColumns = () => {
  visibleColumns.value = { ...defaultColumnVisibility }
  saveColumnPreferences()
}

// Save column preferences to localStorage
const saveColumnPreferences = () => {
  localStorage.setItem('orderColumns', JSON.stringify(visibleColumns.value))
}

// Load column preferences from localStorage
const loadColumnPreferences = () => {
  const saved = localStorage.getItem('orderColumns')
  if (saved) {
    try {
      const parsed = JSON.parse(saved)
      visibleColumns.value = { ...defaultColumnVisibility, ...parsed }
    } catch (e) {
      console.warn('Failed to load column preferences:', e)
      visibleColumns.value = { ...defaultColumnVisibility }
    }
  } else {
    // First time user - use default visibility
    visibleColumns.value = { ...defaultColumnVisibility }
  }
}

// Load column order from localStorage
const loadColumnOrder = () => {
  const saved = localStorage.getItem('orderColumnOrder')
  if (saved) {
    try {
      const parsed = JSON.parse(saved)
      columnOrder.value = parsed
    } catch (e) {
      console.warn('Failed to load column order:', e)
    }
  }
}

// Save column order to localStorage
const saveColumnOrder = () => {
  localStorage.setItem('orderColumnOrder', JSON.stringify(columnOrder.value))
}

// Drag and drop functions
const handleDragStart = (event: DragEvent, columnKey: string) => {
  draggedColumn.value = columnKey
  if (event.dataTransfer) {
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', columnKey)
  }
}

const handleDragOver = (event: DragEvent, columnKey: string) => {
  event.preventDefault()
  if (event.dataTransfer) {
    event.dataTransfer.dropEffect = 'move'
  }
  dragOverColumn.value = columnKey
}

const handleDragLeave = () => {
  dragOverColumn.value = null
}

const handleDrop = (event: DragEvent, targetColumnKey: string) => {
  event.preventDefault()
  
  if (!draggedColumn.value || draggedColumn.value === targetColumnKey) {
    dragOverColumn.value = null
    draggedColumn.value = null
    return
  }

  // Reorder columns
  const draggedIndex = columnOrder.value.indexOf(draggedColumn.value)
  const targetIndex = columnOrder.value.indexOf(targetColumnKey)
  
  if (draggedIndex !== -1 && targetIndex !== -1) {
    // Remove dragged column from its current position
    const draggedItem = columnOrder.value.splice(draggedIndex, 1)[0]
    
    if (draggedItem) {
      // Insert at new position
      if (draggedIndex < targetIndex) {
        columnOrder.value.splice(targetIndex - 1, 0, draggedItem)
      } else {
        columnOrder.value.splice(targetIndex, 0, draggedItem)
      }
      
      saveColumnOrder()
    }
  }
  
  dragOverColumn.value = null
  draggedColumn.value = null
}

const handleDragEnd = () => {
  dragOverColumn.value = null
  draggedColumn.value = null
}

// Get column label for display
const getColumnLabel = (columnKey: string) => {
  const column = availableColumns.find(col => col.key === columnKey)
  return column ? column.label : columnKey
}

// Get current date in YYYY-MM-DD format
const getCurrentDate = () => {
  const today = new Date()
  return today.toISOString().split('T')[0]
}

// Save order (add or update) - Multi-product version
const saveOrder = async () => {
  try {
    saving.value = true
    
    // Validate form
    if (!orderForm.customer_name || !orderForm.customer_email || !orderForm.status) {
      alert('Please fill in all required fields')
      return
    }
    
    // Validate that we have at least one product
    if (!orderForm.items || orderForm.items.length === 0) {
      alert('Please add at least one product to the order')
      return
    }
    
    // Validate each product item
    for (let i = 0; i < orderForm.items.length; i++) {
      const item = orderForm.items[i]
      console.log(`Validating Product ${i + 1}:`, item) // Debug log
      
      // Check if product is selected
      if (!item.product_id || item.product_id === '') {
        alert(`Please select a product for Product ${i + 1}`)
        return
      }
      
      // Check if product name is set (this should be auto-set when product is selected)
      if (!item.product_name || item.product_name === '') {
        alert(`Product name is missing for Product ${i + 1}. Please select the product again.`)
        return
      }
      
      // Check quantity
      if (!item.quantity || item.quantity <= 0) {
        alert(`Please enter a valid quantity for Product ${i + 1}`)
        return
      }
      
      // Check unit price
      if (item.unit_price === undefined || item.unit_price === null || item.unit_price < 0) {
        alert(`Please enter a valid unit price for Product ${i + 1}`)
        return
      }
    }
    
    // Check if products are loaded
    if (!products.value || products.value.length === 0) {
      console.log('No products available, fetching products...')
      await fetchProducts()
    }
    
    // Calculate total amount
    const totalAmount = getOrderTotal()
    
    // Prepare order data
    const orderData: any = {
      customer_name: orderForm.customer_name.trim(),
      customer_email: orderForm.customer_email.trim(),
      total_amount: totalAmount,
      status: orderForm.status,
      notes: orderForm.notes.trim() || null
    }
    
    // Add optional fields only if they have values
    if (orderForm.channel && orderForm.channel.trim()) {
      orderData.channel = orderForm.channel.trim()
    }
    
    if (orderForm.location && orderForm.location.trim()) {
      orderData.location = orderForm.location.trim()
    }
    
    if (orderForm.order_date && orderForm.order_date.trim()) {
      orderData.order_date = orderForm.order_date.trim()
    }
    
    console.log('Saving order with data:', orderData)
    console.log('Order items:', orderForm.items)
    
    if (isEditing.value) {
      // Update existing order
      if (!orderToEdit.value?.id) {
        throw new Error('Order ID is missing. Cannot update order.')
      }
      
      console.log('Updating order with ID:', orderToEdit.value.id)
      
      const { update, delete: deleteRecord } = useSupabaseDB()
      
      // Update the main order record
      const { error: orderError } = await update('orders', orderData).eq('id', orderToEdit.value.id)
      if (orderError) throw orderError
      
      // Delete existing order items
      const { error: deleteError } = await deleteRecord('order_items').eq('order_id', orderToEdit.value.id)
      if (deleteError) throw deleteError
      
      // Insert new order items
      const orderItemsData = orderForm.items.map((item: any) => ({
        order_id: orderToEdit.value.id,
        product_id: parseInt(item.product_id),
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.total_price
      }))
      
      const { insert } = useSupabaseDB()
      const { error: itemsError } = await insert('order_items', orderItemsData)
      if (itemsError) throw itemsError
      
    } else {
      // Add new order
      const { insert } = useSupabaseDB()

      // Insert the main order record with .select() to get the returned data
      const { data: orderResult, error: orderError } = await insert('orders', [orderData]).select()
      if (orderError) throw orderError

      // Get the new order ID
      const newOrderId = orderResult?.[0]?.id
      if (!newOrderId) {
        console.error('Order result:', orderResult)
        throw new Error('Failed to get new order ID')
      }

      console.log('New order created with ID:', newOrderId)

      // Insert order items
      const orderItemsData = orderForm.items.map((item: any) => ({
        order_id: newOrderId,
        product_id: parseInt(item.product_id),
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.total_price
      }))

      console.log('Inserting order items:', orderItemsData)

      const { error: itemsError } = await insert('order_items', orderItemsData)
      if (itemsError) throw itemsError
    }
    
    closeModal()
    await fetchOrders()
    
  } catch (err) {
    console.error('Error saving order:', err)
    
    // More detailed error message
    let errorMessage = 'Failed to save order. Please try again.'
    
    if (err && typeof err === 'object' && 'message' in err) {
      const errorMsg = (err as any).message
      console.error('Detailed error:', errorMsg)
      
      if (errorMsg.includes('column') && errorMsg.includes('does not exist')) {
        errorMessage = 'Database schema error: Missing column. Please run the multi-product migration first.'
      } else if (errorMsg.includes('permission')) {
        errorMessage = 'Permission denied. Please check your database permissions.'
      } else if (errorMsg.includes('connection')) {
        errorMessage = 'Connection error. Please check your internet connection.'
      } else {
        errorMessage = `Error: ${errorMsg}`
      }
    }
    
    alert(errorMessage)
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

// Format date (date only, no time)
const formatDate = (dateString: string) => {
  if (!dateString) return '-'
  
  const date = new Date(dateString)
  
  // Check if date is valid
  if (isNaN(date.getTime())) {
    return 'Invalid Date'
  }
  
  // Get user's local timezone
  const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
  
  // Format date using local timezone (date only, no time)
  const dateStr = date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    timeZone: timeZone
  })
  
  return dateStr
}

// Test database connection
const testDatabaseConnection = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error } = await select('orders').limit(1)
    
    if (error) {
      console.error('Database connection test failed:', error)
      return false
    }
    
    console.log('Database connection test passed')
    return true
  } catch (err) {
    console.error('Database connection test error:', err)
    return false
  }
}

// Filter functions
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const toggleTableWidth = () => {
  isTableExpanded.value = !isTableExpanded.value
  saveTableWidthPreference()
}

// Save table width preference to localStorage
const saveTableWidthPreference = () => {
  localStorage.setItem('orderTableExpanded', JSON.stringify(isTableExpanded.value))
}

// Load table width preference from localStorage
const loadTableWidthPreference = () => {
  const saved = localStorage.getItem('orderTableExpanded')
  if (saved !== null) {
    try {
      isTableExpanded.value = JSON.parse(saved)
    } catch (e) {
      console.warn('Failed to load table width preference:', e)
      isTableExpanded.value = false
    }
  }
}

const clearFilters = () => {
  filters.value = {
    dateFrom: '',
    dateTo: '',
    status: '',
    channel: '',
    location: '',
    customerName: '',
    productName: '',
    minAmount: '',
    maxAmount: ''
  }
  filtersApplied.value = false // Clear applied state
}

const applyFilters = () => {
  // Apply the current filter settings
  filtersApplied.value = true
  console.log('Filters applied:', filters.value)
}

// Computed properties for filtering
const totalOrders = computed(() => orders.value.length)
const totalAmount = computed(() => 
  orders.value.reduce((sum: number, order: Order) => sum + order.total_amount, 0)
)

// Filtered orders based on current filters (only when filters are applied)
const filteredOrders = computed(() => {
  // If filters are not applied, show all orders
  if (!filtersApplied.value) {
    return orders.value
  }
  
  let filtered = [...orders.value]
  
  // Date range filter
  if (filters.value.dateFrom) {
    const fromDate = new Date(filters.value.dateFrom)
    filtered = filtered.filter(order => {
      const orderDate = new Date(order.order_date || order.created_at)
      return orderDate >= fromDate
    })
  }
  
  if (filters.value.dateTo) {
    const toDate = new Date(filters.value.dateTo)
    toDate.setHours(23, 59, 59, 999) // Include the entire day
    filtered = filtered.filter(order => {
      const orderDate = new Date(order.order_date || order.created_at)
      return orderDate <= toDate
    })
  }
  
  // Status filter - COMMENTED OUT
  // if (filters.value.status) {
  //   filtered = filtered.filter(order => order.status === filters.value.status)
  // }
  
  // Channel filter - COMMENTED OUT
  // if (filters.value.channel) {
  //   filtered = filtered.filter(order => order.channel === filters.value.channel)
  // }
  
  // Location filter - COMMENTED OUT
  // if (filters.value.location) {
  //   filtered = filtered.filter(order => order.location === filters.value.location)
  // }
  
  // Customer name filter - COMMENTED OUT
  // if (filters.value.customerName) {
  //   const searchTerm = filters.value.customerName.toLowerCase()
  //   filtered = filtered.filter(order => 
  //     order.customer_name.toLowerCase().includes(searchTerm)
  //   )
  // }
  
  // Product name filter - COMMENTED OUT
  // if (filters.value.productName) {
  //   const searchTerm = filters.value.productName.toLowerCase()
  //   filtered = filtered.filter(order => 
  //     order.product_name.toLowerCase().includes(searchTerm)
  //   )
  // }
  
  // Amount range filter - COMMENTED OUT
  // if (filters.value.minAmount) {
  //   const minAmount = parseFloat(filters.value.minAmount)
  //   if (!isNaN(minAmount)) {
  //     filtered = filtered.filter(order => order.total_amount >= minAmount)
  //   }
  // }
  
  // if (filters.value.maxAmount) {
  //   const maxAmount = parseFloat(filters.value.maxAmount)
  //   if (!isNaN(maxAmount)) {
  //     filtered = filtered.filter(order => order.total_amount <= maxAmount)
  //   }
  // }
  
  return filtered
})

// Debug function to check form state
const debugFormState = () => {
  console.log('=== FORM DEBUG INFO ===')
  console.log('Order Form:', orderForm)
  console.log('Products:', products.value)
  console.log('Form Items:', orderForm.items)
  
  if (orderForm.items && orderForm.items.length > 0) {
    orderForm.items.forEach((item, index) => {
      console.log(`Item ${index + 1}:`, {
        product_id: item.product_id,
        product_name: item.product_name,
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.total_price
      })
    })
  }
  console.log('========================')
}

// Make debug function available globally for testing
if (typeof window !== 'undefined') {
  (window as any).debugFormState = debugFormState
}

// Fetch data on component mount
onMounted(async () => {
  loadColumnPreferences() // Load saved column preferences
  loadColumnOrder() // Load saved column order
  loadTableWidthPreference() // Load saved table width preference

  // Test database connection first
  const connectionOk = await testDatabaseConnection()
  if (!connectionOk) {
    error.value = 'Database connection failed. Please check your Supabase configuration.'
    return
  }

  await Promise.all([
    fetchOrders(),
    fetchProducts()
  ])
})
</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  transition: max-width 0.3s ease;
}

.page-container.expanded {
  max-width: 100%;
  padding: 2rem 1rem;
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

.action-left {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.action-right {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.action-bar .btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Filter Panel Styles */
.filter-panel {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.filter-header h3 {
  margin: 0;
  color: #374151;
  font-size: 1.1rem;
  font-weight: 600;
}

.filter-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
  max-width: 600px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  margin-bottom: 0.5rem;
}

.filter-group label {
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.date-range,
.amount-range {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.date-range input,
.amount-range input {
  flex: 1;
  min-width: 120px;
}

.form-input,
.form-select {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  transition: border-color 0.2s;
  width: 100%;
  box-sizing: border-box;
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.filter-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.filter-stats {
  color: #6b7280;
  font-size: 0.9rem;
}

.filter-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
}

/* Column Menu Styles */
.column-menu {
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  margin-bottom: 2rem;
  overflow: hidden;
}

.column-menu-header {
  background: #f8f9fa;
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.column-menu-header h3 {
  margin: 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.menu-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #6c757d;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.menu-close:hover {
  color: #495057;
}

.column-options {
  padding: 1rem;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.75rem;
}

.column-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 4px;
  transition: background-color 0.2s ease;
}

.column-option:hover {
  background: #f8f9fa;
}

.column-option input[type="checkbox"] {
  margin: 0;
  cursor: pointer;
}

.column-label {
  font-size: 0.9rem;
  color: #495057;
  user-select: none;
}

.column-menu-actions {
  padding: 1rem;
  border-top: 1px solid #dee2e6;
  background: #f8f9fa;
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.btn-outline {
  background: transparent;
  border: 1px solid #dee2e6;
  color: #6c757d;
}

.btn-outline:hover {
  background: #f8f9fa;
  border-color: #adb5bd;
  color: #495057;
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
  overflow-x: auto;
  overflow-y: hidden;
  position: relative;
}

/* Scroll indicator */
.table-container::-webkit-scrollbar {
  height: 8px;
}

.table-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.table-container::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

.table-container::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

.orders-table {
  width: 100%;
  min-width: 1000px; /* Ensure minimum width for all columns */
  border-collapse: collapse;
}

.orders-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
  white-space: nowrap; /* Prevent text wrapping in headers */
  position: relative;
  user-select: none;
}

/* Draggable header styles */
.draggable-header {
  cursor: move;
  transition: all 0.2s ease;
}

.draggable-header:hover {
  background: #e9ecef;
}

.draggable-header.dragging {
  opacity: 0.5;
  background: #dee2e6;
}

.draggable-header.drag-over {
  background: #007bff;
  color: white;
  border-left: 3px solid #0056b3;
  border-right: 3px solid #0056b3;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.drag-handle {
  color: #6c757d;
  font-size: 0.8rem;
  cursor: grab;
  user-select: none;
  opacity: 0.6;
  transition: opacity 0.2s ease;
}

.draggable-header:hover .drag-handle {
  opacity: 1;
}

.draggable-header.dragging .drag-handle {
  cursor: grabbing;
}

.header-text {
  flex: 1;
}

/* Specific column widths for better layout */
.orders-table th:nth-child(1), .orders-table td:nth-child(1) { width: 80px; } /* Order ID */
.orders-table th:nth-child(2), .orders-table td:nth-child(2) { width: 150px; } /* Customer */
.orders-table th:nth-child(3), .orders-table td:nth-child(3) { width: 120px; } /* Product */
.orders-table th:nth-child(4), .orders-table td:nth-child(4) { width: 80px; } /* Quantity */
.orders-table th:nth-child(5), .orders-table td:nth-child(5) { width: 100px; } /* Total */
.orders-table th:nth-child(6), .orders-table td:nth-child(6) { width: 100px; } /* Status */
.orders-table th:nth-child(7), .orders-table td:nth-child(7) { width: 100px; } /* Channel */
.orders-table th:nth-child(8), .orders-table td:nth-child(8) { width: 120px; } /* Location */
.orders-table th:nth-child(9), .orders-table td:nth-child(9) { width: 120px; } /* Order Date */
.orders-table th:nth-child(10), .orders-table td:nth-child(10) { width: 100px; } /* Actions */

/* Sticky column styles - works regardless of column position */
.orders-table .sticky-column {
  position: sticky;
  right: 0;
  z-index: 10;
}

/* Sticky header background */
.orders-table thead th.sticky-column {
  background: #f8f9fa;
  box-shadow: -2px 0 4px rgba(0, 0, 0, 0.1);
}

/* Sticky body cell background */
.orders-table tbody td.sticky-column {
  background: white;
  box-shadow: -2px 0 4px rgba(0, 0, 0, 0.1);
}

/* Maintain hover effect for sticky column */
.orders-table tbody tr:hover td.sticky-column {
  background: #f8f9fa;
}

.orders-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
  white-space: nowrap; /* Prevent text wrapping in cells */
  overflow: hidden;
  text-overflow: ellipsis; /* Show ... for long text */
}

.orders-table tr:hover {
  background: #f8f9fa;
}

/* Badge Styles */
.channel-badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.location-badge {
  background: #f3e5f5;
  color: #7b1fa2;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.no-data {
  color: #6c757d;
  font-style: italic;
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

/* Multi-Product Form Styles */
.form-section {
  margin-bottom: 2rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.5rem;
  background: #f9fafb;
}

.form-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.form-section-header h3 {
  margin: 0;
  color: #374151;
  font-size: 1.2rem;
  font-weight: 600;
}

.empty-products {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
  background: white;
  border-radius: 8px;
  border: 2px dashed #d1d5db;
}

.product-items {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.product-item {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.product-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #f3f4f6;
}

.product-item-header h4 {
  margin: 0;
  color: #374151;
  font-size: 1rem;
  font-weight: 600;
}

.order-summary {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.5rem;
  margin-top: 1.5rem;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid #f3f4f6;
}

.summary-row:last-child {
  border-bottom: none;
}

.summary-row.total-row {
  font-weight: 600;
  font-size: 1.1rem;
  color: #1f2937;
  border-top: 2px solid #e5e7eb;
  margin-top: 0.5rem;
  padding-top: 1rem;
}

.summary-label {
  color: #6b7280;
}

.summary-value {
  color: #1f2937;
  font-weight: 500;
}

.readonly-input {
  background-color: #f9fafb;
  color: #6b7280;
  cursor: not-allowed;
}

/* Product Select Container */
.product-select-container {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.product-select {
  flex: 1;
}

.refresh-product-btn {
  padding: 0.5rem;
  min-width: auto;
  height: 38px; /* Match select height */
  display: flex;
  align-items: center;
  justify-content: center;
}

.form-help.error {
  color: #dc3545;
  font-weight: 500;
  margin-top: 0.5rem;
  padding: 0.5rem;
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 4px;
}

/* Product Display in Table */
.product-info {
  max-width: 200px;
}

.multi-products {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.product-item-display {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.product-name {
  font-weight: 500;
  color: #374151;
}

.product-quantity {
  color: #6b7280;
  font-size: 0.8rem;
}

.single-product {
  color: #374151;
  font-weight: 500;
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
  
  .filter-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .date-range,
  .amount-range {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .date-range input,
  .amount-range input {
    min-width: unset;
  }
  
  .filter-footer {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .filter-actions {
    justify-content: center;
  }
  
  /* Mobile table adjustments */
  .table-container {
    margin: 0 -1rem; /* Extend to screen edges on mobile */
    border-radius: 0;
  }
  
  .orders-table {
    min-width: 800px; /* Reduce minimum width for mobile */
  }
  
  /* Make some columns more compact on mobile */
  .orders-table th, .orders-table td {
    padding: 0.5rem;
    font-size: 0.9rem;
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
  
  /* Multi-product responsive styles */
  .form-section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .product-item-header {
    flex-direction: column;
    gap: 0.5rem;
    align-items: stretch;
  }
  
  .product-item-header h4 {
    text-align: center;
  }
  
  .summary-row {
    flex-direction: column;
    gap: 0.25rem;
    text-align: center;
  }
  
  .product-info {
    max-width: none;
  }
  
  .multi-products {
    gap: 0.5rem;
  }
  
  .product-item-display {
    flex-direction: column;
    gap: 0.25rem;
    text-align: center;
  }
}
</style>
