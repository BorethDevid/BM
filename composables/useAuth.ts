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
          console.log('🔄 Auth state restored from localStorage:', authData)
        } catch (e) {
          console.log('❌ Invalid localStorage data, clearing')
          localStorage.removeItem('bm-auth')
        }
      }
    }
  }

  // Login function
  const login = async (username: string, password: string): Promise<boolean> => {
    console.log('=== useAuth LOGIN START ===')
    console.log('useAuth login called with:', username, '***')
    console.log('Password check:', password === '1234')
    loading.value = true
    
    try {
      // Hardcoded credentials for now
      if (username === 'Admin' && password === '1234') {
        console.log('✅ Credentials match, setting authenticated state')
        
        // Set state
        isAuthenticated.value = true
        currentUser.value = { 
          username: 'Admin', 
          role: 'admin' 
        }
        
        console.log('✅ Auth state set:', { 
          isAuthenticated: isAuthenticated.value, 
          currentUser: currentUser.value 
        })
        
        // Store in localStorage
        if (typeof window !== 'undefined') {
          const authData = {
            isAuthenticated: true,
            user: currentUser.value
          }
          localStorage.setItem('bm-auth', JSON.stringify(authData))
          console.log('✅ Stored in localStorage:', authData)
        }
        
        console.log('✅ Login successful, returning true')
        console.log('=== useAuth LOGIN END (SUCCESS) ===')
        return true
      } else {
        console.log('❌ Invalid credentials - username:', username, 'password check:', password === '1234')
        console.log('=== useAuth LOGIN END (FAILED) ===')
        return false
      }
    } catch (error) {
      console.error('❌ Login error:', error)
      console.log('=== useAuth LOGIN END (ERROR) ===')
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