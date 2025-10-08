# Vercel Environment Variables Setup

## Required Environment Variables

You need to set these environment variables in your Vercel project:

### 1. Go to Vercel Dashboard
1. Navigate to your project dashboard
2. Go to **Settings** → **Environment Variables**

### 2. Add Environment Variables

Add these two environment variables:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `SUPABASE_URL` | `https://your-project.supabase.co` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | `your-anon-key-here` | Your Supabase anonymous key |

### 3. Get Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Go to **Settings** → **API**
3. Copy:
   - **Project URL** → Use as `SUPABASE_URL`
   - **anon public** key → Use as `SUPABASE_ANON_KEY`

### 4. Redeploy

After setting the environment variables:
1. Go to **Deployments** tab
2. Click **Redeploy** on the latest deployment
3. Or push a new commit to trigger automatic deployment

## Example Values

```
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Verification

After deployment, you can verify the environment variables are working by visiting:
- `https://your-app.vercel.app/api/auth/config`

This should show:
```json
{
  "error": null,
  "data": {
    "supabaseUrl": "Set",
    "supabaseKey": "Set",
    "hasUrl": true,
    "hasKey": true
  }
}
```
