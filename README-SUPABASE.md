# Supabase Configuration Guide

## Setup Instructions

### 1. Environment Variables
Create a `.env` file in your project root with your Supabase credentials:

```bash
# Copy the example file
cp .env.example .env
```

Then edit `.env` with your actual Supabase values:
```
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 2. Get Your Supabase Credentials
1. Go to [supabase.com](https://supabase.com)
2. Sign in to your account
3. Create a new project or select an existing one
4. Go to Settings > API
5. Copy your Project URL and anon/public key

### 3. Usage Examples

#### Authentication
```vue
<script setup lang="ts">
const { signUp, signIn, signOut, getUser } = useSupabaseAuth()

// Sign up a new user
const handleSignUp = async () => {
  const { data, error } = await signUp('user@example.com', 'password123')
  if (error) console.error(error)
  else console.log('User created:', data)
}

// Sign in
const handleSignIn = async () => {
  const { data, error } = await signIn('user@example.com', 'password123')
  if (error) console.error(error)
  else console.log('Signed in:', data)
}
</script>
```

#### Database Operations
```vue
<script setup lang="ts">
const { select, insert, update, delete: deleteRecord } = useSupabaseDB()

// Fetch data
const fetchUsers = async () => {
  const { data, error } = await select('users')
  if (error) console.error(error)
  else console.log('Users:', data)
}

// Insert data
const createUser = async () => {
  const { data, error } = await insert('users', {
    name: 'John Doe',
    email: 'john@example.com'
  })
  if (error) console.error(error)
  else console.log('User created:', data)
}
</script>
```

#### Direct Supabase Client Access
```vue
<script setup lang="ts">
const supabase = useSupabase()

// Use any Supabase method directly
const { data, error } = await supabase
  .from('products')
  .select('*')
  .eq('category', 'electronics')
</script>
```

## File Structure
- `plugins/supabase.client.ts` - Supabase client initialization
- `composables/useSupabase.ts` - Helper composables for easy usage
- `nuxt.config.ts` - Runtime configuration for environment variables
- `.env.example` - Template for environment variables

## Next Steps
1. Set up your Supabase project
2. Create your database tables
3. Configure Row Level Security (RLS) policies
4. Start building your application!
