<template>
  <el-container class="navbar">
    <el-header class="navbar-header">
      <div class="navbar-container">
        <div class="navbar-brand">
          <el-icon class="brand-icon" size="24">
            <Shop />
          </el-icon>
          <h1>BM System</h1>
        </div>
        
        <el-menu
          :default-active="$route.path"
          mode="horizontal"
          class="navbar-menu"
          background-color="#2c3e50"
          text-color="#bdc3c7"
          active-text-color="#3498db"
          router
        >
          <el-menu-item index="/stock">
            <el-icon><Box /></el-icon>
            <span>Stock</span>
          </el-menu-item>
          <el-menu-item index="/categories">
            <el-icon><Folder /></el-icon>
            <span>Categories</span>
          </el-menu-item>
          <el-menu-item index="/orders">
            <el-icon><ShoppingCart /></el-icon>
            <span>Orders</span>
          </el-menu-item>
          <el-menu-item index="/data">
            <el-icon><DataAnalysis /></el-icon>
            <span>Data</span>
          </el-menu-item>
        </el-menu>
        
        <div class="navbar-user">
          <el-dropdown trigger="click" placement="bottom-end">
            <div class="user-dropdown">
              <el-avatar :size="32" class="user-avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
              <div class="user-info">
                <span class="user-name">{{ currentUser?.username }}</span>
                <span class="user-role">{{ currentUser?.role }}</span>
              </div>
              <el-icon class="dropdown-icon"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item>
                  <el-icon><User /></el-icon>
                  Profile
                </el-dropdown-item>
                <el-dropdown-item>
                  <el-icon><Setting /></el-icon>
                  Settings
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>
                  Logout
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>
  </el-container>
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
.navbar {
  position: sticky;
  top: 0;
  z-index: 1000;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
}

.navbar-header {
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  padding: 0;
  height: 80px !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.navbar-container {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 2rem;
  height: 100%;
}

.navbar-brand {
  display: flex;
  align-items: center;
  gap: 1rem;
  color: #ecf0f1;
}

.brand-icon {
  font-size: 2rem;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.navbar-brand h1 {
  margin: 0;
  font-size: 1.8rem;
  font-weight: 700;
  color: #ecf0f1;
  letter-spacing: -0.025em;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.navbar-menu {
  flex: 1;
  justify-content: center;
  border-bottom: none !important;
  background: transparent !important;
}

.navbar-menu .el-menu-item {
  border-bottom: 3px solid transparent !important;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  margin: 0 0.5rem;
  border-radius: 12px 12px 0 0;
  font-weight: 600;
  font-size: 1rem;
  letter-spacing: 0.025em;
  position: relative;
  overflow: hidden;
}

.navbar-menu .el-menu-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(59, 130, 246, 0.1), rgba(16, 185, 129, 0.1));
  opacity: 0;
  transition: opacity 0.3s ease;
}

.navbar-menu .el-menu-item:hover::before {
  opacity: 1;
}

.navbar-menu .el-menu-item:hover {
  background-color: transparent !important;
  border-bottom-color: #3b82f6 !important;
  color: #3b82f6 !important;
  transform: translateY(-2px);
}

.navbar-menu .el-menu-item.is-active {
  background-color: transparent !important;
  border-bottom-color: #3b82f6 !important;
  color: #3b82f6 !important;
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.2);
}

.navbar-user {
  display: flex;
  align-items: center;
}

.user-dropdown {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1.5rem;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
}

.user-dropdown:hover {
  background: rgba(255, 255, 255, 0.15);
  border-color: rgba(59, 130, 246, 0.4);
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.user-avatar {
  background: linear-gradient(135deg, #3498db, #2ecc71);
  color: white;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  text-align: left;
}

.user-name {
  font-weight: 700;
  color: #f1f5f9;
  font-size: 1rem;
  line-height: 1.2;
  letter-spacing: 0.025em;
}

.user-role {
  font-size: 0.8rem;
  color: #cbd5e1;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  line-height: 1.2;
  font-weight: 500;
}

.dropdown-icon {
  color: #cbd5e1;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 0.9rem;
}

.user-dropdown:hover .dropdown-icon {
  transform: rotate(180deg);
  color: #3b82f6;
}

/* Element Plus dropdown customization */
:deep(.el-dropdown-menu) {
  background: rgba(30, 41, 59, 0.95);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  padding: 0.75rem 0;
  min-width: 200px;
}

:deep(.el-dropdown-menu__item) {
  color: #f1f5f9;
  padding: 1rem 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 1rem;
  font-weight: 500;
  font-size: 0.95rem;
  letter-spacing: 0.025em;
  position: relative;
  overflow: hidden;
}

:deep(.el-dropdown-menu__item::before) {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.1), transparent);
  transition: left 0.5s;
}

:deep(.el-dropdown-menu__item:hover::before) {
  left: 100%;
}

:deep(.el-dropdown-menu__item:hover) {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
  transform: translateX(4px);
}

:deep(.el-dropdown-menu__item--divided) {
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  margin-top: 0.75rem;
  padding-top: 1rem;
}

/* Responsive design */
@media (max-width: 768px) {
  .navbar-container {
    flex-direction: column;
    height: auto;
    padding: 1rem;
    gap: 1rem;
  }
  
  .navbar-header {
    height: auto !important;
  }
  
  .navbar-menu {
    width: 100%;
    justify-content: center;
  }
  
  .navbar-menu .el-menu-item {
    margin: 0 0.25rem;
    padding: 0 1rem;
  }
  
  .user-dropdown {
    padding: 0.5rem;
  }
  
  .user-info {
    display: none;
  }
}

@media (max-width: 480px) {
  .navbar-brand h1 {
    font-size: 1.2rem;
  }
  
  .navbar-menu .el-menu-item span {
    display: none;
  }
  
  .navbar-menu .el-menu-item {
    padding: 0 0.75rem;
  }
}
</style>

