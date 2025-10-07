import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    const { username, password } = body

    console.log('🔐 Login attempt for username:', username)

    if (!username || !password) {
      return {
        error: 'Username and password are required',
        data: null
      }
    }

    // Initialize Supabase client
    const supabaseUrl = process.env.SUPABASE_URL
    const supabaseKey = process.env.SUPABASE_ANON_KEY

    console.log('🔧 Supabase config check:', { 
      url: supabaseUrl ? 'Set' : 'Missing', 
      key: supabaseKey ? 'Set' : 'Missing' 
    })

    if (!supabaseUrl || !supabaseKey) {
      console.log('❌ Missing Supabase configuration')
      return {
        error: 'Database configuration missing',
        data: null
      }
    }

    const supabase = createClient(supabaseUrl, supabaseKey)
    console.log('✅ Supabase client created successfully')

    // Query the users table to find the user
    console.log('🔍 Searching for user in database:', username)
    
    const { data: user, error } = await supabase
      .from('users')
      .select('id, username, password_hash, role, is_active')
      .eq('username', username)
      .eq('is_active', true)
      .single()

    console.log('📊 Database query result:', { 
      user: user ? { username: user.username, role: user.role, is_active: user.is_active } : null, 
      error: error?.message 
    })

    if (error) {
      console.log('❌ Database error:', error.message)
      return {
        error: 'Database error: ' + error.message,
        data: null
      }
    }

    if (!user) {
      console.log('❌ User not found or inactive')
      return {
        error: 'Invalid username or password',
        data: null
      }
    }

    console.log('✅ User found in database:', { 
      username: user.username, 
      role: user.role, 
      is_active: user.is_active 
    })
    console.log('🔐 Comparing passwords - stored:', user.password_hash, 'provided:', password)

    // Compare the provided password with the stored password_hash
    if (user.password_hash !== password) {
      console.log('❌ Password mismatch')
      return {
        error: 'Invalid username or password',
        data: null
      }
    }

    console.log('✅ Password verified successfully')

    // Return user data (without password)
    return {
      error: null,
      data: {
        user: {
          id: user.id,
          username: user.username,
          role: user.role
        }
      }
    }

  } catch (error) {
    console.error('❌ Login API error:', error)
    return {
      error: 'Internal server error: ' + (error instanceof Error ? error.message : String(error)),
      data: null
    }
  }
})
