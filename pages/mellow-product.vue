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
      <!-- Category Tabs -->
      <div class="category-tabs">
        <button
          v-for="cat in categoryTabs"
          :key="cat.value"
          class="category-tab"
          :class="{ active: cat.value === activeCategory }"
          @click="setActiveCategory(cat.value)"
        >
          <span class="cat-icon">{{ cat.icon }}</span>
          <span class="cat-label">{{ cat.label }}</span>
          <span class="cat-count">{{ cat.count }}</span>
        </button>
        <button class="category-tab add-category-tab" title="Add a new category" @click="addCategory">
          + Category
        </button>
      </div>

      <!-- Action Bar -->
      <div class="action-bar">
        <button class="btn btn-primary" @click="openAddModal">
          <span>+</span> Add New Product
        </button>
        <button class="btn btn-secondary" @click="fetchProducts">
          Refresh
        </button>
        <div class="search-box">
          <span class="search-icon">🔍</span>
          <input
            v-model="searchQuery"
            type="search"
            class="search-input"
            placeholder="Search by name…"
          />
          <button
            v-if="searchQuery"
            class="search-clear"
            title="Clear search"
            @click="searchQuery = ''"
          >&times;</button>
        </div>
      </div>

      <!-- Products Table -->
      <div v-if="sortedProducts.length > 0" class="products-section">
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
                    <span
                      v-if="columnKey === 'name'"
                      class="sort-indicator"
                      :class="{ active: nameSortDir }"
                      title="Sort by name"
                      @click.stop="toggleNameSort"
                    >{{ nameSortIcon }}</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(product, index) in paginatedProducts" :key="product.id">
                <td v-for="columnKey in columnOrder" :key="columnKey">
                  <!-- Index (global position across all pages) -->
                  <span v-if="columnKey === 'index'">{{ (currentPage - 1) * pageSize + index + 1 }}</span>

                  <!-- Name -->
                  <span v-else-if="columnKey === 'name'" class="product-name">{{ product.name }}</span>

                  <!-- QTY -->
                  <span v-else-if="columnKey === 'qty'">{{ product.qty ?? 0 }}</span>

                  <!-- Colors (QTY) -->
                  <div v-else-if="columnKey === 'colors'" class="color-tags">
                    <template v-if="product.colors && product.colors.length">
                      <span
                        v-for="(c, ci) in product.colors"
                        :key="ci"
                        class="color-tag"
                        :title="formatColorCount(c)"
                      >{{ c.color }}: {{ formatColorCount(c) }}</span>
                    </template>
                    <span v-else class="no-data">-</span>
                  </div>

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

                  <!-- Profit $ = Price Sell $ − Price Total / Unit $ -->
                  <span
                    v-else-if="columnKey === 'profit'"
                    class="profit-value"
                    :class="{ 'profit-negative': productProfit(product) < 0 }"
                  >{{ formatUsd(productProfit(product)) }}</span>

                  <!-- Type Shop -->
                  <span v-else-if="columnKey === 'typeShop'">{{ product.type_shop || '-' }}</span>

                  <!-- Pic CN Shop -->
                  <div v-else-if="columnKey === 'picCnShop'" class="pic-cell">
                    <img
                      v-if="product.pic_cn_shop"
                      :src="product.pic_cn_shop"
                      alt="CN Shop"
                      class="pic-thumb"
                      loading="lazy"
                      decoding="async"
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
                      loading="lazy"
                      decoding="async"
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

        <!-- Pagination Controls -->
        <div class="pagination">
          <div class="pagination-info">
            Showing {{ rangeStart }}–{{ rangeEnd }} of {{ sortedProducts.length }}
          </div>
          <div class="pagination-controls">
            <label class="page-size">
              Per page
              <select v-model.number="pageSize">
                <option v-for="size in pageSizeOptions" :key="size" :value="size">{{ size }}</option>
              </select>
            </label>
            <button class="btn btn-secondary btn-sm" :disabled="currentPage <= 1" @click="goToPage(currentPage - 1)">
              ‹ Prev
            </button>
            <span class="page-status">Page {{ currentPage }} / {{ totalPages }}</span>
            <button class="btn btn-secondary btn-sm" :disabled="currentPage >= totalPages" @click="goToPage(currentPage + 1)">
              Next ›
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="searchQuery.trim()" class="empty-state">
        <h3>No products match “{{ searchQuery.trim() }}”</h3>
        <p>Try a different name or clear the search.</p>
        <button class="btn btn-secondary" @click="searchQuery = ''">
          Clear Search
        </button>
      </div>
      <div v-else class="empty-state">
        <h3>No Products in {{ activeCategoryLabel }}</h3>
        <p>Add your first {{ activeCategoryLabel }} product to get started!</p>
        <button class="btn btn-primary" @click="openAddModal">
          Add Product
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
          <div class="form-row">
            <div class="form-group">
              <label for="name">Name *</label>
              <input id="name" v-model="productForm.name" type="text" placeholder="Enter product name" required />
            </div>
            <div class="form-group">
              <label for="category">Category *</label>
              <select id="category" v-model="productForm.category" class="category-select">
                <option v-for="cat in categoryTabs" :key="cat.value" :value="cat.value">
                  {{ cat.icon }} {{ cat.label }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="qty">
                QTY
                <span v-if="hasColors" class="hint">(auto = sum of colors)</span>
              </label>
              <input
                id="qty"
                v-model.number="productForm.qty"
                type="number"
                min="0"
                step="1"
                placeholder="0"
                :readonly="hasColors"
                :class="{ 'is-readonly': hasColors }"
              />
            </div>
            <div class="form-group">
              <label for="typeShop">Type Shop</label>
              <input id="typeShop" v-model="productForm.type_shop" type="text" placeholder="e.g. Taobao, 1688" />
            </div>
          </div>

          <!-- Per-color quantity breakdown -->
          <div class="form-group">
            <label>
              Colors &amp; Quantity
              <span class="hint">
                {{ formNeedsSizes
                  ? '(add a color, then a row per size to count stock)'
                  : '(add a row per color for multi-color products)' }}
              </span>
            </label>

            <!-- Sized layout (e.g. shoes): each color has its own size rows -->
            <div v-if="formNeedsSizes && productForm.colors.length" class="color-cards">
              <div v-for="(c, index) in productForm.colors" :key="index" class="color-card">
                <div class="color-card-header">
                  <input
                    v-model="c.color"
                    type="text"
                    class="color-name-input"
                    placeholder="Color (e.g. Black)"
                  />
                  <span class="color-subtotal">Qty: {{ colorQty(c) }}</span>
                  <button type="button" class="color-remove" title="Remove color" @click="removeColor(index)">&times;</button>
                </div>

                <div class="size-list">
                  <div v-for="(s, si) in (c.sizes || [])" :key="si" class="size-row">
                    <input
                      v-model="s.size"
                      type="text"
                      class="size-name-input"
                      placeholder="Size (e.g. 40)"
                    />
                    <input
                      v-model.number="s.qty"
                      type="number"
                      min="0"
                      step="1"
                      class="size-qty-input"
                      placeholder="QTY"
                    />
                    <button type="button" class="size-remove" title="Remove size" @click="removeSize(c, si)">&times;</button>
                  </div>
                  <button type="button" class="btn btn-secondary btn-sm add-size-btn" @click="addSize(c)">
                    + Add Size
                  </button>
                </div>
              </div>
              <div class="color-total">Total QTY: <strong>{{ colorsTotalQty }}</strong></div>
            </div>

            <!-- Simple layout (bags etc.): color + quantity -->
            <div v-else-if="productForm.colors.length" class="color-rows">
              <div v-for="(c, index) in productForm.colors" :key="index" class="color-row">
                <input
                  v-model="c.color"
                  type="text"
                  class="color-name-input"
                  placeholder="Color (e.g. Red)"
                />
                <input
                  v-model.number="c.qty"
                  type="number"
                  min="0"
                  step="1"
                  class="color-qty-input"
                  placeholder="QTY"
                />
                <button type="button" class="color-remove" title="Remove color" @click="removeColor(index)">&times;</button>
              </div>
              <div class="color-total">Total QTY: <strong>{{ colorsTotalQty }}</strong></div>
            </div>

            <button type="button" class="btn btn-secondary btn-sm add-color-btn" @click="addColor">
              + Add Color
            </button>
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

interface ProductSize {
  size: string
  qty: number
}

interface ProductColor {
  color: string
  qty: number
  // Per-size stock breakdown — used for sized categories (e.g. shoes).
  // When present, the color's qty is the sum of its sizes.
  sizes?: ProductSize[]
}

interface MellowProduct {
  id: number
  name: string
  category: string | null
  qty: number | null
  colors: ProductColor[] | null
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
  category: 'bag',
  qty: 0,
  colors: [] as ProductColor[],
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
// Per-color quantity (with optional per-size breakdown)
// A product can have one or many colors, each with its own QTY. For sized
// categories (e.g. shoes) each color is broken down by size, and the color's
// QTY is the sum of its sizes. When any color rows exist, the top-level QTY is
// the sum of all colors (the QTY field becomes read-only). With no color rows,
// QTY is entered manually so simple single-stock products still work.
// ==============================================

// Categories whose products are counted per size (color + size + qty).
const sizedCategories = ['shoes']
const formNeedsSizes = computed(() => sizedCategories.includes(productForm.category))

// Effective quantity of a single color: sum of its sizes when sized, else qty.
const colorQty = (c: ProductColor) => {
  if (c.sizes && c.sizes.length) {
    return c.sizes.reduce((sum, s) => sum + (Number(s.qty) || 0), 0)
  }
  return Number(c.qty) || 0
}

const colorsTotalQty = computed(() =>
  productForm.colors.reduce((sum, c) => sum + colorQty(c), 0)
)

// A color row only "counts" once it has a name or a quantity. Empty placeholder
// rows are ignored, so they don't lock the manual QTY field.
const meaningfulColors = computed(() =>
  productForm.colors.filter(c => (c.color && c.color.trim() !== '') || colorQty(c) > 0)
)

const hasColors = computed(() => meaningfulColors.value.length > 0)

const addSize = (c: ProductColor) => {
  if (!c.sizes) c.sizes = []
  c.sizes.push({ size: '', qty: 0 })
}

const removeSize = (c: ProductColor, index: number) => {
  c.sizes?.splice(index, 1)
}

const addColor = () => {
  const row: ProductColor = { color: '', qty: 0 }
  if (formNeedsSizes.value) row.sizes = [{ size: '', qty: 0 }]
  productForm.colors.push(row)
}

const removeColor = (index: number) => {
  productForm.colors.splice(index, 1)
}

// When the form switches to a sized category, make sure every color has at
// least one size row so the size fields are visible and editable right away.
watch(formNeedsSizes, (needs) => {
  if (!needs) return
  productForm.colors.forEach(c => {
    if (!c.sizes || c.sizes.length === 0) c.sizes = [{ size: '', qty: 0 }]
  })
})

// Keep the top-level QTY in sync with the per-color breakdown whenever colors
// are present. Editing color/size quantities then drives the displayed total.
watch([colorsTotalQty, hasColors], ([total, has]) => {
  if (has) productForm.qty = total
})

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
// Categories (tab switcher)
// Products are grouped by `category` (e.g. bag, shoes). The active tab filters
// the list. New products default to the active category. Custom categories the
// user adds are persisted to localStorage so they survive reloads, and any
// category already present in the data is shown even if not in the base list.
// ==============================================
const baseCategories = [
  { value: 'bag', label: 'Bag', icon: '👜' },
  { value: 'shoes', label: 'Shoes', icon: '👟' }
]

const activeCategory = ref('bag')
const customCategories = ref<string[]>([])

// Title-case a raw category key for display, e.g. "hand-bag" -> "Hand-bag"
const formatCategoryLabel = (value: string) =>
  value.charAt(0).toUpperCase() + value.slice(1)

// All category tabs with live product counts. Base categories always show
// (even at 0); custom + data-derived categories are appended.
const categoryTabs = computed(() => {
  const counts: Record<string, number> = {}
  for (const p of products.value) {
    const key = p.category || 'bag'
    counts[key] = (counts[key] || 0) + 1
  }

  const known = baseCategories.map(c => c.value)
  const extraKeys = [
    ...customCategories.value,
    ...Object.keys(counts)
  ].filter((k, i, arr) => !known.includes(k) && arr.indexOf(k) === i)

  const extras = extraKeys.map(k => ({ value: k, label: formatCategoryLabel(k), icon: '🏷️' }))

  return [...baseCategories, ...extras].map(c => ({ ...c, count: counts[c.value] || 0 }))
})

const activeCategoryLabel = computed(() => {
  const tab = categoryTabs.value.find(c => c.value === activeCategory.value)
  return tab ? tab.label : formatCategoryLabel(activeCategory.value)
})

const setActiveCategory = (value: string) => {
  activeCategory.value = value
  localStorage.setItem('mellowProductActiveCategory', value)
}

const addCategory = () => {
  const raw = window.prompt('New category name (e.g. Shoes, Hat):')
  if (!raw) return
  const value = raw.trim().toLowerCase()
  if (!value) return

  const exists = categoryTabs.value.some(c => c.value === value)
  if (!exists) {
    customCategories.value.push(value)
    localStorage.setItem('mellowProductCustomCategories', JSON.stringify(customCategories.value))
  }
  setActiveCategory(value)
}

const loadCategoryState = () => {
  const savedActive = localStorage.getItem('mellowProductActiveCategory')
  if (savedActive) activeCategory.value = savedActive

  const savedCustom = localStorage.getItem('mellowProductCustomCategories')
  if (savedCustom) {
    try {
      const parsed = JSON.parse(savedCustom)
      if (Array.isArray(parsed)) customCategories.value = parsed.filter(c => typeof c === 'string')
    } catch (e) {
      console.warn('Failed to load custom categories:', e)
    }
  }
}

// Free-text search by product name (case-insensitive).
const searchQuery = ref('')

// Products in the currently selected category, narrowed by the name search.
// Feeds the sort/paginate chain.
const visibleProducts = computed(() => {
  const q = searchQuery.value.trim().toLowerCase()
  return products.value.filter(p => {
    if ((p.category || 'bag') !== activeCategory.value) return false
    if (q && !(p.name || '').toLowerCase().includes(q)) return false
    return true
  })
})

// ==============================================
// Column ordering (drag-and-drop) — required by rules.md
// ==============================================
const availableColumns = [
  { key: 'actions', label: 'Actions' },
  { key: 'picCnShop', label: 'Pic CN Shop' },
  { key: 'picBag', label: 'Pic Bag' },
  { key: 'index', label: '#' },
  { key: 'name', label: 'Name' },
  { key: 'qty', label: 'QTY' },
  { key: 'colors', label: 'Colors (QTY)' },
  { key: 'priceBuyYuan', label: 'Price Buy ¥' },
  { key: 'priceBuyUsd', label: 'Price Buy $' },
  { key: 'priceDeliveryUsd', label: 'Price Delivery $' },
  { key: 'priceTotalPerUnit', label: 'Price Total / Unit $' },
  { key: 'priceSellUsd', label: 'Price Sell $' },
  { key: 'profit', label: 'Profit $' },
  { key: 'typeShop', label: 'Type Shop' }
]

const columnOrder = ref(availableColumns.map(c => c.key))

const draggedColumn = ref<string | null>(null)
const dragOverColumn = ref<string | null>(null)

// ==============================================
// Sort by Name (asc / desc / none)
// Clicking the indicator cycles: none -> asc -> desc -> none
// ==============================================
const nameSortDir = ref<'asc' | 'desc' | null>('asc')

const nameSortIcon = computed(() =>
  nameSortDir.value === 'asc' ? '▲' : nameSortDir.value === 'desc' ? '▼' : '⇅'
)

const toggleNameSort = () => {
  nameSortDir.value =
    nameSortDir.value === 'asc' ? 'desc' : nameSortDir.value === 'desc' ? null : 'asc'
}

// Sorted view of products used by the table. When no sort is active the
// original fetch order (id desc) is preserved. Numeric-aware compare so
// B003 < B050 (and B2 < B10) order correctly.
const sortedProducts = computed(() => {
  if (!nameSortDir.value) return visibleProducts.value
  return [...visibleProducts.value].sort((a, b) => {
    const cmp = (a.name || '').localeCompare(b.name || '', undefined, {
      numeric: true,
      sensitivity: 'base'
    })
    return nameSortDir.value === 'asc' ? cmp : -cmp
  })
})

// ==============================================
// Pagination (client-side over the sorted list)
// ==============================================
const pageSizeOptions = [10, 20, 50, 100]
const pageSize = ref(20)
const currentPage = ref(1)

const totalPages = computed(() =>
  Math.max(1, Math.ceil(sortedProducts.value.length / pageSize.value))
)

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return sortedProducts.value.slice(start, start + pageSize.value)
})

// 1-based display range of the current page, e.g. "21–40 of 48"
const rangeStart = computed(() =>
  sortedProducts.value.length === 0 ? 0 : (currentPage.value - 1) * pageSize.value + 1
)
const rangeEnd = computed(() =>
  Math.min(currentPage.value * pageSize.value, sortedProducts.value.length)
)

const goToPage = (page: number) => {
  currentPage.value = Math.min(Math.max(1, page), totalPages.value)
}

// Keep the current page valid when the underlying list shrinks (delete) or
// the page size grows. Clamping here covers fetch, sort and page-size changes.
watch(totalPages, (max) => {
  if (currentPage.value > max) currentPage.value = max
})

// Resetting to the first page on sort/page-size/category change keeps the view predictable.
watch([nameSortDir, pageSize, activeCategory, searchQuery], () => {
  currentPage.value = 1
})

// ==============================================
// Lazy image loading
// The list query omits the large base64 image columns. Here we fetch the
// images only for the rows currently on screen, so paging is fast and the
// initial load stays small. Loaded ids are tracked so we never refetch.
// ==============================================
const loadedImageIds = ref(new Set<number>())

const fetchImagesForIds = async (ids: number[]) => {
  const missing = ids.filter(id => !loadedImageIds.value.has(id))
  if (missing.length === 0) return
  // Mark as loaded up front so concurrent page changes don't double-fetch.
  missing.forEach(id => loadedImageIds.value.add(id))
  try {
    const { from } = useSupabaseDB()
    const { data, error: imgError } = await from('mellow_products')
      .select('id, pic_cn_shop, pic_bag')
      .in('id', missing)
    if (imgError) throw imgError
    for (const row of (data as unknown as Array<{ id: number, pic_cn_shop: string | null, pic_bag: string | null }>) || []) {
      const prod = products.value.find(p => p.id === row.id)
      if (prod) {
        prod.pic_cn_shop = row.pic_cn_shop ?? null
        prod.pic_bag = row.pic_bag ?? null
      }
    }
  } catch (err) {
    console.error('Error loading product images:', err)
    // Allow a retry on the next trigger if the fetch failed.
    missing.forEach(id => loadedImageIds.value.delete(id))
  }
}

// Load thumbnails whenever the visible page changes (fetch, sort, paging, filter).
watch(paginatedProducts, (rows) => {
  fetchImagesForIds(rows.map(p => p.id))
}, { immediate: true })

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
    // Skip the heavy base64 image columns (pic_cn_shop, pic_bag) here — they make
    // the payload huge. Thumbnails are loaded lazily per visible page instead.
    const { data, error: fetchError } = await from('mellow_products')
      .select('id, name, category, qty, colors, price_buy_yuan, price_buy_usd, price_delivery_usd, price_total_per_unit_usd, price_sell_usd, type_shop, created_at')
      .order('id', { ascending: false })

    if (fetchError) throw fetchError

    // Reset the lazy-image cache so freshly fetched rows reload their thumbnails.
    loadedImageIds.value = new Set()
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
  productForm.category = activeCategory.value
  productForm.qty = 0
  productForm.colors = []
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
  // Show one blank color row so the color-name field is visible right away.
  // It's ignored on save unless filled in.
  addColor()
  showModal.value = true
}

const openEditModal = async (product: MellowProduct) => {
  isEditing.value = true
  productToEdit.value = product
  // Images are lazy-loaded; make sure this product's images are present before
  // populating the form, otherwise saving would overwrite them with blanks.
  await fetchImagesForIds([product.id])
  productForm.name = product.name
  productForm.category = product.category || 'bag'
  productForm.qty = product.qty ?? 0
  // Clone so editing the form doesn't mutate the table row before saving.
  // Preserve any per-size breakdown so sized products (shoes) round-trip.
  productForm.colors = Array.isArray(product.colors)
    ? product.colors.map(c => {
        const row: ProductColor = { color: c.color ?? '', qty: Number(c.qty) || 0 }
        if (Array.isArray(c.sizes)) {
          row.sizes = c.sizes.map(s => ({ size: String(s.size ?? ''), qty: Number(s.qty) || 0 }))
        }
        return row
      })
    : []
  // Show a blank row so the color field is visible for products without colors yet
  if (productForm.colors.length === 0) addColor()
  // For sized categories, make sure each color has at least one size row to edit
  if (formNeedsSizes.value) {
    productForm.colors.forEach(c => {
      if (!c.sizes || c.sizes.length === 0) c.sizes = [{ size: '', qty: 0 }]
    })
  }
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

    // Drop blank color rows, then derive the total QTY from the breakdown when
    // colors are present (otherwise keep the manually entered QTY).
    const cleanColors = productForm.colors
      .map(c => {
        const name = c.color.trim()
        if (formNeedsSizes.value) {
          // Sized category (shoes): keep the per-size breakdown; the color's
          // qty is the sum of its sizes. Drop fully-empty size rows.
          const sizes = (c.sizes || [])
            .map(s => ({ size: String(s.size).trim(), qty: Number(s.qty) || 0 }))
            .filter(s => s.size !== '' || s.qty > 0)
          const qty = sizes.reduce((sum, s) => sum + s.qty, 0)
          return { color: name, qty, sizes }
        }
        return { color: name, qty: Number(c.qty) || 0 }
      })
      .filter(c => c.color !== '' || c.qty > 0 || ((c as any).sizes?.length > 0))

    if (cleanColors.some(c => c.color === '')) {
      alert('Please enter a name for each color (or remove the empty rows)')
      return
    }

    if (formNeedsSizes.value && cleanColors.some(c => (c as any).sizes?.some((s: ProductSize) => s.size === ''))) {
      alert('Please enter a size label for each size row (or remove the empty rows)')
      return
    }

    const totalQty = cleanColors.length > 0
      ? cleanColors.reduce((sum, c) => sum + c.qty, 0)
      : (productForm.qty || 0)

    const payload = {
      name: productForm.name.trim(),
      category: productForm.category || 'bag',
      qty: totalQty,
      colors: cleanColors,
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
  } catch (err: any) {
    console.error('Error saving product:', err)
    // Surface the real cause. A missing DB column (PostgREST PGRST204) usually
    // means a pending migration hasn't been applied to Supabase yet.
    const message = err?.message || ''
    if (err?.code === 'PGRST204' || /could not find the .* column/i.test(message)) {
      const col = message.match(/'([^']+)' column/)?.[1]
      alert(
        `Database is missing the "${col || 'required'}" column.\n\n` +
        'Run the latest migrations in the Supabase SQL editor:\n' +
        '• database/migrations/07-add-mellow-product-colors.sql\n' +
        '• database/migrations/08-add-mellow-product-category.sql'
      )
    } else {
      alert(`Failed to save product.\n\n${message || 'Please try again.'}`)
    }
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

// Profit per unit = Price Sell $ − Price Total / Unit $
const productProfit = (product: MellowProduct) =>
  Number(product.price_sell_usd || 0) - Number(product.price_total_per_unit_usd || 0)

// Table display for a color cell: per-size breakdown when present
// (e.g. "40×2, 41×3"), otherwise just the color total qty.
const formatColorCount = (c: ProductColor) => {
  if (c.sizes && c.sizes.length) {
    return c.sizes
      .filter(s => s.size || s.qty)
      .map(s => `${s.size || '?'}×${s.qty || 0}`)
      .join(', ')
  }
  return String(c.qty ?? 0)
}

onMounted(() => {
  loadCategoryState()
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
  justify-content: flex-start;
  align-items: center;
  flex-wrap: wrap;
}

.action-bar .btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Search box (pushed to the right) */
.search-box {
  position: relative;
  margin-left: auto;
  display: flex;
  align-items: center;
  min-width: 240px;
}

.search-box .search-icon {
  position: absolute;
  left: 0.7rem;
  font-size: 0.9rem;
  pointer-events: none;
  opacity: 0.6;
}

.search-input {
  width: 100%;
  padding: 0.6rem 2rem 0.6rem 2.1rem;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  font-size: 0.95rem;
  transition: border-color 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #3498db;
}

.search-clear {
  position: absolute;
  right: 0.5rem;
  border: none;
  background: none;
  font-size: 1.3rem;
  line-height: 1;
  cursor: pointer;
  color: #7f8c8d;
}

.search-clear:hover { color: #e74c3c; }

@media (max-width: 600px) {
  .search-box { margin-left: 0; width: 100%; }
}

/* Category Tabs */
.category-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 0.75rem;
}

.category-tab {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.55rem 1.1rem;
  border: 2px solid #dee2e6;
  background: #fff;
  border-radius: 999px;
  font-size: 0.95rem;
  font-weight: 600;
  color: #5a6c7d;
  cursor: pointer;
  transition: all 0.2s ease;
}

.category-tab:hover { border-color: #3498db; color: #2c3e50; }

.category-tab.active {
  background: #3498db;
  border-color: #3498db;
  color: #fff;
}

.category-tab .cat-icon { font-size: 1.1rem; line-height: 1; }

.category-tab .cat-count {
  background: rgba(0, 0, 0, 0.08);
  color: inherit;
  border-radius: 999px;
  padding: 0.05rem 0.5rem;
  font-size: 0.8rem;
  min-width: 1.5rem;
  text-align: center;
}

.category-tab.active .cat-count { background: rgba(255, 255, 255, 0.25); }

.add-category-tab {
  color: #3498db;
  border-style: dashed;
}

.add-category-tab:hover { background: #eef6fc; }

.category-select {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  background: #fff;
  cursor: pointer;
  transition: border-color 0.3s ease;
}

.category-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
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
  overflow-y: auto;
  max-height: 70vh;
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
  /* Sticky header — stays visible while scrolling (rules.md) */
  position: sticky;
  top: 0;
  z-index: 20;
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
.profit-value { font-weight: 600; color: #1e7e34; }
.profit-value.profit-negative { color: #dc3545; }

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

/* Name sort indicator */
.sort-indicator {
  cursor: pointer;
  font-size: 0.8rem;
  color: #adb5bd;
  user-select: none;
  padding: 0 0.15rem;
  transition: color 0.2s ease;
}

.sort-indicator:hover { color: #2c3e50; }
.sort-indicator.active { color: #3498db; }

/* Picture cells */
.pic-cell { display: flex; align-items: center; }

.pic-thumb {
  width: 80px;
  height: 80px;
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

/* Pagination */
.pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 1rem;
  padding: 0.75rem 0.25rem;
}

.pagination-info {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.page-size {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.9rem;
  color: #5a6c7d;
}

.page-size select {
  padding: 0.35rem 0.5rem;
  border: 2px solid #dee2e6;
  border-radius: 6px;
  font-size: 0.9rem;
  font-family: inherit;
  cursor: pointer;
}

.page-status {
  font-size: 0.9rem;
  color: #2c3e50;
  min-width: 90px;
  text-align: center;
}

.pagination .btn-sm {
  padding: 0.4rem 0.9rem;
  font-size: 0.9rem;
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

.form-group input.is-readonly {
  background: #f1f3f5;
  color: #6c757d;
  cursor: not-allowed;
}

/* Per-color quantity editor (form) */
.color-rows {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.color-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Use input.<class> so these beat the page's global
   `.form-group input[type="text"] { width: 100% }` rule, which would
   otherwise squash the color name field to an unusable sliver. */
.color-row input.color-name-input {
  flex: 1 1 auto;
  width: auto;
  min-width: 0;
}

.color-row input.color-qty-input {
  flex: 0 0 5.5rem;
  width: 5.5rem;
}

.color-row input[type="text"],
.color-row input[type="number"] {
  padding: 0.5rem 0.6rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
}

.color-row input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.color-remove {
  border: none;
  background: #f8d7da;
  color: #c82333;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  font-size: 1.2rem;
  line-height: 1;
  cursor: pointer;
  flex-shrink: 0;
}

.color-remove:hover { background: #f5c2c7; }

.color-total {
  font-size: 0.9rem;
  color: #2c3e50;
}

.add-color-btn {
  padding: 0.4rem 0.9rem;
  font-size: 0.9rem;
}

/* Sized layout (shoes): color card with per-size rows */
.color-cards {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.color-card {
  border: 2px solid #e9ecef;
  border-radius: 10px;
  padding: 0.75rem;
  background: #fbfcfd;
}

.color-card-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.6rem;
}

.color-card-header .color-name-input { flex: 1 1 auto; width: auto; min-width: 0; }

.color-subtotal {
  font-size: 0.85rem;
  font-weight: 600;
  color: #2c3e50;
  white-space: nowrap;
}

.color-card-header input[type="text"] {
  padding: 0.5rem 0.6rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
}

.size-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  padding-left: 0.75rem;
  border-left: 3px solid #e9ecef;
}

.size-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.size-row input.size-name-input { flex: 1 1 auto; width: auto; min-width: 0; }
.size-row input.size-qty-input { flex: 0 0 5rem; width: 5rem; }

.size-row input[type="text"],
.size-row input[type="number"] {
  padding: 0.4rem 0.55rem;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  font-size: 0.9rem;
  font-family: inherit;
}

.size-row input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.size-remove {
  border: none;
  background: #f1f3f5;
  color: #868e96;
  width: 28px;
  height: 28px;
  border-radius: 8px;
  font-size: 1.1rem;
  line-height: 1;
  cursor: pointer;
  flex-shrink: 0;
}

.size-remove:hover { background: #e9ecef; color: #495057; }

.add-size-btn {
  align-self: flex-start;
  padding: 0.3rem 0.75rem;
  font-size: 0.85rem;
}

/* Per-color tags (table) */
.color-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  max-width: 240px;
  white-space: normal;
}

.color-tag {
  background: #eef2f7;
  color: #2c3e50;
  border: 1px solid #dde3ea;
  border-radius: 12px;
  padding: 0.15rem 0.6rem;
  font-size: 0.8rem;
  white-space: nowrap;
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
