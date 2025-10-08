export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
    const supabaseUrl = config.supabaseUrl
    const supabaseKey = config.supabaseAnonKey

    return {
      error: null,
      data: {
        supabaseUrl: supabaseUrl ? 'Set' : 'Missing',
        supabaseKey: supabaseKey ? 'Set' : 'Missing',
        hasUrl: !!supabaseUrl,
        hasKey: !!supabaseKey,
        nodeEnv: process.env.NODE_ENV
      }
    }
  } catch (error) {
    return {
      error: 'Config check failed: ' + (error instanceof Error ? error.message : String(error)),
      data: null
    }
  }
})
