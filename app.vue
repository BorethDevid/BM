<template>
  <div>
    <NavigationBar v-if="showNavigation" />
    <main class="main-content" :class="{ 'no-nav': !showNavigation }">
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

.main-content {
  min-height: calc(100vh - 60px);
  padding: 2rem 1rem;
  max-width: 1200px;
  margin: 0 auto;
}

.main-content.no-nav {
  min-height: 100vh;
  padding: 0;
}

/* Responsive design */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }
  
  .main-content.no-nav {
    padding: 0;
  }
}
</style>
