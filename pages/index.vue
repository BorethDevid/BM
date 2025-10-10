<script setup lang="ts">
// Apply authentication middleware
definePageMeta({
  middleware: 'auth'
})

const { currentUser } = useAuth()
</script>

<template>
  <div class="page-container">
    <el-row :gutter="24" class="page-header">
      <el-col :span="24">
        <el-card class="welcome-card" shadow="hover">
          <div class="welcome-content">
            <div class="welcome-text">
              <h1 class="welcome-title">
                <el-icon class="welcome-icon" size="32">
                  <House />
                </el-icon>
                Dashboard
              </h1>
              <p class="welcome-subtitle">Welcome back, {{ currentUser?.username }}!</p>
              <p class="welcome-description">Manage your business operations efficiently</p>
            </div>
            <div class="welcome-avatar">
              <el-avatar :size="80" class="user-avatar">
                <el-icon size="40"><User /></el-icon>
              </el-avatar>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="24" class="dashboard-grid">
      <el-col :xs="24" :sm="12" :md="12" :lg="6" :xl="6">
        <el-card class="dashboard-card" shadow="hover" @click="navigateTo('/stock')">
          <div class="card-content">
            <div class="card-icon stock-icon">
              <el-icon size="48"><Box /></el-icon>
            </div>
            <h3 class="card-title">Stock Management</h3>
            <p class="card-description">Manage your inventory and product stock levels</p>
            <el-button type="primary" class="card-button" @click.stop="navigateTo('/stock')">
              <el-icon><ArrowRight /></el-icon>
              Go to Stock
            </el-button>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="12" :lg="6" :xl="6">
        <el-card class="dashboard-card" shadow="hover" @click="navigateTo('/categories')">
          <div class="card-content">
            <div class="card-icon categories-icon">
              <el-icon size="48"><Folder /></el-icon>
            </div>
            <h3 class="card-title">Categories</h3>
            <p class="card-description">Organize your products with categories</p>
            <el-button type="success" class="card-button" @click.stop="navigateTo('/categories')">
              <el-icon><ArrowRight /></el-icon>
              Go to Categories
            </el-button>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="12" :lg="6" :xl="6">
        <el-card class="dashboard-card" shadow="hover" @click="navigateTo('/orders')">
          <div class="card-content">
            <div class="card-icon orders-icon">
              <el-icon size="48"><ShoppingCart /></el-icon>
            </div>
            <h3 class="card-title">Orders</h3>
            <p class="card-description">Track and manage customer orders</p>
            <el-button type="warning" class="card-button" @click.stop="navigateTo('/orders')">
              <el-icon><ArrowRight /></el-icon>
              Go to Orders
            </el-button>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="12" :md="12" :lg="6" :xl="6">
        <el-card class="dashboard-card" shadow="hover" @click="navigateTo('/data')">
          <div class="card-content">
            <div class="card-icon data-icon">
              <el-icon size="48"><DataAnalysis /></el-icon>
            </div>
            <h3 class="card-title">Data Management</h3>
            <p class="card-description">Reference data for dropdowns and configuration</p>
            <el-button type="info" class="card-button" @click.stop="navigateTo('/data')">
              <el-icon><ArrowRight /></el-icon>
              Go to Data
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.page-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
  background: #f8fafc;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 3rem;
}

.welcome-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(102, 126, 234, 0.15);
}

.welcome-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  padding: 2rem;
}

.welcome-text {
  flex: 1;
}

.welcome-title {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 2.8rem;
  font-weight: 800;
  margin: 0 0 0.5rem 0;
  color: white;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.welcome-icon {
  font-size: 2.5rem;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.welcome-subtitle {
  font-size: 1.3rem;
  margin: 0 0 0.5rem 0;
  opacity: 0.95;
  font-weight: 500;
}

.welcome-description {
  font-size: 1.1rem;
  margin: 0;
  opacity: 0.85;
  font-weight: 400;
}

.welcome-avatar {
  margin-left: 2rem;
}

.user-avatar {
  background: linear-gradient(135deg, #ffd700, #ffed4e);
  color: #333;
  box-shadow: 0 8px 16px rgba(255, 215, 0, 0.3);
  border: 3px solid rgba(255, 255, 255, 0.2);
}

.dashboard-grid {
  margin-top: 2rem;
}

.dashboard-card {
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 20px;
  border: none;
  overflow: hidden;
  background: white;
  height: 100%;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.dashboard-card:hover {
  transform: translateY(-12px) scale(1.02);
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
}

.card-content {
  padding: 2.5rem;
  text-align: center;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  position: relative;
}

.card-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.dashboard-card:hover .card-content::before {
  opacity: 1;
}

.card-icon {
  margin-bottom: 1.5rem;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 90px;
  border-radius: 20px;
  margin: 0 auto 1.5rem;
  width: 90px;
  position: relative;
  overflow: hidden;
}

.card-icon::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(255, 255, 255, 0.1), transparent);
  border-radius: 20px;
}

.stock-icon {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  box-shadow: 0 8px 16px rgba(59, 130, 246, 0.3);
}

.categories-icon {
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  box-shadow: 0 8px 16px rgba(16, 185, 129, 0.3);
}

.orders-icon {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: white;
  box-shadow: 0 8px 16px rgba(245, 158, 11, 0.3);
}

.data-icon {
  background: linear-gradient(135deg, #8b5cf6, #7c3aed);
  color: white;
  box-shadow: 0 8px 16px rgba(139, 92, 246, 0.3);
}

.card-title {
  color: #1e293b;
  font-size: 1.6rem;
  font-weight: 700;
  margin: 0 0 1rem 0;
  letter-spacing: -0.025em;
}

.card-description {
  color: #64748b;
  margin: 0 0 2rem 0;
  line-height: 1.7;
  flex: 1;
  font-size: 1rem;
  font-weight: 400;
}

.card-button {
  width: 100%;
  height: 52px;
  font-weight: 600;
  border-radius: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 1rem;
  letter-spacing: 0.025em;
  position: relative;
  overflow: hidden;
}

.card-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.card-button:hover::before {
  left: 100%;
}

.card-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}

/* Element Plus card customization */
:deep(.el-card__body) {
  padding: 0;
}

:deep(.el-card) {
  border: none;
}

/* Responsive design */
@media (max-width: 768px) {
  .page-container {
    padding: 1rem;
  }
  
  .welcome-content {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
  }
  
  .welcome-avatar {
    margin-left: 0;
  }
  
  .welcome-title {
    font-size: 2rem;
    justify-content: center;
  }
  
  .dashboard-grid {
    margin-top: 1rem;
  }
  
  .card-content {
    padding: 1.5rem;
  }
  
  .card-icon {
    width: 60px;
    height: 60px;
  }
  
  .card-title {
    font-size: 1.3rem;
  }
}

@media (max-width: 480px) {
  .welcome-title {
    font-size: 1.8rem;
  }
  
  .welcome-subtitle {
    font-size: 1rem;
  }
  
  .card-content {
    padding: 1rem;
  }
}
</style>