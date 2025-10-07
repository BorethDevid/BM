-- Authentication Database Setup
-- Create users table for authentication

-- Create users table
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy for users table
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);

-- Insert admin user (password: 1234)
-- Note: In production, use proper password hashing
INSERT INTO users (username, password_hash, role) 
VALUES ('Admin', '1234', 'admin');

-- Create index for username lookup
CREATE INDEX idx_users_username ON users(username);

-- Create index for active users
CREATE INDEX idx_users_active ON users(is_active);

-- Verification query
SELECT id, username, role, is_active, created_at 
FROM users 
WHERE username = 'Admin';
