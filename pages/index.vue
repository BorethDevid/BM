<template>
  <div class="container">
    <h1>Welcome to Nuxt.js with TypeScript!</h1>
    <p>This is your first page with TypeScript support.</p>
    <NuxtLink to="/about">Go to About page</NuxtLink>
  </div>
</template>

<script setup lang="ts">
// TypeScript is enabled here
const message: string = 'Hello from TypeScript!'
console.log(message)
</script>

<style scoped>
.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

h1 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

p {
  color: #7f8c8d;
  margin-bottom: 2rem;
}
</style>
