-- ==============================================================================
-- TopBusiness.lk — Supabase Row Level Security (RLS) Lockdown
-- ==============================================================================
-- Purpose:
-- 1. Prevent anonymous public clients from reading private applicant submissions.
-- 2. Prevent anonymous public clients from modifying or deleting business listings.
-- 3. Restrict administrative mutations strictly to the server-side service role.
-- ==============================================================================

-- 1. SUBMISSIONS TABLE POLICIES
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

-- Clean existing insecure policies
DROP POLICY IF EXISTS "Public can submit business intake" ON public.submissions;
DROP POLICY IF EXISTS "Allow all for authenticated/service role on submissions" ON public.submissions;
DROP POLICY IF EXISTS "Allow writes for service role and admin on submissions" ON public.submissions;
DROP POLICY IF EXISTS "Public can submit pending intake only" ON public.submissions;
DROP POLICY IF EXISTS "Service role full access on submissions" ON public.submissions;

-- Public can ONLY INSERT new submissions with status forced to 'pending'
CREATE POLICY "Public can submit pending intake only"
ON public.submissions FOR INSERT
TO anon, authenticated, service_role
WITH CHECK (status = 'pending');

-- ONLY service_role can SELECT (read), UPDATE (approve/edit), or DELETE submissions
CREATE POLICY "Service role full access on submissions"
ON public.submissions FOR ALL
TO service_role
USING (true)
WITH CHECK (true);


-- 2. BUSINESSES TABLE POLICIES
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- Clean existing insecure policies
DROP POLICY IF EXISTS "Public can view live businesses" ON public.businesses;
DROP POLICY IF EXISTS "Allow all for authenticated/service role on businesses" ON public.businesses;
DROP POLICY IF EXISTS "Allow writes for service role and admin on businesses" ON public.businesses;
DROP POLICY IF EXISTS "Public can view live businesses only" ON public.businesses;
DROP POLICY IF EXISTS "Service role full access on businesses" ON public.businesses;

-- Public can ONLY SELECT verified live businesses
CREATE POLICY "Public can view live businesses only"
ON public.businesses FOR SELECT
TO anon, authenticated, service_role
USING (live = true);

-- ONLY service_role can INSERT, UPDATE, or DELETE business directory listings
CREATE POLICY "Service role full access on businesses"
ON public.businesses FOR ALL
TO service_role
USING (true)
WITH CHECK (true);


-- 3. ADMIN SETTINGS TABLE POLICIES
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Clean existing insecure policies
DROP POLICY IF EXISTS "Public can view settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Allow all for authenticated/service role on settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Allow writes for service role and admin on settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Service role full access on settings" ON public.admin_settings;

-- Public can read general application settings (e.g. founding counter)
CREATE POLICY "Public can view settings"
ON public.admin_settings FOR SELECT
TO anon, authenticated, service_role
USING (true);

-- ONLY service_role can UPDATE or INSERT admin settings
CREATE POLICY "Service role full access on settings"
ON public.admin_settings FOR ALL
TO service_role
USING (true)
WITH CHECK (true);
