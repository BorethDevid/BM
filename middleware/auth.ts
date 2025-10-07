export default defineNuxtRouteMiddleware((to, from) => {
  // Only run on client side
  if (typeof window === 'undefined') {
    return
  }

  // Get authentication state
  const { isAuthenticated } = useAuth()
  
  // Check if user is trying to access login page
  if (to.path === '/login') {
    // If already authenticated, redirect to dashboard
    if (isAuthenticated.value) {
      return navigateTo('/')
    }
    // Allow access to login page if not authenticated
    return
  }

  // For all other pages, check authentication
  if (!isAuthenticated.value) {
    return navigateTo('/login')
  }
})
