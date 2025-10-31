-- Migration: GDPR Compliance Tables
-- Created: 2025-10-31
-- Description: Creates tables for GDPR/CCPA compliance including consent management,
--              privacy policy versioning, account deletion tracking, and data export auditing

-- ==============================================================================
-- 1. USER_CONSENTS TABLE
-- Tracks granular user consent preferences for GDPR/CCPA compliance
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.user_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    consent_type TEXT NOT NULL CHECK (
        consent_type IN (
            'analytics_tracking',
            'marketing_communications',
            'data_processing',
            'non_essential_cookies',
            'do_not_sell_data'
        )
    ),
    consent_given BOOLEAN NOT NULL DEFAULT FALSE,
    consent_version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Ensure one consent record per user per consent type
    UNIQUE(user_id, consent_type)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_consents_user_id ON public.user_consents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_consents_consent_type ON public.user_consents(consent_type);
CREATE INDEX IF NOT EXISTS idx_user_consents_updated_at ON public.user_consents(updated_at);

-- Comments for documentation
COMMENT ON TABLE public.user_consents IS 'User consent preferences for GDPR/CCPA compliance';
COMMENT ON COLUMN public.user_consents.consent_type IS 'Type of consent: analytics_tracking, marketing_communications, data_processing, non_essential_cookies, do_not_sell_data';
COMMENT ON COLUMN public.user_consents.consent_given IS 'Whether user has granted this consent (default: false for GDPR compliance)';
COMMENT ON COLUMN public.user_consents.consent_version IS 'Version number incremented on each update for audit trail';

-- ==============================================================================
-- 2. PRIVACY_POLICY TABLE
-- Stores versioned privacy policy documents for dynamic updates
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.privacy_policy (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version INTEGER NOT NULL UNIQUE,
    content TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'es' CHECK (language IN ('es', 'en', 'pt', 'fr')),
    effective_date TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_privacy_policy_version ON public.privacy_policy(version);
CREATE INDEX IF NOT EXISTS idx_privacy_policy_language ON public.privacy_policy(language);
CREATE INDEX IF NOT EXISTS idx_privacy_policy_is_active ON public.privacy_policy(is_active);
CREATE INDEX IF NOT EXISTS idx_privacy_policy_effective_date ON public.privacy_policy(effective_date);

-- Unique constraint: Only one active policy per language
CREATE UNIQUE INDEX IF NOT EXISTS idx_privacy_policy_active_language
    ON public.privacy_policy(language)
    WHERE is_active = TRUE;

-- Comments for documentation
COMMENT ON TABLE public.privacy_policy IS 'Versioned privacy policy documents loaded dynamically in app';
COMMENT ON COLUMN public.privacy_policy.version IS 'Incrementing version number (unique)';
COMMENT ON COLUMN public.privacy_policy.content IS 'Full privacy policy text (supports Markdown)';
COMMENT ON COLUMN public.privacy_policy.is_active IS 'Whether this is the currently active policy for its language';

-- ==============================================================================
-- 3. ACCOUNT_DELETION_REQUESTS TABLE
-- Tracks account deletion requests with 30-day grace period (GDPR Article 17)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    scheduled_deletion_date TIMESTAMPTZ NOT NULL,
    recovery_token TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'cancelled', 'completed')
    ),
    cancelled_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    deletion_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_account_deletion_user_id ON public.account_deletion_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_account_deletion_status ON public.account_deletion_requests(status);
CREATE INDEX IF NOT EXISTS idx_account_deletion_scheduled_date ON public.account_deletion_requests(scheduled_deletion_date);
CREATE INDEX IF NOT EXISTS idx_account_deletion_recovery_token ON public.account_deletion_requests(recovery_token);

-- Comments for documentation
COMMENT ON TABLE public.account_deletion_requests IS 'Account deletion requests with 30-day grace period for GDPR Article 17 compliance';
COMMENT ON COLUMN public.account_deletion_requests.scheduled_deletion_date IS 'Date when account will be automatically deleted (typically 30 days after request)';
COMMENT ON COLUMN public.account_deletion_requests.recovery_token IS 'Unique token allowing user to cancel deletion within grace period';
COMMENT ON COLUMN public.account_deletion_requests.status IS 'Status: pending (awaiting deletion), cancelled (user recovered), completed (deleted)';

-- ==============================================================================
-- 4. DATA_EXPORT_AUDIT TABLE
-- Audit trail for data export operations (GDPR Article 20 - Right to Data Portability)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.data_export_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    export_type TEXT NOT NULL DEFAULT 'full' CHECK (
        export_type IN ('full', 'partial', 'specific')
    ),
    exported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    file_size_bytes BIGINT NOT NULL,
    record_counts JSONB NOT NULL DEFAULT '{}'::jsonb,
    export_format TEXT NOT NULL DEFAULT 'zip' CHECK (
        export_format IN ('json', 'csv', 'zip', 'pdf')
    ),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_data_export_audit_user_id ON public.data_export_audit(user_id);
CREATE INDEX IF NOT EXISTS idx_data_export_audit_exported_at ON public.data_export_audit(exported_at);
CREATE INDEX IF NOT EXISTS idx_data_export_audit_export_type ON public.data_export_audit(export_type);

-- JSONB index for efficient querying of record counts
CREATE INDEX IF NOT EXISTS idx_data_export_audit_record_counts ON public.data_export_audit USING GIN (record_counts);

-- Comments for documentation
COMMENT ON TABLE public.data_export_audit IS 'Audit trail for user data export operations (GDPR Article 20)';
COMMENT ON COLUMN public.data_export_audit.export_type IS 'Type of export: full (all data), partial (selected tables), specific (custom query)';
COMMENT ON COLUMN public.data_export_audit.record_counts IS 'JSON object with counts of records exported per table (e.g., {"fasting_sessions": 42, "hydration_logs": 156})';
COMMENT ON COLUMN public.data_export_audit.file_size_bytes IS 'Size of exported file in bytes';

-- ==============================================================================
-- TRIGGER: Auto-update updated_at timestamp
-- ==============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables with updated_at column
CREATE TRIGGER update_user_consents_updated_at
    BEFORE UPDATE ON public.user_consents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_privacy_policy_updated_at
    BEFORE UPDATE ON public.privacy_policy
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_account_deletion_requests_updated_at
    BEFORE UPDATE ON public.account_deletion_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- SUCCESS MESSAGE
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ GDPR Compliance tables created successfully:';
    RAISE NOTICE '   - user_consents (consent management)';
    RAISE NOTICE '   - privacy_policy (versioned policies)';
    RAISE NOTICE '   - account_deletion_requests (30-day grace period)';
    RAISE NOTICE '   - data_export_audit (export audit trail)';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Next steps:';
    RAISE NOTICE '   1. Apply RLS policies (run 20251031_gdpr_rls_policies.sql)';
    RAISE NOTICE '   2. Insert initial privacy policy content';
    RAISE NOTICE '   3. Test GDPR flows end-to-end';
END $$;
