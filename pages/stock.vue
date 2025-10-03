<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Stock Management</h1>
      <p>Manage your inventory and stock levels</p>
    </div>
    
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
    
    <div class="stock-actions">
      <button class="btn btn-primary" @click="addNewProduct">
        Add New Product
      </button>
      <button class="btn btn-secondary" @click="viewInventory">
        View Full Inventory
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
// Stock management page with TypeScript
interface StockData {
  totalProducts: number
  lowStockItems: number
  outOfStockItems: number
}

const stockData: StockData = {
  totalProducts: 156,
  lowStockItems: 12,
  outOfStockItems: 3
}

const { totalProducts, lowStockItems, outOfStockItems } = stockData

const addNewProduct = (): void => {
  console.log('Adding new product...')
  // Add product logic here
}

const viewInventory = (): void => {
  console.log('Viewing full inventory...')
  // View inventory logic here
}
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
}
</style>

