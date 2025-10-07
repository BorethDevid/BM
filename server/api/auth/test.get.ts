import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  try {
    // Initialize Supabase client
    const supabaseUrl = process.env.SUPABASE_URL
    const supabaseKey = process.env.SUPABASE_ANON_KEY

    if (!supabaseUrl || !supabaseKey) {
      return {
        error: 'Database configuration missing',
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
