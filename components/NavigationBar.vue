<template>
  <nav class="navbar">
    <div class="navbar-container">
      <div class="navbar-brand">
        <h1>BM System</h1>
      </div>
      <div class="navbar-tabs">
        <NuxtLink 
          to="/stock" 
          class="navbar-tab"
          :class="{ active: $route.path === '/stock' }"
        >
          Stock
        </NuxtLink>
        <NuxtLink 
          to="/categories" 
          class="navbar-tab"
          :class="{ active: $route.path === '/categories' }"
        >
          Categories
        </NuxtLink>
        <NuxtLink 
          to="/order" 
          class="navbar-tab"
          :class="{ active: $route.path === '/order' }"
        >
          Order
        </NuxtLink>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
// Navigation component with TypeScript support
</script>

<style scoped>
.navbar {
  background-color: #2c3e50;
  color: white;
  padding: 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.navbar-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 1rem;
  height: 60px;
}

.navbar-brand h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: #ecf0f1;
}

.navbar-tabs {
  display: flex;
  gap: 0;
}

.navbar-tab {
  padding: 0.75rem 1.5rem;
  text-decoration: none;
  color: #bdc3c7;
  font-weight: 500;
  transition: all 0.3s ease;
  border-bottom: 3px solid transparent;
  position: relative;
}

.navbar-tab:hover {
  color: #ecf0f1;
  background-color: rgba(255, 255, 255, 0.1);
}

.navbar-tab.active {
  color: #3498db;
  border-bottom-color: #3498db;
  background-color: rgba(52, 152, 219, 0.1);
}

.navbar-tab.active:hover {
  color: #2980b9;
  border-bottom-color: #2980b9;
}

/* Responsive design */
@media (max-width: 768px) {
  .navbar-container {
    flex-direction: column;
    height: auto;
    padding: 1rem;
  }
  
  .navbar-tabs {
    margin-top: 1rem;
    width: 100%;
    justify-content: center;
  }
  
  .navbar-tab {
    flex: 1;
    text-align: center;
  }
}
</style>

