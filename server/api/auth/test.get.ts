import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  try {
        // Initialize Supabase client using runtime config
        const config = useRuntimeConfig()
        const supabaseUrl = config.supabaseUrl
        const supabaseKey = config.supabaseAnonKey

        if (!supabaseUrl || !supabaseKey) {
          return {
            error: 'Database configuration missing. Please check environment variables.',
            data: null
          }
        }

    const supabase = createClient(supabaseUrl, supabaseKey)

    // Test database connection by querying users table
    const { data: users, error } = await supabase
      .from('users')
      .select('id, username, role, is_active')
      .limit(10)

    if (error) {
      return {
        error: 'Database error: ' + error.message,
        data: null
      }
    }

    return {
      error: null,
      data: {
        message: 'Database connection successful',
        users: users,
        totalUsers: users?.length || 0
      }
    }

  } catch (error) {
    console.error('Database test error:', error)
    return {
      error: 'Internal server error: ' + (error instanceof Error ? error.message : String(error)),
      data: null
    }
  }
})
