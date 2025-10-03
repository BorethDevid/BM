<template>
  <div>
    <NavigationBar />
    <main class="main-content">
      <NuxtPage />
    </main>
  </div>
</template>

<script setup lang="ts">
// Main app component with navigation
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

/* Responsive design */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }
}
</style>
