export default defineNuxtRouteMiddleware((to, from) => {
  console.log('🔒 Auth middleware: to.path =', to.path, 'from.path =', from.path)
  
  // Skip middleware on server side during SSR
  if (process.server) {
    console.log('🔒 Auth middleware: Skipping on server side')
    return
  }

  // Get authentication state
  const { isAuthenticated, currentUser } = useAuth()
  console.log('🔒 Auth middleware: isAuthenticated =', isAuthenticated.value)
  console.log('🔒 Auth middleware: currentUser =', currentUser.value)
  
  // Check localStorage directly for debugging
  if (typeof window !== 'undefined') {
    const stored = localStorage.getItem('bm-auth')
    console.log('🔒 Auth middleware: localStorage =', stored)
  }

  // Check if user is trying to access login page
  if (to.path === '/login') {
    // If already authenticated, redirect to dashboard
    if (isAuthenticated.value) {
      console.log('🔒 Auth middleware: User already authenticated, redirecting to dashboard')
      return navigateTo('/')
    }
    // Allow access to login page if not authenticated
    console.log('🔒 Auth middleware: Allowing access to login page')
    return
  }

  // For all other pages, check authentication
  if (!isAuthenticated.value) {
    console.log('🔒 Auth middleware: User not authenticated, redirecting to login')
    return navigateTo('/login')
  }
  
  console.log('🔒 Auth middleware: Allowing access to', to.path)
})
