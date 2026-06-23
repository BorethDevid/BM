<template>
  <div class="page-container" :class="{ 'expanded': isTableExpanded }">
    <div class="page-header">
      <h1>Expense Management</h1>
      <p>Track business expenses and goods purchased for resale</p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading expenses...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-message">
        <h3>⚠️ Connection Error</h3>
        <p>{{ error }}</p>
        <button class="btn btn-primary" @click="fetchExpenses">
          Retry
        </button>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Summary Cards -->
      <div class="summary-cards">
        <div class="summary-card">
          <div class="summary-icon">💰</div>
          <div class="summary-content">
            <h3>Total Expenses</h3>
            <p class="summary-value">${{ totalExpenses.toFixed(2) }}</p>
          </div>
        </div>
        <div class="summary-card">
          <div class="summary-icon">📊</div>
          <div class="summary-content">
            <h3>Total Records</h3>
            <p class="summary-value">{{ expenses.length }}</p>
          </div>
        </div>
        <div class="summary-card">
          <div class="summary-icon">📅</div>
          <div class="summary-content">
            <h3>This Month</h3>
            <p class="summary-value">${{ monthlyExpenses.toFixed(2) }}</p>
          </div>
        </div>
        <div class="summary-card">
          <div class="summary-icon">📈</div>
          <div class="summary-content">
            <h3>Average</h3>
            <p class="summary-value">${{ averageExpense.toFixed(2) }}</p>
          </div>
        </div>
      </div>

      <!-- Action Bar -->
      <div class="action-bar">
        <div class="action-left">
          <button class="btn btn-primary" @click="openAddModal">
            <span>+</span> Add Expense
          </button>
          <button class="btn btn-secondary" @click="fetchExpenses">
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
        </div>
      </div>

      <!-- Filter Panel -->
      <div v-if="showFilters" class="filter-panel">
        <div class="filter-header">
          <h3>🔍 Filter Expenses</h3>
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
                class="form-input"
              />
              <input
                type="date"
                v-model="filters.dateTo"
                class="form-input"
              />
            </div>
          </div>

          <!-- Category Filter -->
          <div class="filter-group">
            <label>Category</label>
            <select v-model="filters.category" class="form-select">
              <option value="">All Categories</option>
              <option v-for="cat in categories" :key="cat.name" :value="cat.name">
                {{ cat.icon }} {{ cat.name }}
              </option>
            </select>
          </div>

          <!-- Payment Status Filter -->
          <div class="filter-group">
            <label>Payment Status</label>
            <select v-model="filters.paymentStatus" class="form-select">
              <option value="">All Statuses</option>
              <option value="Paid">Paid</option>
              <option value="Pending">Pending</option>
              <option value="Partial">Partial</option>
            </select>
          </div>
        </div>

        <div class="filter-footer">
          <div class="filter-stats">
            <span>Showing {{ filteredExpenses.length }} of {{ expenses.length }} expenses</span>
          </div>
          <div class="filter-actions">
            <button class="btn btn-sm btn-outline" @click="clearFilters">Clear</button>
            <button class="btn btn-sm btn-primary" @click="applyFilters">Apply</button>
          </div>
        </div>
      </div>

      <!-- Expenses Table -->
      <div v-if="expenses.length > 0" class="expenses-section">
        <div class="table-container">
          <table class="expenses-table">
            <thead>
              <tr>
                <th
                  v-for="columnKey in columnOrder"
                  :key="columnKey"
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
                    <span
                      v-if="columnKey === 'id'"
                      class="sort-indicator"
                      title="Sort by ID"
                      @click.stop="toggleIdSort"
                    >{{ idSortOrder === 'asc' ? '▲' : '▼' }}</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="expense in filteredExpenses" :key="expense.id">
                <td
                  v-for="columnKey in columnOrder"
                  :key="columnKey"
                  :class="{ 'sticky-column': columnKey === 'actions' }"
                >
                  <template v-if="columnKey === 'id'">#{{ expense.id }}</template>
                  <template v-else-if="columnKey === 'date'">{{ formatDate(expense.expense_date) }}</template>
                  <template v-else-if="columnKey === 'category'">
                    <span class="category-badge" :style="{ background: getCategoryColor(expense.category) }">
                      {{ getCategoryIcon(expense.category) }} {{ expense.category }}
                    </span>
                  </template>
                  <span v-else-if="columnKey === 'description'" class="description-cell">{{ expense.description }}</span>
                  <template v-else-if="columnKey === 'product'">{{ expense.product_name || '-' }}</template>
                  <template v-else-if="columnKey === 'quantity'">{{ expense.quantity || '-' }}</template>
                  <template v-else-if="columnKey === 'total_cost'">${{ (expense.total_amount - (expense.delivery_cost || 0)).toFixed(2) }}</template>
                  <template v-else-if="columnKey === 'delivery'">${{ (expense.delivery_cost || 0).toFixed(2) }}</template>
                  <template v-else-if="columnKey === 'unit_cost'">${{ expense.unit_cost.toFixed(2) }}</template>
                  <span v-else-if="columnKey === 'total_amount'" class="amount-cell">${{ expense.total_amount.toFixed(2) }}</span>
                  <template v-else-if="columnKey === 'payment_status'">
                    <span
                      class="status-badge"
                      :class="{
                        'paid': expense.payment_status === 'Paid',
                        'pending': expense.payment_status === 'Pending',
                        'partial': expense.payment_status === 'Partial'
                      }"
                    >
                      {{ expense.payment_status }}
                    </span>
                  </template>
                  <template v-else-if="columnKey === 'invoice'">{{ expense.receipt_number || '-' }}</template>
                  <span v-else-if="columnKey === 'notes'" class="notes-cell" :title="expense.notes || ''">{{ expense.notes || '-' }}</span>
                  <template v-else-if="columnKey === 'actions'">
                    <div class="action-buttons">
                      <button class="btn btn-sm btn-edit" @click="openEditModal(expense)" title="Edit">
                        ✏️
                      </button>
                      <button class="btn btn-sm btn-delete" @click="confirmDelete(expense)" title="Delete">
                        🗑️
                      </button>
                    </div>
                  </template>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <h3>No Expenses Found</h3>
        <p>Start tracking your business expenses!</p>
        <button class="btn btn-primary" @click="openAddModal">
          Add First Expense
        </button>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Expense' : 'Add New Expense' }}</h2>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>

        <form @submit.prevent="saveExpense" class="expense-form">
          <div class="form-row">
            <div class="form-group">
              <label for="expenseDate">Expense Date *</label>
              <input
                id="expenseDate"
                v-model="expenseForm.expense_date"
                type="date"
                :max="getCurrentDate()"
                required
              />
            </div>

            <div class="form-group">
              <label for="category">Category *</label>
              <select
                id="category"
                v-model="expenseForm.category"
                required
              >
                <option value="">Select category</option>
                <option v-for="cat in categories" :key="cat.name" :value="cat.name">
                  {{ cat.icon }} {{ cat.name }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label for="description">Description *</label>
            <textarea
              id="description"
              v-model="expenseForm.description"
              placeholder="Enter expense description"
              rows="2"
              required
            ></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="supplierName">Supplier Name</label>
              <input
                id="supplierName"
                v-model="expenseForm.supplier_name"
                type="text"
                placeholder="Enter supplier name"
              />
            </div>

            <div class="form-group">
              <label for="supplierContact">Supplier Contact</label>
              <input
                id="supplierContact"
                v-model="expenseForm.supplier_contact"
                type="text"
                placeholder="Phone or email"
              />
            </div>
          </div>

          <!-- Product Selection (optional) -->
          <div class="form-section">
            <h3>Product Information (Optional)</h3>
            <p class="form-help">Link this expense to a Mellow product — selecting one fills in the ¥ / $ unit cost and delivery price</p>

            <div class="form-row">
              <div class="form-group">
                <label for="productSearch">Product</label>
                <div class="combobox">
                  <input
                    id="productSearch"
                    v-model="productSearch"
                    type="text"
                    autocomplete="off"
                    placeholder="Search product…"
                    @focus="showProductDropdown = true"
                    @input="showProductDropdown = true"
                    @blur="closeProductDropdownSoon"
                  />
                  <button
                    v-if="expenseForm.product_id"
                    type="button"
                    class="combobox-clear"
                    title="Clear"
                    @click="clearProduct"
                  >&times;</button>
                  <ul v-if="showProductDropdown" class="combobox-list">
                    <li class="combobox-item muted" @mousedown.prevent="clearProduct">
                      No product (general expense)
                    </li>
                    <li
                      v-for="product in filteredProducts"
                      :key="product.id"
                      class="combobox-item"
                      :class="{ active: String(product.id) === expenseForm.product_id }"
                      @mousedown.prevent="selectProduct(product)"
                    >
                      <span>{{ product.name }}</span>
                      <span class="combobox-stock">Stock: {{ product.qty ?? 0 }}</span>
                    </li>
                    <li v-if="filteredProducts.length === 0" class="combobox-item muted">
                      No products found
                    </li>
                  </ul>
                </div>
              </div>

              <div class="form-group">
                <label for="quantity">Quantity</label>
                <input
                  id="quantity"
                  v-model.number="expenseForm.quantity"
                  type="number"
                  min="1"
                  placeholder="Quantity purchased"
                  :disabled="!expenseForm.product_id"
                  @input="calculateTotal"
                />
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="totalCostYuan">Total Cost ¥</label>
              <input
                id="totalCostYuan"
                v-model.number="expenseForm.total_cost_yuan"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                @input="convertYuanToUsd"
              />
            </div>

            <div class="form-group">
              <label for="totalCostUsd">
                Total Cost $
                <span class="hint">(auto from ¥ × live rate)</span>
              </label>
              <input
                id="totalCostUsd"
                v-model.number="expenseForm.total_cost_usd"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                @input="calculateTotal"
              />
            </div>
          </div>

          <div class="rate-banner">
            <span v-if="rateLoading">Loading live exchange rate…</span>
            <template v-else-if="cnyToUsdRate">
              <span class="rate-value">Live rate: ¥1 = ${{ cnyToUsdRate.toFixed(4) }}</span>
              <button type="button" class="rate-refresh" :disabled="rateLoading" @click="fetchExchangeRate" title="Refresh rate">↻</button>
              <span v-if="rateUpdatedAt" class="rate-updated">{{ rateUpdatedAt }}</span>
            </template>
            <span v-else class="rate-error">
              {{ rateError || 'Rate unavailable' }}
              <button type="button" class="rate-refresh" :disabled="rateLoading" @click="fetchExchangeRate" title="Retry">↻</button>
            </span>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="deliveryCost">Delivery Price $</label>
              <input
                id="deliveryCost"
                v-model.number="expenseForm.delivery_cost"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                @input="calculateTotal"
              />
            </div>

            <div class="form-group">
              <label for="totalAmount">
                Total Amount *
                <span class="hint">(auto = Total Cost $ + Delivery)</span>
              </label>
              <input
                id="totalAmount"
                v-model.number="expenseForm.total_amount"
                type="number"
                step="0.01"
                min="0"
                placeholder="0.00"
                required
                class="readonly-input"
                readonly
              />
            </div>
          </div>

          <div class="form-group">
            <label for="unitCost">
              Unit Cost $ *
              <span class="hint">(auto = Total Amount ÷ Qty)</span>
            </label>
            <input
              id="unitCost"
              v-model.number="expenseForm.unit_cost"
              type="number"
              step="0.01"
              min="0"
              placeholder="0.00"
              class="readonly-input"
              readonly
              required
            />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="paymentMethod">Payment Method</label>
              <select id="paymentMethod" v-model="expenseForm.payment_method">
                <option value="">Select method</option>
                <option value="Cash">💵 Cash</option>
                <option value="Bank Transfer">🏦 Bank Transfer</option>
                <option value="Credit Card">💳 Credit Card</option>
                <option value="Mobile Payment">📱 Mobile Payment</option>
                <option value="Check">📝 Check</option>
                <option value="Other">Other</option>
              </select>
            </div>

            <div class="form-group">
              <label for="paymentStatus">Payment Status *</label>
              <select id="paymentStatus" v-model="expenseForm.payment_status" required>
                <option value="Paid">Paid</option>
                <option value="Pending">Pending</option>
                <option value="Partial">Partial</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label for="receiptNumber">Receipt/Invoice Number</label>
            <input
              id="receiptNumber"
              v-model="expenseForm.receipt_number"
              type="text"
              placeholder="Enter receipt or invoice number"
            />
          </div>

          <div class="form-group">
            <label for="notes">Notes</label>
            <textarea
              id="notes"
              v-model="expenseForm.notes"
              placeholder="Additional notes (optional)"
              rows="2"
            ></textarea>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="saving">
              {{ saving ? 'Saving...' : (isEditing ? 'Update' : 'Add Expense') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="closeDeleteModal">
      <div class="modal-content delete-modal" @click.stop>
        <div class="modal-header">
          <h2>Delete Expense</h2>
          <button class="modal-close" @click="closeDeleteModal">&times;</button>
        </div>

        <div class="delete-content">
          <p>Are you sure you want to delete this expense?</p>
          <p><strong>#{{ expenseToDelete?.id }} - {{ expenseToDelete?.description }}</strong></p>
          <p class="warning">This action cannot be undone.</p>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeDeleteModal">Cancel</button>
            <button type="button" class="btn btn-danger" @click="deleteExpense" :disabled="deleting">
              {{ deleting ? 'Deleting...' : 'Delete Expense' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Expense management page
interface Expense {
  id: number
  expense_date: string
  category: string
  description: string
  product_id?: number
  product_name?: string
  quantity?: number
  total_cost_yuan?: number
  unit_cost: number
  delivery_cost?: number
  total_amount: number
  supplier_name?: string
  supplier_contact?: string
  payment_method?: string
  payment_status: string
  receipt_number?: string
  notes?: string
  created_at: string
  updated_at: string
}

interface ExpenseCategory {
  id: number
  name: string
  description: string
  icon: string
  color: string
}

// Reactive data
const expenses = ref<Expense[]>([])
const categories = ref<ExpenseCategory[]>([])
// Sourced from the mellow_products table (see fetchProducts)
const products = ref<Array<{
  id: number
  name: string
  qty: number | null
  price_buy_yuan: number | null
  price_buy_usd: number | null
  price_delivery_usd: number | null
}>>([])
const loading = ref(true)
const error = ref<string | null>(null)
const saving = ref(false)
const deleting = ref(false)

// Modal states
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const expenseToEdit = ref<Expense | null>(null)
const expenseToDelete = ref<Expense | null>(null)

// Filter states
const showFilters = ref(false)
const filters = ref({
  dateFrom: '',
  dateTo: '',
  category: '',
  paymentStatus: ''
})

// Table width state
const isTableExpanded = ref(false)

// Sort state
const idSortOrder = ref<'asc' | 'desc'>('desc')

// Form data
const expenseForm = reactive({
  expense_date: getCurrentDate(),
  category: '',
  description: '',
  product_id: '',
  product_name: '',
  quantity: 1,
  total_cost_yuan: 0,
  total_cost_usd: 0,
  unit_cost: 0,
  delivery_cost: 0,
  total_amount: 0,
  supplier_name: '',
  supplier_contact: '',
  payment_method: '',
  payment_status: 'Paid',
  receipt_number: '',
  notes: ''
})

// Searchable product picker state
const productSearch = ref('')
const showProductDropdown = ref(false)

const filteredProducts = computed(() => {
  const q = productSearch.value.trim().toLowerCase()
  if (!q) return products.value
  return products.value.filter(p => p.name.toLowerCase().includes(q))
})

const selectProduct = (product: typeof products.value[number]) => {
  expenseForm.product_id = String(product.id)
  productSearch.value = product.name
  showProductDropdown.value = false
  onProductSelect()
}

const clearProduct = () => {
  expenseForm.product_id = ''
  productSearch.value = ''
  showProductDropdown.value = false
  onProductSelect()
}

const closeProductDropdownSoon = () => {
  // Delay so a click on an option registers before the list closes.
  setTimeout(() => { showProductDropdown.value = false }, 150)
}

// Fetch expenses
const fetchExpenses = async () => {
  try {
    loading.value = true
    error.value = null

    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('expenses')

    if (fetchError) throw fetchError

    expenses.value = (data as unknown as Expense[]) || []

  } catch (err) {
    console.error('Error fetching expenses:', err)
    error.value = 'Failed to load expenses. Please check your database connection.'
  } finally {
    loading.value = false
  }
}

// Fetch categories
const fetchCategories = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('expense_categories')

    if (fetchError) {
      console.error('Error fetching categories:', fetchError)
      return
    }

    categories.value = (data as unknown as ExpenseCategory[]) || []
  } catch (err) {
    console.error('Error fetching categories:', err)
  }
}

// Fetch products from the mellow_products catalog
const fetchProducts = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('mellow_products')

    if (fetchError) {
      console.error('Error fetching mellow products:', fetchError)
      return
    }

    products.value = (data as unknown as typeof products.value) || []
  } catch (err) {
    console.error('Error fetching mellow products:', err)
  }
}

// Product selection handler — prefill the total cost (mellow per-unit price × qty)
const onProductSelect = () => {
  if (expenseForm.product_id) {
    const product = products.value.find(p => p.id === parseInt(expenseForm.product_id))
    if (product) {
      const qty = expenseForm.quantity || 1
      expenseForm.product_name = product.name
      expenseForm.total_cost_yuan = Number(((product.price_buy_yuan || 0) * qty).toFixed(2))
      expenseForm.total_cost_usd = Number(((product.price_buy_usd || 0) * qty).toFixed(2))
      expenseForm.delivery_cost = Number(((product.price_delivery_usd || 0) * qty).toFixed(2))
      // Refresh $ from ¥ at the live rate when available, then derive unit cost.
      convertYuanToUsd()
      calculateTotal()
    }
  } else {
    expenseForm.product_name = ''
    expenseForm.quantity = 1
  }
}

// Calculate total amount = unit cost × quantity + delivery price
const calculateTotal = () => {
  const quantity = expenseForm.quantity || 1
  const delivery = expenseForm.delivery_cost || 0
  const totalCost = expenseForm.total_cost_usd || 0
  // Overall expense = goods total cost + delivery.
  expenseForm.total_amount = Number((totalCost + delivery).toFixed(2))
  // Landed unit cost = total amount (incl. delivery) / quantity.
  expenseForm.unit_cost = Number((expenseForm.total_amount / quantity).toFixed(2))
}

// ==============================================
// Live CNY -> USD exchange rate (same as mellow page).
// Fetched on mount and on manual refresh; converts the ¥ unit cost
// the user types into the $ unit cost field.
// ==============================================
const cnyToUsdRate = ref<number | null>(null)
const rateLoading = ref(false)
const rateUpdatedAt = ref('')
const rateError = ref<string | null>(null)

const fetchExchangeRate = async () => {
  try {
    rateLoading.value = true
    rateError.value = null
    const data = await $fetch<any>('https://open.er-api.com/v6/latest/CNY')
    const usd = data?.rates?.USD
    if (typeof usd === 'number' && usd > 0) {
      cnyToUsdRate.value = usd
      rateUpdatedAt.value = data?.time_last_update_utc || ''
      // Keep the converted $ in sync if a ¥ value is already entered.
      convertYuanToUsd()
    } else {
      throw new Error('USD rate missing in response')
    }
  } catch (err) {
    console.error('Error fetching exchange rate:', err)
    rateError.value = 'Could not load live rate'
  } finally {
    rateLoading.value = false
  }
}

// Recompute Total Cost $ from Total Cost ¥ using the live rate, then derive unit cost.
const convertYuanToUsd = () => {
  if (cnyToUsdRate.value == null) return
  const yuan = expenseForm.total_cost_yuan || 0
  expenseForm.total_cost_usd = Number((yuan * cnyToUsdRate.value).toFixed(2))
  calculateTotal()
}

// Get current date
function getCurrentDate() {
  const today = new Date()
  return today.toISOString().split('T')[0]
}

// Format date
const formatDate = (dateString: string) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return 'Invalid Date'
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// Get category icon
const getCategoryIcon = (categoryName: string) => {
  const category = categories.value.find(c => c.name === categoryName)
  return category?.icon || '💰'
}

// Get category color
const getCategoryColor = (categoryName: string) => {
  const category = categories.value.find(c => c.name === categoryName)
  return category?.color || '#64748b'
}

// Open add modal
const openAddModal = () => {
  isEditing.value = false
  Object.assign(expenseForm, {
    expense_date: getCurrentDate(),
    category: '',
    description: '',
    product_id: '',
    product_name: '',
    quantity: 1,
    total_cost_yuan: 0,
    total_cost_usd: 0,
    unit_cost: 0,
    delivery_cost: 0,
    total_amount: 0,
    supplier_name: '',
    supplier_contact: '',
    payment_method: '',
    payment_status: 'Paid',
    receipt_number: '',
    notes: ''
  })
  productSearch.value = ''
  showProductDropdown.value = false
  showModal.value = true
}

// Open edit modal
const openEditModal = (expense: Expense) => {
  isEditing.value = true
  expenseToEdit.value = expense
  Object.assign(expenseForm, {
    expense_date: expense.expense_date,
    category: expense.category,
    description: expense.description,
    product_id: expense.product_id?.toString() || '',
    product_name: expense.product_name || '',
    quantity: expense.quantity || 1,
    total_cost_yuan: expense.total_cost_yuan || 0,
    total_cost_usd: Number((expense.total_amount - (expense.delivery_cost || 0)).toFixed(2)),
    unit_cost: expense.unit_cost,
    delivery_cost: expense.delivery_cost || 0,
    total_amount: expense.total_amount,
    supplier_name: expense.supplier_name || '',
    supplier_contact: expense.supplier_contact || '',
    payment_method: expense.payment_method || '',
    payment_status: expense.payment_status,
    receipt_number: expense.receipt_number || '',
    notes: expense.notes || ''
  })
  productSearch.value = expense.product_name || ''
  showProductDropdown.value = false
  showModal.value = true
}

// Close modal
const closeModal = () => {
  showModal.value = false
  isEditing.value = false
  expenseToEdit.value = null
}

// Save expense
const saveExpense = async () => {
  try {
    saving.value = true

    const expenseData: any = {
      expense_date: expenseForm.expense_date,
      category: expenseForm.category.trim(),
      description: expenseForm.description.trim(),
      total_cost_yuan: expenseForm.total_cost_yuan || 0,
      unit_cost: expenseForm.unit_cost,
      delivery_cost: expenseForm.delivery_cost || 0,
      total_amount: expenseForm.total_amount,
      payment_status: expenseForm.payment_status
    }

    // Add optional fields
    if (expenseForm.product_id) {
      expenseData.product_id = parseInt(expenseForm.product_id)
      expenseData.product_name = expenseForm.product_name
      expenseData.quantity = expenseForm.quantity
    }

    if (expenseForm.supplier_name) expenseData.supplier_name = expenseForm.supplier_name.trim()
    if (expenseForm.supplier_contact) expenseData.supplier_contact = expenseForm.supplier_contact.trim()
    if (expenseForm.payment_method) expenseData.payment_method = expenseForm.payment_method
    if (expenseForm.receipt_number) expenseData.receipt_number = expenseForm.receipt_number.trim()
    if (expenseForm.notes) expenseData.notes = expenseForm.notes.trim()

    if (isEditing.value && expenseToEdit.value) {
      const { update } = useSupabaseDB()
      const { error: updateError } = await update('expenses', expenseData).eq('id', expenseToEdit.value.id)
      if (updateError) throw updateError
    } else {
      const { insert } = useSupabaseDB()
      const { error: insertError } = await insert('expenses', [expenseData]).select()
      if (insertError) throw insertError
    }

    closeModal()
    await fetchExpenses()

  } catch (err) {
    console.error('Error saving expense:', err)
    alert('Failed to save expense. Please try again.')
  } finally {
    saving.value = false
  }
}

// Confirm delete
const confirmDelete = (expense: Expense) => {
  expenseToDelete.value = expense
  showDeleteModal.value = true
}

// Close delete modal
const closeDeleteModal = () => {
  showDeleteModal.value = false
  expenseToDelete.value = null
}

// Delete expense
const deleteExpense = async () => {
  try {
    deleting.value = true

    if (!expenseToDelete.value) return

    const { delete: deleteRecord } = useSupabaseDB()
    const { error } = await deleteRecord('expenses').eq('id', expenseToDelete.value.id)

    if (error) throw error

    closeDeleteModal()
    await fetchExpenses()

  } catch (err) {
    console.error('Error deleting expense:', err)
    alert('Failed to delete expense. Please try again.')
  } finally {
    deleting.value = false
  }
}

// Filter functions
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const clearFilters = () => {
  filters.value = {
    dateFrom: '',
    dateTo: '',
    category: '',
    paymentStatus: ''
  }
}

const applyFilters = () => {
  // Filters are applied automatically via computed property
}

// Toggle ID sort order
const toggleIdSort = () => {
  idSortOrder.value = idSortOrder.value === 'asc' ? 'desc' : 'asc'
}

// ==============================================
// Column ordering (drag-and-drop) — required by rules.md
// ==============================================
const availableColumns = [
  { key: 'id', label: 'Id' },
  { key: 'date', label: 'Date' },
  { key: 'category', label: 'Category' },
  { key: 'description', label: 'Description' },
  { key: 'product', label: 'Product' },
  { key: 'quantity', label: 'Quantity' },
  { key: 'total_cost', label: 'Total Cost $' },
  { key: 'delivery', label: 'Delivery $' },
  { key: 'unit_cost', label: 'Unit Cost' },
  { key: 'total_amount', label: 'Total Amount' },
  { key: 'payment_status', label: 'Payment Status' },
  { key: 'invoice', label: 'Invoice #' },
  { key: 'notes', label: 'Notes' },
  { key: 'actions', label: 'Actions' }
]

const columnOrder = ref<string[]>(availableColumns.map(c => c.key))
const draggedColumn = ref<string | null>(null)
const dragOverColumn = ref<string | null>(null)

const getColumnLabel = (columnKey: string) => {
  const column = availableColumns.find(col => col.key === columnKey)
  return column ? column.label : columnKey
}

const COLUMN_ORDER_KEY = 'expenseColumnOrder'

const loadColumnOrder = () => {
  const saved = localStorage.getItem(COLUMN_ORDER_KEY)
  if (saved) {
    try {
      const parsed = JSON.parse(saved) as string[]
      const known = availableColumns.map(c => c.key)
      const valid = parsed.filter(k => known.includes(k))
      const missing = known.filter(k => !valid.includes(k))
      columnOrder.value = [...valid, ...missing]
    } catch (e) {
      console.warn('Failed to load column order:', e)
    }
  }
}

const saveColumnOrder = () => {
  localStorage.setItem(COLUMN_ORDER_KEY, JSON.stringify(columnOrder.value))
}

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
  const draggedIndex = columnOrder.value.indexOf(draggedColumn.value)
  const targetIndex = columnOrder.value.indexOf(targetColumnKey)
  if (draggedIndex !== -1 && targetIndex !== -1) {
    const draggedItem = columnOrder.value.splice(draggedIndex, 1)[0]
    if (draggedItem) {
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

// Toggle table width
const toggleTableWidth = () => {
  isTableExpanded.value = !isTableExpanded.value
  localStorage.setItem('expenseTableExpanded', JSON.stringify(isTableExpanded.value))
}

// Load table width preference
const loadTableWidthPreference = () => {
  const saved = localStorage.getItem('expenseTableExpanded')
  if (saved !== null) {
    try {
      isTableExpanded.value = JSON.parse(saved)
    } catch (e) {
      isTableExpanded.value = false
    }
  }
}

// Computed properties
const totalExpenses = computed(() =>
  expenses.value.reduce((sum, expense) => sum + expense.total_amount, 0)
)

const monthlyExpenses = computed(() => {
  const now = new Date()
  const currentMonth = now.getMonth()
  const currentYear = now.getFullYear()

  return expenses.value
    .filter(expense => {
      const date = new Date(expense.expense_date)
      return date.getMonth() === currentMonth && date.getFullYear() === currentYear
    })
    .reduce((sum, expense) => sum + expense.total_amount, 0)
})

const averageExpense = computed(() =>
  expenses.value.length > 0 ? totalExpenses.value / expenses.value.length : 0
)

const filteredExpenses = computed(() => {
  let filtered = [...expenses.value]

  if (filters.value.dateFrom) {
    const fromDate = new Date(filters.value.dateFrom)
    filtered = filtered.filter(expense => new Date(expense.expense_date) >= fromDate)
  }

  if (filters.value.dateTo) {
    const toDate = new Date(filters.value.dateTo)
    toDate.setHours(23, 59, 59, 999)
    filtered = filtered.filter(expense => new Date(expense.expense_date) <= toDate)
  }

  if (filters.value.category) {
    filtered = filtered.filter(expense => expense.category === filters.value.category)
  }

  if (filters.value.paymentStatus) {
    filtered = filtered.filter(expense => expense.payment_status === filters.value.paymentStatus)
  }

  return filtered.sort((a, b) =>
    idSortOrder.value === 'asc' ? a.id - b.id : b.id - a.id
  )
})

// Fetch data on mount
onMounted(async () => {
  loadColumnOrder()
  loadTableWidthPreference()
  await Promise.all([
    fetchExpenses(),
    fetchCategories(),
    fetchProducts(),
    fetchExchangeRate()
  ])
})
</script>

<style scoped>
/* Base Page Styles */
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
}

.error-message h3 {
  color: #721c24;
  margin-bottom: 1rem;
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

/* Filter Panel */
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
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.filter-group {
  display: flex;
  flex-direction: column;
}

.filter-group label {
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.date-range {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.form-input,
.form-select {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  transition: border-color 0.2s;
  width: 100%;
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

/* Table Styles */
.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow-x: auto;
  overflow-y: auto;
  max-height: 70vh;
}

.expenses-table {
  width: 100%;
  min-width: 1200px;
  border-collapse: collapse;
}

.expenses-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
  white-space: nowrap;
  /* Sticky header — stays visible while scrolling (rules.md) */
  position: sticky;
  top: 0;
  z-index: 20;
}

.expenses-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
}

.expenses-table tr:hover {
  background: #f8f9fa;
}

.expenses-table th.sortable {
  cursor: pointer;
  user-select: none;
}

.expenses-table th.sortable:hover {
  background: #eceff1;
}

.sort-indicator {
  margin-left: 0.25rem;
  font-size: 0.75rem;
  color: #6c757d;
}

/* Sticky Column */
.sticky-column {
  position: sticky;
  right: 0;
  background: #f8f9fa;
  box-shadow: -2px 0 4px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

/* Sticky header + sticky column corner stays above both axes */
.expenses-table thead th.sticky-column {
  top: 0;
  z-index: 30;
}

.expenses-table tbody td.sticky-column {
  background: white;
}

.expenses-table tbody tr:hover td.sticky-column {
  background: #f8f9fa;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 0.5rem;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
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
}

.modal-close:hover {
  color: #e74c3c;
}

.expense-form {
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
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3498db;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
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

/* Button Styles */
.btn {
  padding: 0.75rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
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
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn-secondary:hover {
  background-color: #7f8c8d;
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

.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
}

.btn-edit {
  background-color: #ffc107;
  color: #212529;
  border: none;
  padding: 0.5rem;
  font-size: 0.9rem;
  cursor: pointer;
  border-radius: 6px;
}

.btn-edit:hover {
  background-color: #e0a800;
}

.btn-delete {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 0.5rem;
  font-size: 0.9rem;
  cursor: pointer;
  border-radius: 6px;
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

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.readonly-input {
  background-color: #f9fafb;
  color: #6b7280;
  cursor: not-allowed;
}

.form-group label .hint {
  font-weight: 400;
  font-size: 0.8rem;
  color: #7f8c8d;
}

.rate-banner {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
  margin: -0.75rem 0 1.5rem;
  font-size: 0.85rem;
  color: #5a6c7d;
}

.rate-banner .rate-value {
  font-weight: 600;
  color: #2c3e50;
}

.rate-banner .rate-updated {
  font-size: 0.75rem;
  color: #95a5a6;
}

.rate-banner .rate-error {
  color: #c0392b;
}

.rate-refresh {
  border: 1px solid #dee2e6;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  padding: 0.1rem 0.45rem;
  font-size: 0.9rem;
  line-height: 1;
  color: #2c3e50;
}

.rate-refresh:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Searchable product combobox */
.combobox {
  position: relative;
}

.combobox-clear {
  position: absolute;
  right: 0.6rem;
  top: 0.75rem;
  border: none;
  background: none;
  font-size: 1.4rem;
  line-height: 1;
  cursor: pointer;
  color: #7f8c8d;
}

.combobox-clear:hover {
  color: #e74c3c;
}

.combobox-list {
  position: absolute;
  z-index: 20;
  top: 100%;
  left: 0;
  right: 0;
  margin: 0.25rem 0 0;
  padding: 0.25rem 0;
  list-style: none;
  background: #fff;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
  max-height: 240px;
  overflow-y: auto;
}

.combobox-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 0.75rem;
  cursor: pointer;
  font-size: 0.95rem;
  color: #2c3e50;
}

.combobox-item:hover {
  background: #f1f5f9;
}

.combobox-item.active {
  background: #e8f4fd;
  font-weight: 600;
}

.combobox-item.muted {
  color: #94a3b8;
}

.combobox-stock {
  font-size: 0.8rem;
  color: #94a3b8;
  white-space: nowrap;
}

/* Expense-specific styles */
.summary-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.summary-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.summary-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  border-radius: 12px;
}

.summary-content h3 {
  font-size: 0.9rem;
  color: #6c757d;
  margin: 0 0 0.5rem 0;
  font-weight: 500;
}

.summary-value {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
}

.category-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  color: white;
  display: inline-block;
}

.description-cell,
.notes-cell {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.amount-cell {
  font-weight: 600;
  color: #e74c3c;
}

.form-section {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

.form-section h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  color: #2c3e50;
}

.form-help {
  margin: 0 0 1rem 0;
  font-size: 0.9rem;
  color: #6c757d;
}

.status-badge.paid {
  background: #d4edda;
  color: #155724;
}

.status-badge.pending {
  background: #fff3cd;
  color: #856404;
}

.status-badge.partial {
  background: #cce5ff;
  color: #004085;
}

/* Drag and drop headers */
.draggable-header {
  cursor: move;
  transition: all 0.2s ease;
}
.draggable-header:hover { background: #e9ecef; }
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
.draggable-header:hover .drag-handle { opacity: 1; }
.draggable-header.dragging .drag-handle { cursor: grabbing; }
.header-text { flex: 1; }

@media (max-width: 768px) {
  .summary-cards {
    grid-template-columns: 1fr;
  }

  .summary-card {
    padding: 1rem;
  }

  .summary-icon {
    width: 50px;
    height: 50px;
    font-size: 2rem;
  }

  .summary-value {
    font-size: 1.5rem;
  }
}
</style>
