<template>
  <div class="catalog">
    <!-- NOTE: This page intentionally has NO auth middleware — it is public.
         Anyone with the link can view it. It is read-only (no add/edit/delete). -->
    <header class="catalog-header">
      <h1>Mellow Product Catalog</h1>
      <p>Product list — view only</p>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="state-box">
      <div class="spinner"></div>
      <p>Loading products…</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="state-box">
      <h3>⚠️ Unable to load</h3>
      <p>{{ error }}</p>
      <button class="btn" @click="fetchProducts">Retry</button>
    </div>

    <div v-else>
      <!-- Category tabs (view-only filter, no add) -->
      <div class="category-tabs">
        <button
          v-for="cat in categoryTabs"
          :key="cat.value"
          class="category-tab"
          :class="{ active: cat.value === activeCategory }"
          @click="activeCategory = cat.value"
        >
          <span class="cat-icon">{{ cat.icon }}</span>
          {{ cat.label }}
          <span class="cat-count">{{ cat.count }}</span>
        </button>
      </div>

      <!-- Search -->
      <div class="toolbar">
        <input
          v-model="search"
          type="search"
          class="search-input"
          placeholder="Search by name…"
        />
        <span class="result-count">{{ filteredProducts.length }} item(s)</span>
      </div>

      <!-- Table -->
      <div v-if="filteredProducts.length > 0" class="table-wrap">
        <table class="catalog-table">
          <thead>
            <tr>
              <th class="col-index">#</th>
              <th class="col-name">Name</th>
              <th class="col-pic">Pic</th>
              <th class="col-price">Price Sell $</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(product, index) in paginatedProducts" :key="product.id">
              <td class="col-index">{{ (currentPage - 1) * pageSize + index + 1 }}</td>
              <td class="col-name">{{ product.name }}</td>
              <td class="col-pic">
                <img
                  v-if="product.pic_bag"
                  :src="product.pic_bag"
                  alt="Product"
                  class="pic-thumb"
                  loading="lazy"
                  decoding="async"
                  @click="preview = product.pic_bag"
                />
                <span v-else class="no-data">—</span>
              </td>
              <td class="col-price">{{ formatUsd(product.price_sell_usd) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-else class="state-box">
        <p>No products to show.</p>
      </div>

      <!-- Pagination -->
      <div v-if="filteredProducts.length > 0" class="pagination">
        <button class="btn" :disabled="currentPage <= 1" @click="currentPage--">‹ Prev</button>
        <span class="page-status">Page {{ currentPage }} / {{ totalPages }}</span>
        <button class="btn" :disabled="currentPage >= totalPages" @click="currentPage++">Next ›</button>
      </div>
    </div>

    <!-- Image lightbox -->
    <div v-if="preview" class="lightbox" @click="preview = null">
      <img :src="preview" alt="Preview" @click.stop />
      <button class="lightbox-close" @click="preview = null">&times;</button>
    </div>
  </div>
</template>

<script setup lang="ts">
// Public, read-only catalog of mellow products.
// No `definePageMeta({ middleware: 'auth' })` here on purpose, so the route is
// accessible without logging in.

interface CatalogProduct {
  id: number
  name: string
  category: string | null
  price_sell_usd: number | null
  pic_bag?: string | null
}

const products = ref<CatalogProduct[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const activeCategory = ref('bag')
const search = ref('')
const preview = ref<string | null>(null)

const formatUsd = (value: number | null | undefined) => `$${Number(value || 0).toFixed(2)}`

// ---- Fetch (without the heavy base64 image column) ----
const loadedImageIds = ref(new Set<number>())

const fetchProducts = async () => {
  try {
    loading.value = true
    error.value = null

    const { from } = useSupabaseDB()
    const { data, error: fetchError } = await from('mellow_products')
      .select('id, name, category, price_sell_usd')
      .order('name', { ascending: true })

    if (fetchError) throw fetchError

    loadedImageIds.value = new Set()
    products.value = (data as unknown as CatalogProduct[]) || []
  } catch (err) {
    console.error('Error loading catalog:', err)
    error.value = 'Failed to load products. Please try again later.'
  } finally {
    loading.value = false
  }
}

// ---- Lazy-load the Pic (Bag) images for only the rows on screen ----
const fetchImagesForIds = async (ids: number[]) => {
  const missing = ids.filter(id => !loadedImageIds.value.has(id))
  if (missing.length === 0) return
  missing.forEach(id => loadedImageIds.value.add(id))
  try {
    const { from } = useSupabaseDB()
    const { data, error: imgError } = await from('mellow_products')
      .select('id, pic_bag')
      .in('id', missing)
    if (imgError) throw imgError
    for (const row of (data as unknown as Array<{ id: number, pic_bag: string | null }>) || []) {
      const prod = products.value.find(p => p.id === row.id)
      if (prod) prod.pic_bag = row.pic_bag ?? null
    }
  } catch (err) {
    console.error('Error loading catalog images:', err)
    missing.forEach(id => loadedImageIds.value.delete(id))
  }
}

// ---- Category tabs (derived from data; bag/shoes always shown) ----
const baseCategories = [
  { value: 'bag', label: 'Bag', icon: '👜' },
  { value: 'shoes', label: 'Shoes', icon: '👟' }
]

const formatCategoryLabel = (value: string) =>
  value.charAt(0).toUpperCase() + value.slice(1)

const categoryTabs = computed(() => {
  const counts: Record<string, number> = {}
  for (const p of products.value) {
    const key = p.category || 'bag'
    counts[key] = (counts[key] || 0) + 1
  }
  const known = baseCategories.map(c => c.value)
  const extraKeys = Object.keys(counts).filter(k => !known.includes(k))
  const extras = extraKeys.map(k => ({ value: k, label: formatCategoryLabel(k), icon: '🏷️' }))
  return [...baseCategories, ...extras].map(c => ({ ...c, count: counts[c.value] || 0 }))
})

// ---- Filtering ----
const filteredProducts = computed(() => {
  const q = search.value.trim().toLowerCase()
  return products.value.filter(p => {
    if ((p.category || 'bag') !== activeCategory.value) return false
    if (q && !p.name.toLowerCase().includes(q)) return false
    return true
  })
})

// ---- Pagination ----
const pageSize = 100
const currentPage = ref(1)
const totalPages = computed(() => Math.max(1, Math.ceil(filteredProducts.value.length / pageSize)))
const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredProducts.value.slice(start, start + pageSize)
})

// Reset to page 1 when the filter changes, and keep the page in range.
watch([activeCategory, search], () => { currentPage.value = 1 })
watch(totalPages, (max) => { if (currentPage.value > max) currentPage.value = max })

// Load thumbnails for the current page whenever it changes.
watch(paginatedProducts, (rows) => {
  fetchImagesForIds(rows.map(p => p.id))
}, { immediate: true })

// Default to the first category that actually has products.
watch(categoryTabs, (tabs) => {
  if (!tabs.some(t => t.value === activeCategory.value && t.count > 0)) {
    const firstWithItems = tabs.find(t => t.count > 0)
    if (firstWithItems) activeCategory.value = firstWithItems.value
  }
}, { once: true })

onMounted(fetchProducts)
</script>

<style scoped>
.catalog {
  max-width: 960px;
  margin: 0 auto;
  padding: 2rem 1.25rem 4rem;
}

.catalog-header {
  text-align: center;
  margin-bottom: 2rem;
}

.catalog-header h1 {
  color: #2c3e50;
  font-size: 2rem;
  margin-bottom: 0.25rem;
}

.catalog-header p {
  color: #7f8c8d;
}

/* States */
.state-box {
  text-align: center;
  padding: 3rem 1rem;
  color: #6c757d;
}

.spinner {
  width: 36px;
  height: 36px;
  border: 4px solid #e9ecef;
  border-top-color: #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin { to { transform: rotate(360deg); } }

/* Category tabs */
.category-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: center;
  margin-bottom: 1.25rem;
}

.category-tab {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.5rem 1rem;
  border: 1px solid #dee2e6;
  background: #fff;
  border-radius: 999px;
  cursor: pointer;
  font-size: 0.9rem;
  color: #495057;
  transition: all 0.2s;
}

.category-tab:hover { border-color: #adb5bd; }

.category-tab.active {
  background: #3498db;
  border-color: #3498db;
  color: #fff;
}

.cat-count {
  font-size: 0.75rem;
  background: rgba(0, 0, 0, 0.08);
  border-radius: 999px;
  padding: 0.05rem 0.45rem;
}

.category-tab.active .cat-count { background: rgba(255, 255, 255, 0.25); }

/* Toolbar */
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
}

.search-input {
  flex: 1;
  max-width: 360px;
  padding: 0.6rem 0.85rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 0.95rem;
}

.search-input:focus { outline: none; border-color: #3498db; }

.result-count { color: #6c757d; font-size: 0.9rem; white-space: nowrap; }

/* Table */
.table-wrap {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.catalog-table {
  width: 100%;
  border-collapse: collapse;
}

.catalog-table th {
  background: #f8f9fa;
  color: #2c3e50;
  font-weight: 600;
  text-align: left;
  padding: 0.85rem 1rem;
  border-bottom: 2px solid #e9ecef;
}

.catalog-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #f1f3f5;
  color: #495057;
  vertical-align: middle;
}

.catalog-table tr:last-child td { border-bottom: none; }
.catalog-table tbody tr:hover { background: #fbfcfd; }

.col-index { width: 48px; color: #adb5bd; }
.col-pic { width: 180px; }
.col-price { width: 130px; font-weight: 600; color: #1e7e34; white-space: nowrap; }
.col-name { font-weight: 500; color: #2c3e50; }

.pic-thumb {
  width: 160px;
  height: 160px;
  object-fit: cover;
  border-radius: 10px;
  border: 1px solid #e9ecef;
  cursor: zoom-in;
  background: #f8f9fa;
}

.no-data { color: #ced4da; }

/* Pagination */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-top: 1.5rem;
}

.page-status { color: #6c757d; font-size: 0.9rem; }

.btn {
  padding: 0.5rem 1rem;
  border: 1px solid #dee2e6;
  background: #fff;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  color: #495057;
}

.btn:hover:not(:disabled) { background: #f1f3f5; }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }

/* Lightbox */
.lightbox {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 2rem;
}

.lightbox img {
  max-width: 90vw;
  max-height: 90vh;
  border-radius: 8px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
}

.lightbox-close {
  position: absolute;
  top: 1rem;
  right: 1.5rem;
  background: none;
  border: none;
  color: #fff;
  font-size: 2.5rem;
  cursor: pointer;
  line-height: 1;
}

@media (max-width: 600px) {
  .catalog { padding: 1rem 0.75rem 3rem; }

  .toolbar { flex-direction: column; align-items: stretch; }
  .search-input { max-width: none; }

  /* Turn the table into a responsive card grid so nothing is cut off. */
  .table-wrap {
    background: transparent;
    box-shadow: none;
    border-radius: 0;
    overflow: visible;
  }

  .catalog-table thead { display: none; }

  .catalog-table,
  .catalog-table tbody,
  .catalog-table tr,
  .catalog-table td { display: block; }

  .catalog-table tbody {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 0.75rem;
  }

  .catalog-table tr {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    overflow: hidden;
  }

  .catalog-table td { padding: 0; border: none; }
  .catalog-table tbody tr:hover { background: #fff; }

  .col-index { display: none; }

  .col-pic { width: 100%; }

  .pic-thumb,
  .col-pic .no-data {
    width: 100%;
    height: auto;
    aspect-ratio: 1 / 1;
    border: none;
    border-radius: 0;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .col-name { padding: 0.6rem 0.75rem 0; }
  .col-price { width: auto; padding: 0.25rem 0.75rem 0.75rem; }
}
</style>
