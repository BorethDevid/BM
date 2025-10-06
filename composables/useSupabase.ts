import type { SupabaseClient } from '@supabase/supabase-js'

export const useSupabase = (): SupabaseClient => {
  const { $supabase } = useNuxtApp()
  return $supabase
}

// Helper composable for common Supabase operations
export const useSupabaseAuth = () => {
  const supabase = useSupabase()
  
  return {
    // Auth methods
    signUp: (email: string, password: string) => 
      supabase.auth.signUp({ email, password }),
    
    signIn: (email: string, password: string) => 
      supabase.auth.signInWithPassword({ email, password }),
    
    signOut: () => supabase.auth.signOut(),
    
    getUser: () => supabase.auth.getUser(),
    
    getSession: () => supabase.auth.getSession(),
    
    // Auth state
    onAuthStateChange: (callback: (event: string, session: any) => void) =>
      supabase.auth.onAuthStateChange(callback)
  }
}

// Helper composable for database operations
export const useSupabaseDB = () => {
  const supabase = useSupabase()
  
  return {
    // Generic database methods
    from: (table: string) => supabase.from(table),
    
    // Common query helpers
    select: (table: string, columns = '*') => 
      supabase.from(table).select(columns),
    
    insert: (table: string, data: any) => 
      supabase.from(table).insert(data),
    
    update: (table: string, data: any) => 
      supabase.from(table).update(data),
    
    delete: (table: string) => 
      supabase.from(table).delete()
  }
}
