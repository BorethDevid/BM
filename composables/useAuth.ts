// Global authentication state
const globalAuthState = {
  isAuthenticated: ref(false),
  currentUser: ref<{ username: string; role: string } | null>(null),
  loading: ref(false)
}

// Authentication composable
export const useAuth = () => {
  // Use global state to ensure consistency across components
  const isAuthenticated = globalAuthState.isAuthenticated
  const currentUser = globalAuthState.currentUser
  const loading = globalAuthState.loading

  // Initialize auth state from localStorage
  const initAuth = () => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem('bm-auth')
      if (stored) {
        try {
          const authData = JSON.parse(stored)
          isAuthenticated.value = authData.isAuthenticated
          currentUser.value = authData.user
        } catch (e) {
          localStorage.removeItem('bm-auth')
        }
      }
    }
  }

  // Login function with database verification
  const login = async (username: string, password: string): Promise<boolean> => {
    loading.value = true
    
    try {
      // Query database to verify credentials
      const response = await $fetch<{ data: any; error: string | null }>('/api/auth/login', {
        method: 'POST',
        body: {
          username: username.trim(),
          password: password.trim()
        }
      })
      
      if (response.error) {
        return false
      }
      
      if (response.data && response.data.user) {
        // Set state
        isAuthenticated.value = true
        currentUser.value = { 
          username: response.data.user.username, 
          role: response.data.user.role 
        }
        
        // Store in localStorage
        if (typeof window !== 'undefined') {
          const authData = {
            isAuthenticated: true,
            user: currentUser.value
          }
          localStorage.setItem('bm-auth', JSON.stringify(authData))
        }
        
        return true
      } else {
        return false
      }
    } catch (error) {
      return false
    } finally {
      loading.value = false
    }
  }

  // Logout function
  const logout = () => {
    isAuthenticated.value = false
    currentUser.value = null
    
    // Clear localStorage
    if (typeof window !== 'undefined') {
      localStorage.removeItem('bm-auth')
    }
  }

  // Check if user has specific role
  const hasRole = (role: string): boolean => {
    return currentUser.value?.role === role
  }

  // Check if user has any of the specified roles
  const hasAnyRole = (roles: string[]): boolean => {
    return currentUser.value ? roles.includes(currentUser.value.role) : false
  }

  // Initialize auth on client side
  onMounted(() => {
    if (typeof window !== 'undefined') {
      initAuth()
    }
  })

  return {
    isAuthenticated: readonly(isAuthenticated),
    currentUser: readonly(currentUser),
    loading: readonly(loading),
    login,
    logout,
    hasRole,
    hasAnyRole
  }
}