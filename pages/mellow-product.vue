<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Mellow Product</h1>
      <p>Manage mellow products, pricing breakdown and product images</p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Loading products...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-message">
        <h3>⚠️ Connection Error</h3>
        <p>{{ error }}</p>
        <p><strong>To fix this:</strong></p>
        <ol>
          <li>Make sure your Supabase connection is working</li>
          <li>Create a <code>mellow_products</code> table by running
            <code>database/migrations/05-add-mellow-products.sql</code></li>
          <li>Check your environment variables</li>
        </ol>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Action Bar -->
      <div class="action-bar">
        <button class="btn btn-primary" @click="openAddModal">
          <span>+</span> Add New Product
        </button>
        <button class="btn btn-secondary" @click="fetchProducts">
          Refresh
        </button>
      </div>

      <!-- Products Table -->
      <div v-if="products.length > 0" class="products-section">
        <div class="table-container">
          <table class="products-table">
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
                    'drag-over': dragOverColumn === columnKey
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
              <tr v-for="(product, index) in products" :key="product.id">
                <td v-for="columnKey in columnOrder" :key="columnKey">
                  <!-- Index -->
                  <span v-if="columnKey === 'index'">{{ index + 1 }}</span>

                  <!-- Name -->
                  <span v-else-if="columnKey === 'name'" class="product-name">{{ product.name }}</span>

                  <!-- QTY -->
                  <span v-else-if="columnKey === 'qty'">{{ product.qty ?? 0 }}</span>

                  <!-- Price Buy ¥ -->
                  <span v-else-if="columnKey === 'priceBuyYuan'">{{ formatYuan(product.price_buy_yuan) }}</span>

                  <!-- Price Buy $ -->
                  <span v-else-if="columnKey === 'priceBuyUsd'">{{ formatUsd(product.price_buy_usd) }}</span>

                  <!-- Price Delivery $ -->
                  <span v-else-if="columnKey === 'priceDeliveryUsd'">{{ formatUsd(product.price_delivery_usd) }}</span>

                  <!-- Price Total / Unit $ -->
                  <span v-else-if="columnKey === 'priceTotalPerUnit'">{{ formatUsd(product.price_total_per_unit_usd) }}</span>

                  <!-- Price Sell $ -->
                  <span v-else-if="columnKey === 'priceSellUsd'">{{ formatUsd(product.price_sell_usd) }}</span>

                  <!-- Type Shop -->
                  <span v-else-if="columnKey === 'typeShop'">{{ product.type_shop || '-' }}</span>

                  <!-- Pic CN Shop -->
                  <div v-else-if="columnKey === 'picCnShop'" class="pic-cell">
                    <img
                      v-if="product.pic_cn_shop"
                      :src="product.pic_cn_shop"
                      alt="CN Shop"
                      class="pic-thumb"
                      @click="openImagePreview(product.pic_cn_shop)"
                    />
                    <span v-else class="no-data">-</span>
                  </div>

                  <!-- Pic Bag -->
                  <div v-else-if="columnKey === 'picBag'" class="pic-cell">
                    <img
                      v-if="product.pic_bag"
                      :src="product.pic_bag"
                      alt="Bag"
                      class="pic-thumb"
                      @click="openImagePreview(product.pic_bag)"
                    />
                    <span v-else class="no-data">-</span>
                  </div>

                  <!-- Actions -->
                  <div v-else-if="columnKey === 'actions'" class="action-buttons">
                    <button class="btn btn-sm btn-edit" @click="openEditModal(product)" title="Edit product">✏️</button>
                    <button class="btn btn-sm btn-delete" @click="confirmDelete(product)" title="Delete product">🗑️</button>
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
        <p>Create your first mellow product to get started!</p>
        <button class="btn btn-primary" @click="openAddModal">
          Add First Product
        </button>
      </div>
    </div>

    <!-- Add/Edit Product Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ isEditing ? 'Edit Product' : 'Add New Product' }}</h2>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>

        <form @submit.prevent="saveProduct" class="product-form">
          <div class="form-group">
            <label for="name">Name *</label>
            <input id="name" v-model="productForm.name" type="text" placeholder="Enter product name" required />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="qty">QTY</label>
              <input id="qty" v-model.number="productForm.qty" type="number" min="0" step="1" placeholder="0" />
            </div>
            <div class="form-group">
              <label for="typeShop">Type Shop</label>
              <input id="typeShop" v-model="productForm.type_shop" type="text" placeholder="e.g. Taobao, 1688" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="priceBuyYuan">Price Buy ¥</label>
              <input id="priceBuyYuan" v-model.number="productForm.price_buy_yuan" type="number" min="0" step="0.01" placeholder="0.00" @input="convertYuanToUsd" />
            </div>
            <div class="form-group">
              <label for="priceBuyUsd">
                Price Buy $
                <span class="hint">(auto from ¥ × live rate)</span>
              </label>
              <input id="priceBuyUsd" v-model.number="productForm.price_buy_usd" type="number" min="0" step="0.01" placeholder="0.00" />
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
              <label for="priceDeliveryUsd">Price Delivery $</label>
              <input id="priceDeliveryUsd" v-model.number="productForm.price_delivery_usd" type="number" min="0" step="0.01" placeholder="0.00" />
            </div>
            <div class="form-group">
              <label for="priceTotalPerUnit">
                Price Total / Unit $
                <span class="hint">(auto = Buy $ + Delivery $)</span>
              </label>
              <input id="priceTotalPerUnit" v-model.number="productForm.price_total_per_unit_usd" type="number" min="0" step="0.01" placeholder="0.00" />
            </div>
          </div>

          <div class="form-group">
            <label for="priceSellUsd">Price Sell $</label>
            <input id="priceSellUsd" v-model.number="productForm.price_sell_usd" type="number" min="0" step="0.01" placeholder="0.00" />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Pic CN Shop</label>
              <input type="file" accept="image/*" @change="onImageChange($event, 'pic_cn_shop')" />
              <div v-if="productForm.pic_cn_shop" class="image-preview">
                <img :src="productForm.pic_cn_shop" alt="CN Shop preview" />
                <button type="button" class="remove-image" @click="productForm.pic_cn_shop = ''">Remove</button>
              </div>
            </div>
            <div class="form-group">
              <label>Pic Bag</label>
              <input type="file" accept="image/*" @change="onImageChange($event, 'pic_bag')" />
              <div v-if="productForm.pic_bag" class="image-preview">
                <img :src="productForm.pic_bag" alt="Bag preview" />
                <button type="button" class="remove-image" @click="productForm.pic_bag = ''">Remove</button>
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="saving">
              {{ saving ? 'Saving...' : (isEditing ? 'Update Product' : 'Add Product') }}
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
          <p>Are you sure you want to delete <strong>"{{ productToDelete?.name }}"</strong>?</p>
          <p class="warning">This action cannot be undone.</p>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="closeDeleteModal">Cancel</button>
            <button type="button" class="btn btn-danger" @click="deleteProduct" :disabled="deleting">
              {{ deleting ? 'Deleting...' : 'Delete Product' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Image Preview Modal -->
    <div v-if="imagePreview" class="modal-overlay" @click="imagePreview = ''">
      <div class="image-modal" @click.stop>
        <button class="modal-close image-modal-close" @click="imagePreview = ''">&times;</button>
        <img :src="imagePreview" alt="Preview" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Apply authentication middleware
definePageMeta({
  middleware: 'auth'
})

interface MellowProduct {
  id: number
  name: string
  qty: number | null
  price_buy_yuan: number | null
  price_buy_usd: number | null
  price_delivery_usd: number | null
  price_total_per_unit_usd: number | null
  price_sell_usd: number | null
  type_shop: string | null
  pic_cn_shop: string | null
  pic_bag: string | null
  created_at: string
}

// Reactive data
const products = ref<MellowProduct[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const saving = ref(false)
const deleting = ref(false)

// Modal states
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const productToEdit = ref<MellowProduct | null>(null)
const productToDelete = ref<MellowProduct | null>(null)
const imagePreview = ref('')

// Form data
const productForm = reactive({
  name: '',
  qty: 0,
  price_buy_yuan: 0,
  price_buy_usd: 0,
  price_delivery_usd: 0,
  price_total_per_unit_usd: 0,
  price_sell_usd: 0,
  type_shop: '',
  pic_cn_shop: '',
  pic_bag: ''
})

// Auto-calculate Price Total / Unit $ from Buy $ + Delivery $.
// Users can still override the value manually after this runs.
watch(
  () => [productForm.price_buy_usd, productForm.price_delivery_usd],
  ([buy, delivery]) => {
    productForm.price_total_per_unit_usd = Number(((buy || 0) + (delivery || 0)).toFixed(2))
  }
)

// ==============================================
// Live CNY -> USD exchange rate
// Free, no-key endpoint. We fetch once on mount and on manual refresh,
// then convert Price Buy ¥ -> Price Buy $ as the user types in the ¥ field.
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

// Recompute Price Buy $ from Price Buy ¥ using the live rate.
// Triggered on ¥ input; the existing total watch then updates the unit total.
const convertYuanToUsd = () => {
  if (cnyToUsdRate.value == null) return
  const yuan = productForm.price_buy_yuan || 0
  productForm.price_buy_usd = Number((yuan * cnyToUsdRate.value).toFixed(2))
}

// ==============================================
// Column ordering (drag-and-drop) — required by rules.md
// ==============================================
const availableColumns = [
  { key: 'index', label: '#' },
  { key: 'name', label: 'Name' },
  { key: 'qty', label: 'QTY' },
  { key: 'priceBuyYuan', label: 'Price Buy ¥' },
  { key: 'priceBuyUsd', label: 'Price Buy $' },
  { key: 'priceDeliveryUsd', label: 'Price Delivery $' },
  { key: 'priceTotalPerUnit', label: 'Price Total / Unit $' },
  { key: 'priceSellUsd', label: 'Price Sell $' },
  { key: 'typeShop', label: 'Type Shop' },
  { key: 'picCnShop', label: 'Pic CN Shop' },
  { key: 'picBag', label: 'Pic Bag' },
  { key: 'actions', label: 'Actions' }
]

const columnOrder = ref(availableColumns.map(c => c.key))

const draggedColumn = ref<string | null>(null)
const dragOverColumn = ref<string | null>(null)

const getColumnLabel = (columnKey: string) => {
  const column = availableColumns.find(col => col.key === columnKey)
  return column ? column.label : columnKey
}

const loadColumnOrder = () => {
  const saved = localStorage.getItem('mellowProductColumnOrder')
  if (saved) {
    try {
      const parsed = JSON.parse(saved) as string[]
      // Keep only known keys and append any new columns that didn't exist before
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
  localStorage.setItem('mellowProductColumnOrder', JSON.stringify(columnOrder.value))
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

// ==============================================
// Data operations
// ==============================================
const fetchProducts = async () => {
  try {
    loading.value = true
    error.value = null

    const { from } = useSupabaseDB()
    const { data, error: fetchError } = await from('mellow_products')
      .select('*')
      .order('id', { ascending: false })

    if (fetchError) throw fetchError

    products.value = (data as unknown as MellowProduct[]) || []
  } catch (err) {
    console.error('Error fetching products:', err)
    error.value = 'Failed to load products. Please check your Supabase connection.'
  } finally {
    loading.value = false
  }
}

const resetForm = () => {
  productForm.name = ''
  productForm.qty = 0
  productForm.price_buy_yuan = 0
  productForm.price_buy_usd = 0
  productForm.price_delivery_usd = 0
  productForm.price_total_per_unit_usd = 0
  productForm.price_sell_usd = 0
  productForm.type_shop = ''
  productForm.pic_cn_shop = ''
  productForm.pic_bag = ''
}

const openAddModal = () => {
  isEditing.value = false
  productToEdit.value = null
  resetForm()
  showModal.value = true
}

const openEditModal = (product: MellowProduct) => {
  isEditing.value = true
  productToEdit.value = product
  productForm.name = product.name
  productForm.qty = product.qty ?? 0
  productForm.price_buy_yuan = product.price_buy_yuan ?? 0
  productForm.price_buy_usd = product.price_buy_usd ?? 0
  productForm.price_delivery_usd = product.price_delivery_usd ?? 0
  productForm.price_total_per_unit_usd = product.price_total_per_unit_usd ?? 0
  productForm.price_sell_usd = product.price_sell_usd ?? 0
  productForm.type_shop = product.type_shop ?? ''
  productForm.pic_cn_shop = product.pic_cn_shop ?? ''
  productForm.pic_bag = product.pic_bag ?? ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

// Convert a selected image file into a data URL stored on the form
const onImageChange = (event: Event, field: 'pic_cn_shop' | 'pic_bag') => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = () => {
    productForm[field] = reader.result as string
  }
  reader.readAsDataURL(file)
}

const openImagePreview = (src: string | null) => {
  if (src) imagePreview.value = src
}

const saveProduct = async () => {
  try {
    saving.value = true

    if (!productForm.name.trim()) {
      alert('Please enter a product name')
      return
    }

    const payload = {
      name: productForm.name.trim(),
      qty: productForm.qty || 0,
      price_buy_yuan: productForm.price_buy_yuan || 0,
      price_buy_usd: productForm.price_buy_usd || 0,
      price_delivery_usd: productForm.price_delivery_usd || 0,
      price_total_per_unit_usd: productForm.price_total_per_unit_usd || 0,
      price_sell_usd: productForm.price_sell_usd || 0,
      type_shop: productForm.type_shop.trim() || null,
      pic_cn_shop: productForm.pic_cn_shop || null,
      pic_bag: productForm.pic_bag || null
    }

    const { insert, update } = useSupabaseDB()

    if (isEditing.value && productToEdit.value) {
      const { error: updateError } = await update('mellow_products', payload)
        .eq('id', productToEdit.value.id)
      if (updateError) throw updateError
    } else {
      const { error: insertError } = await insert('mellow_products', [payload])
      if (insertError) throw insertError
    }

    closeModal()
    await fetchProducts()
  } catch (err) {
    console.error('Error saving product:', err)
    alert('Failed to save product. Please try again.')
  } finally {
    saving.value = false
  }
}

const confirmDelete = (product: MellowProduct) => {
  productToDelete.value = product
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  productToDelete.value = null
}

const deleteProduct = async () => {
  try {
    deleting.value = true
    if (!productToDelete.value) return

    const { delete: deleteRecord } = useSupabaseDB()
    const { error: deleteError } = await deleteRecord('mellow_products')
      .eq('id', productToDelete.value.id)
    if (deleteError) throw deleteError

    closeDeleteModal()
    await fetchProducts()
  } catch (err) {
    console.error('Error deleting product:', err)
    alert('Failed to delete product. Please try again.')
  } finally {
    deleting.value = false
  }
}

// ==============================================
// Formatters
// ==============================================
const formatUsd = (value: number | null) => {
  return `$${Number(value || 0).toFixed(2)}`
}

const formatYuan = (value: number | null) => {
  return `¥${Number(value || 0).toFixed(2)}`
}

onMounted(() => {
  loadColumnOrder()
  fetchProducts()
  fetchExchangeRate()
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

.error-message h3 { color: #721c24; margin-bottom: 1rem; }
.error-message p { color: #721c24; margin-bottom: 1rem; }
.error-message ol { color: #721c24; margin: 1rem 0; padding-left: 1.5rem; }
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
}

.products-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 1100px;
}

.products-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
  border-bottom: 2px solid #dee2e6;
  white-space: nowrap;
}

.products-table td {
  padding: 1rem;
  border-bottom: 1px solid #dee2e6;
  color: #495057;
  white-space: nowrap;
}

.products-table tr:hover { background: #f8f9fa; }

.product-name { font-weight: 600; color: #2c3e50; }
.no-data { color: #adb5bd; }

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

/* Picture cells */
.pic-cell { display: flex; align-items: center; }

.pic-thumb {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #dee2e6;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.pic-thumb:hover { transform: scale(1.08); }

/* Action buttons */
.action-buttons { display: flex; gap: 0.5rem; }

.btn-sm {
  padding: 0.5rem;
  font-size: 0.9rem;
  min-width: auto;
}

.btn-edit { background-color: #ffc107; color: #212529; }
.btn-edit:hover { background-color: #e0a800; }
.btn-delete { background-color: #dc3545; color: white; }
.btn-delete:hover { background-color: #c82333; }
.btn-danger { background-color: #dc3545; color: white; }
.btn-danger:hover { background-color: #c82333; }

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin: 2rem 0;
}

.empty-state h3 { color: #2c3e50; margin-bottom: 1rem; }
.empty-state p { color: #7f8c8d; margin-bottom: 2rem; }

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
  max-width: 640px;
  max-height: 90vh;
  overflow-y: auto;
}

.delete-modal { max-width: 400px; }

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #dee2e6;
}

.modal-header h2 { margin: 0; color: #2c3e50; font-size: 1.5rem; }

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

.modal-close:hover { color: #e74c3c; }

.product-form { padding: 1.5rem; }
.delete-content { padding: 1.5rem; }
.delete-content p { margin-bottom: 1rem; color: #495057; }
.warning { color: #dc3545; font-weight: 600; }

.form-row {
  display: flex;
  gap: 1rem;
}

.form-row .form-group { flex: 1; }

.form-group { margin-bottom: 1.5rem; }

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #2c3e50;
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
  margin: -0.25rem 0 0.5rem;
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

.form-group input[type="text"],
.form-group input[type="number"] {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
  font-family: inherit;
}

.form-group input[type="file"] {
  width: 100%;
  font-size: 0.9rem;
}

.form-group input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.image-preview {
  margin-top: 0.75rem;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.5rem;
}

.image-preview img {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.remove-image {
  background: none;
  border: none;
  color: #dc3545;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 600;
  padding: 0;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

/* Image preview modal */
.image-modal {
  position: relative;
  background: white;
  border-radius: 12px;
  padding: 1rem;
  max-width: 90vw;
  max-height: 90vh;
}

.image-modal img {
  max-width: 80vw;
  max-height: 80vh;
  border-radius: 8px;
  display: block;
}

.image-modal-close {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 50%;
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

.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-primary { background-color: #3498db; color: white; }
.btn-primary:hover:not(:disabled) { background-color: #2980b9; transform: translateY(-2px); }
.btn-secondary { background-color: #95a5a6; color: white; }
.btn-secondary:hover { background-color: #7f8c8d; transform: translateY(-2px); }

/* Responsive design */
@media (max-width: 768px) {
  .page-container { padding: 1rem; }
  .page-header h1 { font-size: 2rem; }
  .action-bar { flex-direction: column; align-items: stretch; }
  .form-row { flex-direction: column; gap: 0; }
  .modal-content { width: 95%; margin: 1rem; }
  .form-actions { flex-direction: column; }
  .form-actions .btn { width: 100%; }
}
</style>
