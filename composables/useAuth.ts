// Authentication composable
export const useAuth = () => {
  // Reactive state
  const isAuthenticated = ref(false)
  const currentUser = ref<{ username: string; role: string } | null>(null)
  const loading = ref(false)

  // Initialize auth state from localStorage
  const initAuth = () => {
    if (process.client) {
      const stored = localStorage.getItem('bm-auth')
      if (stored) {
        try {
          const authData = JSON.parse(stored)
          isAuthenticated.value = authData.isAuthenticated
          currentUser.value = authData.user
        } catch (e) {
          // Clear invalid data
          localStorage.removeItem('bm-auth')
        }
      }
    }
  }

  // Login function
  const login = async (username: string, password: string): Promise<boolean> => {
    console.log('useAuth login called with:', username, '***')
    loading.value = true
    
    try {
      // Hardcoded credentials for now
      if (username === 'Admin' && password === '1234') {
        console.log('Credentials match, setting authenticated state')
        isAuthenticated.value = true
        currentUser.value = { 
          username: 'Admin', 
          role: 'admin' 
        }
        
        console.log('Auth state set:', { isAuthenticated: isAuthenticated.value, currentUser: currentUser.value })
        
        // Store in localStorage
        if (process.client) {
          const authData = {
            isAuthenticated: true,
            user: currentUser.value
          }
          localStorage.setItem('bm-auth', JSON.stringify(authData))
          console.log('Stored in localStorage:', authData)
        }
        
        console.log('Login successful, returning true')
        return true
      } else {
        console.log('Invalid credentials')
        return false
      }
    } catch (error) {
      console.error('Login error:', error)
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
    if (process.client) {
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
    initAuth()
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