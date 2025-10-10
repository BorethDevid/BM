<script setup lang="ts">
// Apply authentication middleware
definePageMeta({
  middleware: 'auth'
})

const { currentUser } = useAuth()
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Dashboard</h1>
      <p>Welcome back, {{ currentUser?.username }}!</p>
    </div>
    
    <div class="dashboard-grid">
      <div class="dashboard-card">
        <div class="card-icon">📦</div>
        <h3>Stock Management</h3>
        <p>Manage your inventory and product stock levels</p>
        <NuxtLink to="/stock" class="card-link">Go to Stock</NuxtLink>
      </div>
      
      <div class="dashboard-card">
        <div class="card-icon">📋</div>
        <h3>Categories</h3>
        <p>Organize your products with categories</p>
        <NuxtLink to="/categories" class="card-link">Go to Categories</NuxtLink>
      </div>
      
      <div class="dashboard-card">
        <div class="card-icon">🛒</div>
        <h3>Orders</h3>
        <p>Track and manage customer orders</p>
        <NuxtLink to="/orders" class="card-link">Go to Orders</NuxtLink>
      </div>
      
      <div class="dashboard-card">
        <div class="card-icon">📊</div>
        <h3>Data Management</h3>
        <p>Reference data for dropdowns and configuration</p>
        <NuxtLink to="/data" class="card-link">Go to Data</NuxtLink>
      </div>
    </div>
  </div>
</template>

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
  margin: 0 0 0.5rem 0;
}

.page-header p {
  color: #7f8c8d;
  font-size: 1.1rem;
  margin: 0;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

.dashboard-card {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  text-align: center;
  transition: transform 0.2s, box-shadow 0.2s;
}

.dashboard-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.card-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.dashboard-card h3 {
  color: #2c3e50;
  font-size: 1.5rem;
  margin: 0 0 1rem 0;
}

.dashboard-card p {
  color: #7f8c8d;
  margin: 0 0 1.5rem 0;
  line-height: 1.5;
}

.card-link {
  display: inline-block;
  background: linear-gradient(135deg, #3498db, #2980b9);
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.2s;
}

.card-link:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

/* Responsive design */
@media (max-width: 768px) {
  .page-container {
    padding: 1rem;
  }
  
  .dashboard-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .dashboard-card {
    padding: 1.5rem;
  }
}
</style>