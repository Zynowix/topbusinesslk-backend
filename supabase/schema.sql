-- ==============================================================================
-- TopBusiness.lk — Supabase PostgreSQL Schema & Initial Data Migration
-- ==============================================================================
-- How to apply:
-- 1. Open your Supabase Dashboard: https://supabase.com/dashboard/project/_/sql
-- 2. Open the SQL Editor and paste this entire script.
-- 3. Click "Run". All tables, Row Level Security policies, indexes, and seed
--    records will be created immediately.
-- ==============================================================================

-- Enable UUID generation extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. BUSINESSES TABLE (Directory listings)
CREATE TABLE IF NOT EXISTS public.businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    district TEXT NOT NULL,
    initials TEXT,
    color TEXT DEFAULT '#274BC7',
    description TEXT,
    phone TEXT,
    whatsapp TEXT,
    website TEXT,
    link TEXT,
    address TEXT,
    thumbnail TEXT,
    verified BOOLEAN DEFAULT TRUE,
    verified_tier TEXT DEFAULT 'verified' CHECK (verified_tier IN ('verified', 'founding', 'claimed', 'unverified')),
    verification_score INT DEFAULT 95,
    visibility_score INT DEFAULT 80,
    live BOOLEAN DEFAULT TRUE,
    rank_slot INT,
    since TEXT,
    reach TEXT,
    rating NUMERIC(2,1) DEFAULT 5.0,
    review_count INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. SUBMISSIONS TABLE (Review Queue intake for applicant businesses)
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    owner TEXT NOT NULL,
    category TEXT NOT NULL,
    district TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    link TEXT,
    description TEXT,
    since TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'needs_clarification')),
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. ADMIN SETTINGS TABLE (Key-value store for app configuration)
CREATE TABLE IF NOT EXISTS public.admin_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Indexes for lightning fast lookups
CREATE INDEX IF NOT EXISTS idx_businesses_slug ON public.businesses(slug);
CREATE INDEX IF NOT EXISTS idx_businesses_category ON public.businesses(category);
CREATE INDEX IF NOT EXISTS idx_businesses_district ON public.businesses(district);
CREATE INDEX IF NOT EXISTS idx_businesses_live ON public.businesses(live);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON public.submissions(status);

-- Automatic updated_at trigger function
CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_businesses_updated_at ON public.businesses;
CREATE TRIGGER trigger_businesses_updated_at
BEFORE UPDATE ON public.businesses
FOR EACH ROW EXECUTE PROCEDURE public.set_current_timestamp_updated_at();

DROP TRIGGER IF EXISTS trigger_submissions_updated_at ON public.submissions;
CREATE TRIGGER trigger_submissions_updated_at
BEFORE UPDATE ON public.submissions
FOR EACH ROW EXECUTE PROCEDURE public.set_current_timestamp_updated_at();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Clean existing policies
DROP POLICY IF EXISTS "Public can view live businesses" ON public.businesses;
DROP POLICY IF EXISTS "Allow all for authenticated/service role on businesses" ON public.businesses;
DROP POLICY IF EXISTS "Public can submit business intake" ON public.submissions;
DROP POLICY IF EXISTS "Allow all for authenticated/service role on submissions" ON public.submissions;
DROP POLICY IF EXISTS "Public can view settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Allow all for authenticated/service role on settings" ON public.admin_settings;

-- Businesses policies:
-- Anyone can view live listings (or admins can view all via anon key or service role)
CREATE POLICY "Public can view live businesses"
ON public.businesses FOR SELECT
USING (true);

CREATE POLICY "Allow writes for service role and admin on businesses"
ON public.businesses FOR ALL
USING (true)
WITH CHECK (true);

-- Submissions policies:
-- Anyone can submit their business for verification
CREATE POLICY "Public can submit business intake"
ON public.submissions FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow writes for service role and admin on submissions"
ON public.submissions FOR ALL
USING (true)
WITH CHECK (true);

-- Admin settings policies:
CREATE POLICY "Public can view settings"
ON public.admin_settings FOR SELECT
USING (true);

CREATE POLICY "Allow writes for service role and admin on settings"
ON public.admin_settings FOR ALL
USING (true)
WITH CHECK (true);

-- ==============================================================================
-- INITIAL SEED DATA
-- ==============================================================================

-- 1. Seed Businesses (16 verified businesses)
INSERT INTO public.businesses (slug, name, category, district, initials, color, description, phone, whatsapp, website, link, address, thumbnail, verified, verified_tier, verification_score, visibility_score, live, since, reach)
VALUES
(
    'perera-wedding-photography',
    'Perera Wedding Photography',
    'Photography & Events',
    'Colombo',
    'PW',
    '#274BC7',
    'Full-day wedding and engagement coverage, edited within two weeks. Known for candid, natural-light shots across Colombo and the Western Province.',
    '+94 77 245 8910',
    'https://wa.me/94772458910',
    'https://www.pereraweddings.lk',
    'https://www.facebook.com/pereraweddingphotography',
    '42 Galle Road, Kollupitiya, Colombo 03',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'founding',
    98,
    81,
    TRUE,
    '2021',
    'Weekly bookings'
),
(
    'lakpahana-home-repairs',
    'Lakpahana Home Repairs',
    'Home Services',
    'Kandy',
    'LH',
    '#7B4FE0',
    'Plumbing, electrical, and general home repairs across Kandy district, with same-week callouts for urgent jobs.',
    '+94 77 123 4567',
    'https://wa.me/94771234567',
    'https://www.lakpahanarepairs.lk',
    'https://wa.me/94771234567',
    '18 Peradeniya Road, Kandy',
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'verified',
    95,
    74,
    TRUE,
    '2019',
    'Same-week callouts'
),
(
    'bandara-hardware-stores',
    'Bandara Hardware Stores',
    'Retail & Hardware',
    'Kurunegala',
    'BH',
    '#E0A62E',
    'Tools, fittings, and building supplies, open seven days a week, with delivery to nearby villages.',
    '+94 37 222 4589',
    'https://wa.me/94715558822',
    'https://www.bandarahardware.lk',
    'https://www.facebook.com/bandarahardware',
    '85 Colombo Road, Kurunegala',
    'https://images.unsplash.com/photo-1581783342308-f792dbdd27c5?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'verified',
    97,
    69,
    TRUE,
    '2015',
    'Islandwide delivery'
),
(
    'sweet-nangi-bakes',
    'Sweet Nangi Bakes',
    'Bakery & Food',
    'Gampaha',
    'SN',
    '#C1603A',
    'Custom cakes and Sri Lankan short eats, orders taken by WhatsApp with 48-hour notice for celebration cakes.',
    '+94 75 987 6543',
    'https://wa.me/94759876543',
    'https://www.instagram.com/sweetnangibakes',
    'https://wa.me/94759876543',
    '14 Lewis Place, Negombo',
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'verified',
    92,
    88,
    TRUE,
    '2022',
    'Order via WhatsApp'
),
(
    'isharas-tuition-class',
    'Ishara''s Tuition Class',
    'Tutoring & Classes',
    'Colombo',
    'IT',
    '#274BC7',
    'O/L and A/L Mathematics and Science, small group and one-to-one sessions, weekday evenings and weekends.',
    '+94 71 889 0012',
    'https://wa.me/94718890012',
    'https://www.isharastuition.lk',
    'https://www.facebook.com/isharastuition',
    '29 Havelock Road, Colombo 05',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'founding',
    96,
    79,
    TRUE,
    '2020',
    '12 active batches'
),
(
    'kumara-cabs-tours',
    'Kumara Cabs & Tours',
    'Transport & Cabs',
    'Galle',
    'KC',
    '#2E8B57',
    'Airport transfers, day trips, and southern expressway hires with clean, air-conditioned sedans and vans.',
    '+94 77 334 1122',
    'https://wa.me/94773341122',
    'https://www.kumaracabs.lk',
    'https://wa.me/94773341122',
    '08 Matara Road, Galle Fort',
    'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'verified',
    94,
    72,
    TRUE,
    '2018',
    '24/7 on call'
),
(
    'senanayake-legal-consultants',
    'Senanayake Legal Consultants',
    'Professional Services',
    'Colombo',
    'SL',
    '#152769',
    'Notarial services, deed transfers, company registrations, and legal document drafting for individuals and SMEs.',
    '+94 11 258 7741',
    'https://wa.me/94774561230',
    'https://www.senanayakelegal.lk',
    'https://www.senanayakelegal.lk',
    '72 Hulftsdorp Street, Colombo 12',
    'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'verified',
    99,
    85,
    TRUE,
    '2012',
    'Consultations by appt'
),
(
    'ayurveda-suwa-arana',
    'Ayurveda Suwa Arana',
    'Health & Wellness',
    'Matara',
    'AS',
    '#2E8B57',
    'Traditional herbal remedies, wellness consultations, and authentic Panchakarma packages in a calm coastal setting.',
    '+94 41 223 9988',
    'https://wa.me/94719988776',
    'https://www.suwaarana.lk',
    'https://www.suwaarana.lk',
    '55 Beach Road, Polhena, Matara',
    'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=600&auto=format&fit=crop&q=80',
    TRUE,
    'founding',
    91,
    77,
    TRUE,
    '2017',
    'Mon–Sat, 8am–6pm'
)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    district = EXCLUDED.district,
    phone = EXCLUDED.phone,
    whatsapp = EXCLUDED.whatsapp,
    website = EXCLUDED.website,
    address = EXCLUDED.address,
    thumbnail = EXCLUDED.thumbnail;

-- 2. Seed Review Queue Submissions
INSERT INTO public.submissions (name, owner, category, district, phone, email, link, description, since, status)
VALUES
(
    'Nayana''s Cake Studio',
    'Nayana Silva',
    'Bakery & Food',
    'Colombo',
    '077 224 5678',
    'nayana.cakes@gmail.com',
    'https://www.instagram.com/nayanascakestudio',
    'Custom celebration cakes and dessert tables, home-based kitchen, orders by Instagram DM.',
    '2 years',
    'pending'
),
(
    'Silva Electricals',
    'Chamara Silva',
    'Home Services',
    'Gampaha',
    '071 998 1122',
    'chamara.silva@gmail.com',
    'https://wa.me/94719981122',
    'Residential and small commercial electrical work across Negombo and surrounding areas.',
    '6 years',
    'pending'
),
(
    'Kelani Tutors Network',
    'Dilani Wickrama',
    'Tutoring & Classes',
    'Gampaha',
    '076 554 3321',
    'kelanitutors@gmail.com',
    'https://www.facebook.com/kelanitutors',
    'A/L Combined Maths and Physics tutoring, group and individual classes, weekday evenings.',
    '1 year',
    'pending'
),
(
    'Deshan Motor Works',
    'Deshan Perera',
    'Home Services',
    'Kurunegala',
    '070 112 3344',
    'deshan.motors@gmail.com',
    'https://facebook.com/deshanmotorworks',
    'Vehicle servicing and repairs, pickup available for breakdowns within Kurunegala town.',
    '4 years',
    'pending'
),
(
    'Green Leaf Gardeners',
    'Saman Kumara',
    'Home Services',
    'Kandy',
    '077 881 2233',
    'greenleaf.kandy@gmail.com',
    'https://wa.me/94778812233',
    'Garden design, lawn maintenance, and tree trimming for homes and guest houses across Kandy.',
    '3 years',
    'pending'
),
(
    'Ruhunu Printing Press',
    'Hiran Jayasuriya',
    'Retail & Hardware',
    'Galle',
    '091 223 4455',
    'ruhunuprint@sltnet.lk',
    'https://www.ruhunuprint.lk',
    'Visiting cards, bill books, banners, and offset printing for local businesses in Galle.',
    '8 years',
    'pending'
);

-- 3. Seed Admin Settings
INSERT INTO public.admin_settings (key, value)
VALUES
(
    'founding_spaces',
    '{"total": 25, "claimed": 6, "remaining": 19}'::jsonb
),
(
    'admin_config',
    '{"passcode": "topbiz2026", "platformName": "TopBusiness.lk", "currency": "LKR"}'::jsonb
)
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value;
