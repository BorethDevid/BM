<template>
  <div class="app-layout">
    <NavigationBar v-if="showNavigation" />
    <main class="main-content" :class="{ 'with-sidebar': showNavigation, 'no-nav': !showNavigation }">
      <NuxtPage />
    </main>
  </div>
</template>

<script setup lang="ts">
// Main app component with conditional navigation
const route = useRoute()
const { isAuthenticated } = useAuth()

// Only show navigation bar for authenticated users and not on login page
const showNavigation = computed(() => {
  // In production, be more strict about showing navigation
  if (typeof window === 'undefined') {
    return false // Never show navigation on server side
  }
  
  // On client side, check authentication and route
  return isAuthenticated.value && route.path !== '/login'
})
</script>

<style>
/* Global styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  line-height: 1.6;
  color: #333;
  background-color: #f8f9fa;
}

.app-layout {
  display: flex;
  min-height: 100vh;
}

.main-content {
  flex: 1;
  min-height: 100vh;
  padding: 2rem;
  background-color: #f8f9fa;
  transition: margin-left 0.3s ease;
}

.main-content.with-sidebar {
  margin-left: 280px;
}

.main-content.no-nav {
  margin-left: 0;
  padding: 0;
}

/* Responsive design */
@media (max-width: 768px) {
  .app-layout {
    flex-direction: column;
  }
  
  .main-content {
    margin-left: 0 !important;
    padding: 1rem;
  }
  
  .main-content.with-sidebar {
    margin-left: 0;
  }
  
  .main-content.no-nav {
    padding: 0;
  }
}
</style>
