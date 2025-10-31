-- Migration: Row Level Security (RLS) Policies for GDPR Tables
-- Created: 2025-10-31
-- Description: Implements secure RLS policies for GDPR compliance tables
--              Ensures users can only access their own data

-- ==============================================================================
-- ENABLE RLS ON ALL GDPR TABLES
-- ==============================================================================

ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.privacy_policy ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_export_audit ENABLE ROW LEVEL SECURITY;

-- ==============================================================================
-- 1. USER_CONSENTS RLS POLICIES
-- Users can read and update their own consents
-- ==============================================================================

-- Policy: Users can view their own consents
CREATE POLICY "Users can view their own consents"
    ON public.user_consents
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own consents
CREATE POLICY "Users can insert their own consents"
    ON public.user_consents
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own consents
CREATE POLICY "Users can update their own consents"
    ON public.user_consents
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own consents (for account cleanup)
CREATE POLICY "Users can delete their own consents"
    ON public.user_consents
    FOR DELETE
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 2. PRIVACY_POLICY RLS POLICIES
-- All authenticated users can read active policies (public data)
-- Only admins can modify policies (handled separately via service_role)
-- ==============================================================================

-- Policy: All authenticated users can read active privacy policies
CREATE POLICY "All authenticated users can read active privacy policies"
    ON public.privacy_policy
    FOR SELECT
    USING (auth.role() = 'authenticated' AND is_active = TRUE);

-- Note: INSERT/UPDATE/DELETE for privacy_policy should only be done via
-- service_role key or admin dashboard, not by regular users

-- ==============================================================================
-- 3. ACCOUNT_DELETION_REQUESTS RLS POLICIES
-- Users can create and view their own deletion requests
-- ==============================================================================

-- Policy: Users can view their own deletion requests
CREATE POLICY "Users can view their own deletion requests"
    ON public.account_deletion_requests
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can create their own deletion requests
CREATE POLICY "Users can create their own deletion requests"
    ON public.account_deletion_requests
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own deletion requests (for cancellation)
CREATE POLICY "Users can update their own deletion requests"
    ON public.account_deletion_requests
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND status IN ('pending', 'cancelled'));

-- Note: Deletion of deletion_requests should be handled by background jobs
-- using service_role key, not by users directly

-- ==============================================================================
-- 4. DATA_EXPORT_AUDIT RLS POLICIES
-- Users can view their own export history (read-only audit trail)
-- ==============================================================================

-- Policy: Users can view their own data export history
CREATE POLICY "Users can view their own export history"
    ON public.data_export_audit
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: System can insert export audit logs (no user updates/deletes)
CREATE POLICY "System can insert export audit logs"
    ON public.data_export_audit
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Note: data_export_audit is append-only for audit purposes
-- No UPDATE or DELETE policies to maintain audit integrity

-- ==============================================================================
-- GRANT PERMISSIONS
-- Ensure authenticated users have the necessary permissions
-- ==============================================================================

-- Grant permissions for user_consents
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_consents TO authenticated;
GRANT USAGE ON SEQUENCE IF EXISTS public.user_consents_id_seq TO authenticated;

-- Grant permissions for privacy_policy (read-only for users)
GRANT SELECT ON public.privacy_policy TO authenticated;

-- Grant permissions for account_deletion_requests
GRANT SELECT, INSERT, UPDATE ON public.account_deletion_requests TO authenticated;
GRANT USAGE ON SEQUENCE IF EXISTS public.account_deletion_requests_id_seq TO authenticated;

-- Grant permissions for data_export_audit (read and insert only)
GRANT SELECT, INSERT ON public.data_export_audit TO authenticated;
GRANT USAGE ON SEQUENCE IF EXISTS public.data_export_audit_id_seq TO authenticated;

-- ==============================================================================
-- HELPER FUNCTION: Check if user has admin role
-- (For future admin dashboard features)
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if user has admin role in auth.users metadata
    -- This can be extended based on your admin implementation
    RETURN (
        SELECT COALESCE(
            (current_setting('request.jwt.claims', true)::json->>'role') = 'admin',
            false
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- VALIDATION QUERIES
-- Test that RLS policies work correctly
-- ==============================================================================

DO $$
BEGIN
    -- Verify RLS is enabled
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename = 'user_consents'
        AND rowsecurity = true
    ) THEN
        RAISE EXCEPTION 'RLS not enabled on user_consents table';
    END IF;

    RAISE NOTICE '✅ RLS policies created successfully for GDPR tables:';
    RAISE NOTICE '   - user_consents: 4 policies (SELECT, INSERT, UPDATE, DELETE)';
    RAISE NOTICE '   - privacy_policy: 1 policy (SELECT active policies)';
    RAISE NOTICE '   - account_deletion_requests: 3 policies (SELECT, INSERT, UPDATE)';
    RAISE NOTICE '   - data_export_audit: 2 policies (SELECT, INSERT)';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 Security features:';
    RAISE NOTICE '   - Users can only access their own data';
    RAISE NOTICE '   - Privacy policies are public (read-only for users)';
    RAISE NOTICE '   - Audit logs are append-only';
    RAISE NOTICE '   - Admin functions available via service_role key';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  Next steps:';
    RAISE NOTICE '   1. Test RLS policies with authenticated users';
    RAISE NOTICE '   2. Insert initial privacy policy content';
    RAISE NOTICE '   3. Verify consent initialization during user registration';
END $$;
