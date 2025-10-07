export default defineNuxtRouteMiddleware((to, from) => {
  // Skip middleware on server side during SSR
  if (process.server) return

  // Get authentication state
  const { isAuthenticated } = useAuth()

  // Check if user is trying to access login page
  if (to.path === '/login') {
    // If already authenticated, redirect to dashboard
    if (isAuthenticated.value) {
      console.log('User already authenticated, redirecting to dashboard')
      return navigateTo('/')
    }
    // Allow access to login page if not authenticated
    return
  }

  // For all other pages, check authentication
  if (!isAuthenticated.value) {
    console.log('User not authenticated, redirecting to login')
    return navigateTo('/login')
  }
})
