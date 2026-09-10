-- ==============================================================================
-- TopBusiness.lk — Business Subscriptions & Payments Schema & RLS
-- ==============================================================================

-- 1. SUBSCRIPTIONS TABLE
CREATE TABLE IF NOT EXISTS public.business_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES public.businesses(id) ON DELETE CASCADE,
    business_slug TEXT NOT NULL UNIQUE,
    plan_tier TEXT NOT NULL DEFAULT 'founding_free', -- 'founding_free', 'standard_monthly', 'standard_yearly', 'premium_yearly'
    billing_cycle TEXT NOT NULL DEFAULT 'complimentary', -- 'monthly', 'yearly', 'complimentary'
    amount_lkr NUMERIC NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'LKR',
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'due', 'overdue', 'grace_period', 'cancelled'
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_end TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '1 year'),
    owner_phone TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast lookup
CREATE INDEX IF NOT EXISTS idx_subs_slug ON public.business_subscriptions(business_slug);
CREATE INDEX IF NOT EXISTS idx_subs_status ON public.business_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subs_renewal ON public.business_subscriptions(current_period_end);

-- 2. PAYMENTS HISTORY LEDGER
CREATE TABLE IF NOT EXISTS public.business_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES public.business_subscriptions(id) ON DELETE CASCADE,
    business_slug TEXT NOT NULL,
    amount_lkr NUMERIC NOT NULL,
    currency TEXT NOT NULL DEFAULT 'LKR',
    payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    period_covered TEXT NOT NULL, -- e.g. "October 2026", "2026-2027"
    method TEXT NOT NULL DEFAULT 'bank_transfer', -- 'bank_transfer', 'online_card', 'cash', 'waived', 'koko'
    reference_no TEXT, -- Bank slip / transaction reference
    recorded_by TEXT DEFAULT 'Admin',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_slug ON public.business_payments(business_slug);
CREATE INDEX IF NOT EXISTS idx_payments_date ON public.business_payments(payment_date);

-- 3. ROW LEVEL SECURITY (RLS) LOCKDOWN
-- Financial data is strictly confidential. Only service_role can access.
ALTER TABLE public.business_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Service role full access on subscriptions" ON public.business_subscriptions;
CREATE POLICY "Service role full access on subscriptions"
ON public.business_subscriptions FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Service role full access on payments" ON public.business_payments;
CREATE POLICY "Service role full access on payments"
ON public.business_payments FOR ALL
TO service_role
USING (true)
WITH CHECK (true);
