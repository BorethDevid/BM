<template>
  <div class="page-container" :class="{ 'expanded': isTableExpanded }">
    <div class="page-header">
      <h1>Income & Profit Analytics</h1>
      <p>Track revenue, calculate profits, and analyze business performance</p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading data...</p>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Profit Summary Cards -->
      <div class="summary-cards">
        <div class="summary-card revenue">
          <div class="summary-icon">💰</div>
          <div class="summary-content">
            <h3>Total Revenue</h3>
            <p class="summary-value green">${{ stats.totalRevenue.toFixed(2) }}</p>
            <span class="summary-trend">From {{ incomeRecords.length }} transactions</span>
          </div>
        </div>
        <div class="summary-card expenses">
          <div class="summary-icon">💸</div>
          <div class="summary-content">
            <h3>Total Expenses</h3>
            <p class="summary-value red">${{ stats.totalExpenses.toFixed(2) }}</p>
            <span class="summary-trend">Business costs</span>
          </div>
        </div>
        <div class="summary-card profit">
          <div class="summary-icon">📈</div>
          <div class="summary-content">
            <h3>Net Profit</h3>
            <p :class="['summary-value', stats.netProfit >= 0 ? 'green' : 'red']">
              ${{ stats.netProfit.toFixed(2) }}
            </p>
            <span :class="['summary-trend', stats.netProfit >= 0 ? 'positive' : 'negative']">
              {{ stats.netProfit >= 0 ? '↑' : '↓' }} Profit Margin: {{ stats.profitMargin.toFixed(1) }}%
            </span>
          </div>
        </div>
        <div class="summary-card average">
          <div class="summary-icon">💎</div>
          <div class="summary-content">
            <h3>Avg Profit/Sale</h3>
            <p class="summary-value">${{ stats.avgProfit.toFixed(2) }}</p>
            <span class="summary-trend">Per transaction</span>
          </div>
        </div>
      </div>

      <!-- Action Bar -->
      <div class="action-bar">
        <div class="action-left">
          <button class="btn btn-primary" @click="openAddModal">
            <span>+</span> Add Income
          </button>
          <button class="btn btn-secondary" @click="refreshData">
            Refresh Data
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
          <h3>🔍 Filter Income</h3>
          <button class="btn btn-sm btn-outline" @click="clearFilters">Clear All</button>
        </div>

        <div class="filter-grid">
          <div class="filter-group">
            <label>Date Range</label>
            <div class="date-range">
              <input type="date" v-model="filters.dateFrom" class="form-input" />
              <input type="date" v-model="filters.dateTo" class="form-input" />
            </div>
          </div>

          <div class="filter-group">
            <label>Category</label>
            <select v-model="filters.category" class="form-select">
              <option value="">All Categories</option>
              <option v-for="cat in categories" :key="cat.name" :value="cat.name">
                {{ cat.icon }} {{ cat.name }}
              </option>
            </select>
          </div>

          <div class="filter-group">
            <label>Payment Status</label>
            <select v-model="filters.paymentStatus" class="form-select">
              <option value="">All Statuses</option>
              <option value="Received">Received</option>
              <option value="Pending">Pending</option>
              <option value="Partial">Partial</option>
            </select>
          </div>
        </div>

        <div class="filter-footer">
          <div class="filter-stats">
            Showing {{ filteredIncome.length }} of {{ incomeRecords.length }} records
          </div>
        </div>
      </div>

      <!-- Income Table -->
      <div v-if="incomeRecords.length > 0" class="table-section">
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Date</th>
                <th>Category</th>
                <th>Description</th>
                <th>Source</th>
                <th>Revenue</th>
                <th>Cost</th>
                <th>Profit</th>
                <th>Status</th>
                <th class="sticky-column">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="record in filteredIncome" :key="record.id">
                <td>#{{ record.id }}</td>
                <td>{{ formatDate(record.income_date) }}</td>
                <td>
                  <span class="category-badge" :style="{ background: getCategoryColor(record.category) }">
                    {{ getCategoryIcon(record.category) }} {{ record.category }}
                  </span>
                </td>
                <td class="description-cell">{{ record.description }}</td>
                <td>{{ record.source || '-' }}</td>
                <td class="amount-cell green">${{ record.amount.toFixed(2) }}</td>
                <td class="amount-cell">${{ (record.cost || 0).toFixed(2) }}</td>
                <td :class="['amount-cell', 'profit-cell', record.profit >= 0 ? 'positive' : 'negative']">
                  ${{ record.profit.toFixed(2) }}
                </td>
                <td>
                  <span :class="['status-badge', record.payment_status.toLowerCase()]">
                    {{ record.payment_status }}
                  </span>
                </td>
                <td class="sticky-column">
                  <div class="action-buttons">
                    <button class="btn btn-sm btn-edit" @click="openEditModal(record)">✏️</button>
                    <button class="btn btn-sm btn-delete" @click="confirmDelete(record)">🗑️</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <h3>No Income Records</h3>
        <p>Start tracking your business income!</p>
        <button class="btn btn-primary" @click="openAddModal">Add First Income</button>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Income' : 'Add Income' }}</h2>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>

        <form @submit.prevent="saveIncome" class="income-form">
          <div class="form-row">
            <div class="form-group">
              <label>Income Date *</label>
              <input v-model="incomeForm.income_date" type="date" :max="getCurrentDate()" required />
            </div>
            <div class="form-group">
              <label>Category *</label>
              <select v-model="incomeForm.category" required>
                <option value="">Select category</option>
                <option v-for="cat in categories" :key="cat.name" :value="cat.name">
                  {{ cat.icon }} {{ cat.name }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Description *</label>
            <textarea v-model="incomeForm.description" placeholder="Enter description" rows="2" required></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Source/Customer</label>
              <input v-model="incomeForm.source" type="text" placeholder="Who paid you?" />
            </div>
            <div class="form-group">
              <label>Reference Number</label>
              <input v-model="incomeForm.reference_number" type="text" placeholder="Invoice #" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Revenue Amount *</label>
              <input v-model.number="incomeForm.amount" type="number" step="0.01" min="0" @input="calculateProfit" required />
            </div>
            <div class="form-group">
              <label>Cost (Optional)</label>
              <input v-model.number="incomeForm.cost" type="number" step="0.01" min="0" @input="calculateProfit" />
            </div>
          </div>

          <div class="profit-display">
            <label>Calculated Profit:</label>
            <span :class="['profit-value', calculatedProfit >= 0 ? 'positive' : 'negative']">
              ${{ calculatedProfit.toFixed(2) }}
            </span>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Payment Method</label>
              <select v-model="incomeForm.payment_method">
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
              <label>Payment Status *</label>
              <select v-model="incomeForm.payment_status" required>
                <option value="Received">Received</option>
                <option value="Pending">Pending</option>
                <option value="Partial">Partial</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Notes</label>
            <textarea v-model="incomeForm.notes" placeholder="Additional notes" rows="2"></textarea>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="saving">
              {{ saving ? 'Saving...' : (isEditing ? 'Update' : 'Add Income') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Modal -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="closeDeleteModal">
      <div class="modal-content delete-modal" @click.stop>
        <div class="modal-header">
          <h2>Delete Income</h2>
          <button class="modal-close" @click="closeDeleteModal">&times;</button>
        </div>
        <div class="delete-content">
          <p>Delete this income record?</p>
          <p><strong>#{{ recordToDelete?.id }} - {{ recordToDelete?.description }}</strong></p>
          <p class="warning">This action cannot be undone.</p>
          <div class="form-actions">
            <button class="btn btn-secondary" @click="closeDeleteModal">Cancel</button>
            <button class="btn btn-danger" @click="deleteIncome" :disabled="deleting">
              {{ deleting ? 'Deleting...' : 'Delete' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface IncomeRecord {
  id: number
  income_date: string
  category: string
  description: string
  order_id?: number
  amount: number
  cost: number
  profit: number
  source?: string
  payment_method?: string
  payment_status: string
  reference_number?: string
  notes?: string
  created_at: string
}

interface Category {
  id: number
  name: string
  description: string
  icon: string
  color: string
}

const incomeRecords = ref<IncomeRecord[]>([])
const expenseRecords = ref<any[]>([])
const categories = ref<Category[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const saving = ref(false)
const deleting = ref(false)

const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const recordToEdit = ref<IncomeRecord | null>(null)
const recordToDelete = ref<IncomeRecord | null>(null)

const showFilters = ref(false)
const filters = ref({
  dateFrom: '',
  dateTo: '',
  category: '',
  paymentStatus: ''
})

const isTableExpanded = ref(false)

const incomeForm = reactive({
  income_date: getCurrentDate(),
  category: '',
  description: '',
  amount: 0,
  cost: 0,
  source: '',
  payment_method: '',
  payment_status: 'Received',
  reference_number: '',
  notes: ''
})

function getCurrentDate() {
  return new Date().toISOString().split('T')[0]
}

const fetchIncome = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('income')
    if (fetchError) throw fetchError
    incomeRecords.value = (data as unknown as IncomeRecord[]) || []
  } catch (err) {
    console.error('Error fetching income:', err)
  }
}

const fetchExpenses = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('expenses')
    if (fetchError) throw fetchError
    expenseRecords.value = (data as unknown as any[]) || []
  } catch (err) {
    console.error('Error fetching expenses:', err)
  }
}

const fetchCategories = async () => {
  try {
    const { select } = useSupabaseDB()
    const { data, error: fetchError } = await select('income_categories')
    if (fetchError) throw fetchError
    categories.value = (data as unknown as Category[]) || []
  } catch (err) {
    console.error('Error fetching categories:', err)
  }
}

const refreshData = async () => {
  loading.value = true
  await Promise.all([fetchIncome(), fetchExpenses(), fetchCategories()])
  loading.value = false
}

const formatDate = (dateString: string) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const getCategoryIcon = (categoryName: string) => {
  const category = categories.value.find(c => c.name === categoryName)
  return category?.icon || '💰'
}

const getCategoryColor = (categoryName: string) => {
  const category = categories.value.find(c => c.name === categoryName)
  return category?.color || '#10b981'
}

const openAddModal = () => {
  isEditing.value = false
  Object.assign(incomeForm, {
    income_date: getCurrentDate(),
    category: '',
    description: '',
    amount: 0,
    cost: 0,
    source: '',
    payment_method: '',
    payment_status: 'Received',
    reference_number: '',
    notes: ''
  })
  showModal.value = true
}

const openEditModal = (record: IncomeRecord) => {
  isEditing.value = true
  recordToEdit.value = record
  Object.assign(incomeForm, {
    income_date: record.income_date,
    category: record.category,
    description: record.description,
    amount: record.amount,
    cost: record.cost || 0,
    source: record.source || '',
    payment_method: record.payment_method || '',
    payment_status: record.payment_status,
    reference_number: record.reference_number || '',
    notes: record.notes || ''
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  isEditing.value = false
  recordToEdit.value = null
}

const calculateProfit = () => {
  // Profit is calculated automatically in the database
}

const calculatedProfit = computed(() => {
  return (incomeForm.amount || 0) - (incomeForm.cost || 0)
})

const saveIncome = async () => {
  try {
    saving.value = true
    const data: any = {
      income_date: incomeForm.income_date,
      category: incomeForm.category.trim(),
      description: incomeForm.description.trim(),
      amount: incomeForm.amount,
      cost: incomeForm.cost || 0,
      payment_status: incomeForm.payment_status
    }

    if (incomeForm.source) data.source = incomeForm.source.trim()
    if (incomeForm.payment_method) data.payment_method = incomeForm.payment_method
    if (incomeForm.reference_number) data.reference_number = incomeForm.reference_number.trim()
    if (incomeForm.notes) data.notes = incomeForm.notes.trim()

    if (isEditing.value && recordToEdit.value) {
      const { update } = useSupabaseDB()
      const { error: updateError } = await update('income', data).eq('id', recordToEdit.value.id)
      if (updateError) throw updateError
    } else {
      const { insert } = useSupabaseDB()
      const { error: insertError } = await insert('income', [data]).select()
      if (insertError) throw insertError
    }

    closeModal()
    await refreshData()
  } catch (err) {
    console.error('Error saving income:', err)
    alert('Failed to save income. Please try again.')
  } finally {
    saving.value = false
  }
}

const confirmDelete = (record: IncomeRecord) => {
  recordToDelete.value = record
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  recordToDelete.value = null
}

const deleteIncome = async () => {
  try {
    deleting.value = true
    if (!recordToDelete.value) return

    const { delete: deleteRecord } = useSupabaseDB()
    const { error } = await deleteRecord('income').eq('id', recordToDelete.value.id)
    if (error) throw error

    closeDeleteModal()
    await refreshData()
  } catch (err) {
    console.error('Error deleting income:', err)
    alert('Failed to delete income. Please try again.')
  } finally {
    deleting.value = false
  }
}

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

const toggleTableWidth = () => {
  isTableExpanded.value = !isTableExpanded.value
  localStorage.setItem('incomeTableExpanded', JSON.stringify(isTableExpanded.value))
}

const loadTableWidthPreference = () => {
  const saved = localStorage.getItem('incomeTableExpanded')
  if (saved !== null) {
    try {
      isTableExpanded.value = JSON.parse(saved)
    } catch (e) {
      isTableExpanded.value = false
    }
  }
}

const stats = computed(() => {
  const totalRevenue = incomeRecords.value.reduce((sum, r) => sum + r.amount, 0)
  const totalCost = incomeRecords.value.reduce((sum, r) => sum + (r.cost || 0), 0)
  const grossProfit = incomeRecords.value.reduce((sum, r) => sum + r.profit, 0)
  const totalExpenses = expenseRecords.value.reduce((sum, e) => sum + e.total_amount, 0)
  const netProfit = grossProfit - totalExpenses
  const profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0
  const avgProfit = incomeRecords.value.length > 0 ? grossProfit / incomeRecords.value.length : 0

  return {
    totalRevenue,
    totalExpenses,
    grossProfit,
    netProfit,
    profitMargin,
    avgProfit
  }
})

const monthlyTransactions = computed(() => {
  const now = new Date()
  const currentMonth = now.getMonth()
  const currentYear = now.getFullYear()

  return incomeRecords.value.filter(record => {
    const date = new Date(record.income_date)
    return date.getMonth() === currentMonth && date.getFullYear() === currentYear
  }).length
})

const filteredIncome = computed(() => {
  let filtered = [...incomeRecords.value]

  if (filters.value.dateFrom) {
    filtered = filtered.filter(r => new Date(r.income_date) >= new Date(filters.value.dateFrom))
  }

  if (filters.value.dateTo) {
    const toDate = new Date(filters.value.dateTo)
    toDate.setHours(23, 59, 59, 999)
    filtered = filtered.filter(r => new Date(r.income_date) <= toDate)
  }

  if (filters.value.category) {
    filtered = filtered.filter(r => r.category === filters.value.category)
  }

  if (filters.value.paymentStatus) {
    filtered = filtered.filter(r => r.payment_status === filters.value.paymentStatus)
  }

  return filtered.sort((a, b) => new Date(b.income_date).getTime() - new Date(a.income_date).getTime())
})

onMounted(async () => {
  loadTableWidthPreference()
  await refreshData()
})
</script>

<style scoped>
/* Copy all the base styles from expenses.vue */
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
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.summary-card.revenue {
  border-left: 4px solid #10b981;
}

.summary-card.expenses {
  border-left: 4px solid #ef4444;
}

.summary-card.profit {
  border-left: 4px solid #3b82f6;
}

.summary-card.average {
  border-left: 4px solid #8b5cf6;
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

.summary-value.green {
  color: #10b981;
}

.summary-value.red {
  color: #ef4444;
}

.summary-trend {
  font-size: 0.85rem;
  color: #6c757d;
}

.summary-trend.positive {
  color: #10b981;
}

.summary-trend.negative {
  color: #ef4444;
}

.action-bar {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  justify-content: space-between;
}

.action-left, .action-right {
  display: flex;
  gap: 1rem;
}

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
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.filter-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.filter-group label {
  display: block;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.date-range {
  display: flex;
  gap: 0.75rem;
}

.form-input, .form-select {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  width: 100%;
}

.filter-footer {
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.filter-stats {
  color: #6b7280;
  font-size: 0.9rem;
}

.table-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow-x: auto;
}

.data-table {
  width: 100%;
  min-width: 1200px;
  border-collapse: collapse;
}

.data-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
}

.data-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
}

.data-table tr:hover {
  background: #f8f9fa;
}

.sticky-column {
  position: sticky;
  right: 0;
  background: #f8f9fa;
  box-shadow: -2px 0 4px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.data-table tbody td.sticky-column {
  background: white;
}

.data-table tbody tr:hover td.sticky-column {
  background: #f8f9fa;
}

.category-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  color: white;
  display: inline-block;
}

.description-cell {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.amount-cell {
  font-weight: 600;
}

.amount-cell.green {
  color: #10b981;
}

.profit-cell.positive {
  color: #10b981;
}

.profit-cell.negative {
  color: #ef4444;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.received {
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

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

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

.modal-close {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #7f8c8d;
}

.income-form {
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
}

.profit-display {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.profit-value {
  font-size: 1.5rem;
  font-weight: 700;
}

.profit-value.positive {
  color: #10b981;
}

.profit-value.negative {
  color: #ef4444;
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

.warning {
  color: #dc3545;
  font-weight: 600;
}

.btn {
  padding: 0.75rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover {
  background-color: #2980b9;
}

.btn-secondary {
  background-color: #95a5a6;
  color: white;
}

.btn-outline {
  background: transparent;
  border: 1px solid #dee2e6;
  color: #6c757d;
}

.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
}

.btn-edit {
  background-color: #ffc107;
  color: #212529;
  padding: 0.5rem;
  border-radius: 6px;
}

.btn-delete {
  background-color: #dc3545;
  color: white;
  padding: 0.5rem;
  border-radius: 6px;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
}
</style>
