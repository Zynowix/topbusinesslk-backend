-- ==============================================================================
-- TOPBUSINESS.LK - Categories and Team Role-Based Access Control (RBAC) Schema
-- ==============================================================================

-- 1. Directory Categories Table
CREATE TABLE IF NOT EXISTS public.directory_categories (
  id TEXT PRIMARY KEY, -- Slug identifier, e.g. "photography-events"
  name TEXT NOT NULL UNIQUE,
  tag TEXT NOT NULL,
  blurb TEXT DEFAULT '',
  icon TEXT DEFAULT 'folder',
  order_index INTEGER DEFAULT 10,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Admin Users Table (RBAC)
CREATE TABLE IF NOT EXISTS public.admin_users (
  id TEXT PRIMARY KEY, -- "usr_123..."
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'editor', -- 'super_admin' | 'editor' | 'billing_admin' | 'viewer'
  status TEXT NOT NULL DEFAULT 'active', -- 'active' | 'suspended'
  passcode_hash TEXT NOT NULL,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Row Level Security
ALTER TABLE public.directory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Clean existing policies
DROP POLICY IF EXISTS "Public can view active categories" ON public.directory_categories;
DROP POLICY IF EXISTS "Service role full access on categories" ON public.directory_categories;
DROP POLICY IF EXISTS "Service role full access on admin users" ON public.admin_users;

-- Public can view active categories
CREATE POLICY "Public can view active categories"
ON public.directory_categories FOR SELECT
TO anon, authenticated, service_role
USING (active = true);

-- Service role has full access to categories
CREATE POLICY "Service role full access on categories"
ON public.directory_categories FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- ONLY service role has access to admin users (never exposed to anon or client keys)
CREATE POLICY "Service role full access on admin users"
ON public.admin_users FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- 4. Seed initial default categories
INSERT INTO public.directory_categories (id, name, tag, blurb, icon, order_index, active)
VALUES
  ('photography-events', 'Photography & Events', 'Photography & Events', 'Weddings, portraits, event coverage', 'camera', 10, true),
  ('home-services', 'Home Services', 'Home Services', 'Repairs, plumbing, electrical', 'wrench', 20, true),
  ('retail-hardware', 'Retail & Hardware', 'Retail & Hardware', 'Shops, tools, building supplies', 'shopping-bag', 30, true),
  ('bakery-food', 'Bakery & Food', 'Bakery & Food', 'Cakes, bakes, home kitchens', 'utensils', 40, true),
  ('tutoring-classes', 'Tutoring & Classes', 'Tutoring & Classes', 'O/L, A/L, languages, skills', 'graduation-cap', 50, true),
  ('salon-beauty', 'Salon & Beauty', 'Salon & Beauty', 'Hair, bridal, skincare', 'sparkles', 60, true)
ON CONFLICT (id) DO NOTHING;
