-- Migration: Create Terms of Service Table
-- Created: 2025-11-08
-- Description: Creates table to store versioned Terms of Service documents in multiple languages

-- ==============================================================================
-- CREATE TERMS OF SERVICE TABLE
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.terms_of_service (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version INTEGER NOT NULL UNIQUE,
    content TEXT NOT NULL,
    language VARCHAR(5) NOT NULL DEFAULT 'es',
    effective_date TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_language CHECK (language IN ('es', 'en'))
);

-- ==============================================================================
-- CREATE INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_terms_version ON public.terms_of_service(version);
CREATE INDEX IF NOT EXISTS idx_terms_active ON public.terms_of_service(is_active);
CREATE INDEX IF NOT EXISTS idx_terms_language ON public.terms_of_service(language);
CREATE INDEX IF NOT EXISTS idx_terms_version_language ON public.terms_of_service(version, language);

-- ==============================================================================
-- ENABLE RLS
-- ==============================================================================

ALTER TABLE public.terms_of_service ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- CREATE RLS POLICIES (Public Read Access)
-- ==============================================================================

-- Policy: Anyone can read active terms of service
CREATE POLICY "terms_of_service_select_policy"
    ON public.terms_of_service
    FOR SELECT
    USING (is_active = TRUE);

-- Policy: Only authenticated admins can insert/update
-- (This will be refined when admin roles are implemented)
CREATE POLICY "terms_of_service_admin_policy"
    ON public.terms_of_service
    FOR ALL
    USING (auth.uid() IS NOT NULL);

-- ==============================================================================
-- CREATE UPDATED_AT TRIGGER
-- ==============================================================================

CREATE OR REPLACE FUNCTION update_terms_of_service_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_terms_of_service_updated_at
    BEFORE UPDATE ON public.terms_of_service
    FOR EACH ROW
    EXECUTE FUNCTION update_terms_of_service_updated_at();

-- ==============================================================================
-- SUCCESS MESSAGE
-- ==============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Terms of Service table created successfully';
    RAISE NOTICE '   - Table: public.terms_of_service';
    RAISE NOTICE '   - Supports: Versioning, multilingual (es/en), active status';
    RAISE NOTICE '   - RLS: Enabled with public read access for active terms';
    RAISE NOTICE '   - Indexes: Created for version, language, and active status';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Next steps:';
    RAISE NOTICE '   1. Run seed migration to insert initial ToS content';
    RAISE NOTICE '   2. Create Flutter model for TermsOfService';
    RAISE NOTICE '   3. Implement TermsOfServiceScreen';
END $$;
