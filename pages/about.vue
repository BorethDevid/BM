<template>
  <div class="container">
    <h1>About Page</h1>
    <p>This is the about page with TypeScript support.</p>
    <NuxtLink to="/">Back to Home</NuxtLink>
  </div>
</template>

<script setup lang="ts">
// TypeScript is enabled here
interface AboutData {
  title: string
  description: string
}

const aboutData: AboutData = {
  title: 'About Us',
  description: 'This is a Nuxt.js application with TypeScript support.'
}

console.log(aboutData)
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
