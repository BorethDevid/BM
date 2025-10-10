<template>
  <nav class="sidebar">
    <div class="sidebar-container">
      <!-- Brand Section -->
      <NuxtLink to="/" class="sidebar-brand">
        <div class="brand-icon">🏪</div>
        <h1>BM System</h1>
      </NuxtLink>
      
      <!-- Navigation Menu -->
      <div class="sidebar-menu">
        <NuxtLink 
          to="/" 
          class="sidebar-item"
          :class="{ active: $route.path === '/' }"
        >
          <span class="item-icon">🏠</span>
          <span class="item-text">Home</span>
        </NuxtLink>
        <NuxtLink 
          to="/stock" 
          class="sidebar-item"
          :class="{ active: $route.path === '/stock' }"
        >
          <span class="item-icon">📦</span>
          <span class="item-text">Stock</span>
        </NuxtLink>
        <NuxtLink 
          to="/categories" 
          class="sidebar-item"
          :class="{ active: $route.path === '/categories' }"
        >
          <span class="item-icon">📁</span>
          <span class="item-text">Categories</span>
        </NuxtLink>
        <NuxtLink 
          to="/orders" 
          class="sidebar-item"
          :class="{ active: $route.path === '/orders' }"
        >
          <span class="item-icon">🛒</span>
          <span class="item-text">Orders</span>
        </NuxtLink>
        <NuxtLink 
          to="/data" 
          class="sidebar-item"
          :class="{ active: $route.path === '/data' }"
        >
          <span class="item-icon">📊</span>
          <span class="item-text">Data</span>
        </NuxtLink>
      </div>
      
      <!-- User Section -->
      <div class="sidebar-user">
        <div class="user-info">
          <div class="user-avatar">👤</div>
          <div class="user-details">
            <span class="user-name">{{ currentUser?.username }}</span>
            <span class="user-role">{{ currentUser?.role }}</span>
          </div>
        </div>
      </div>
    </div>
  </nav>
  
  <!-- Fixed Logout Button - Always visible at bottom of screen -->
  <div class="fixed-logout">
    <button @click="handleLogout" class="logout-btn">
      <span class="logout-icon">🚪</span>
      <span class="logout-text">Logout</span>
    </button>
  </div>
</template>

<script setup lang="ts">
const { currentUser, logout } = useAuth()
const router = useRouter()

const handleLogout = () => {
  logout()
  router.push('/login')
}
</script>

<style scoped>
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  width: 280px;
  height: 100vh;
  background: linear-gradient(180deg, #1e293b 0%, #334155 100%);
  color: white;
  box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  overflow-y: auto;
}

.sidebar-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 0;
}

/* Brand Section */
.sidebar-brand {
  padding: 2rem 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  text-decoration: none;
  color: inherit;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
}

.sidebar-brand:hover {
  background: rgba(59, 130, 246, 0.1);
  transform: translateX(4px);
}

.brand-icon {
  font-size: 2rem;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.sidebar-brand h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: #f1f5f9;
  letter-spacing: -0.025em;
}

/* Navigation Menu */
.sidebar-menu {
  flex: 1;
  padding: 1rem 0;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  text-decoration: none;
  color: #cbd5e1;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  margin: 0.25rem 0;
}

.sidebar-item::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  background: linear-gradient(180deg, #3b82f6, #1d4ed8);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.sidebar-item:hover {
  color: #f1f5f9;
  background: rgba(59, 130, 246, 0.1);
  transform: translateX(4px);
}

.sidebar-item:hover::before {
  opacity: 1;
}

.sidebar-item.active {
  color: #3b82f6;
  background: rgba(59, 130, 246, 0.15);
  font-weight: 600;
}

.sidebar-item.active::before {
  opacity: 1;
}

.item-icon {
  font-size: 1.2rem;
  width: 24px;
  text-align: center;
}

.item-text {
  font-size: 1rem;
  letter-spacing: 0.025em;
}

/* User Section */
.sidebar-user {
  padding: 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(0, 0, 0, 0.1);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3);
}

.user-details {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-weight: 600;
  color: #f1f5f9;
  font-size: 0.95rem;
  letter-spacing: 0.025em;
}

.user-role {
  font-size: 0.8rem;
  color: #cbd5e1;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 500;
}

/* Fixed Logout Button - Always visible at bottom of screen */
.fixed-logout {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 1001;
}

.logout-btn {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  border: none;
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 50px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  box-shadow: 0 8px 20px rgba(239, 68, 68, 0.4);
  min-width: 120px;
}

.logout-btn:hover {
  background: linear-gradient(135deg, #dc2626, #b91c1c);
  transform: translateY(-3px);
  box-shadow: 0 12px 25px rgba(239, 68, 68, 0.5);
}

.logout-btn:active {
  transform: translateY(-1px);
}

.logout-icon {
  font-size: 1.1rem;
}

.logout-text {
  letter-spacing: 0.025em;
}

/* Responsive design */
@media (max-width: 768px) {
  .sidebar {
    width: 100%;
    height: auto;
    position: relative;
    box-shadow: none;
  }
  
  .sidebar-container {
    flex-direction: row;
    height: auto;
  }
  
  .sidebar-brand {
    padding: 1rem;
    border-bottom: none;
    border-right: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .sidebar-brand:hover {
    transform: translateY(-2px);
  }
  
  .sidebar-brand h1 {
    font-size: 1.2rem;
  }
  
  .sidebar-menu {
    flex: 1;
    display: flex;
    padding: 0;
  }
  
  .sidebar-item {
    flex: 1;
    flex-direction: column;
    padding: 1rem 0.5rem;
    text-align: center;
    margin: 0;
  }
  
  .sidebar-item::before {
    top: 0;
    left: 0;
    right: 0;
    width: auto;
    height: 4px;
  }
  
  .sidebar-item:hover {
    transform: translateY(-2px);
  }
  
  .item-text {
    font-size: 0.8rem;
    margin-top: 0.25rem;
  }
  
  .sidebar-user {
    padding: 1rem;
    border-top: none;
    border-left: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .user-info {
    flex-direction: column;
    text-align: center;
  }
  
  .user-avatar {
    width: 32px;
    height: 32px;
    font-size: 1rem;
  }
  
  .user-name {
    font-size: 0.8rem;
  }
  
  .user-role {
    font-size: 0.7rem;
  }
  
  .fixed-logout {
    bottom: 15px;
    right: 15px;
  }
  
  .logout-btn {
    padding: 0.75rem 1rem;
    font-size: 0.8rem;
    min-width: 100px;
  }
  
  .logout-text {
    display: none;
  }
}
</style>

