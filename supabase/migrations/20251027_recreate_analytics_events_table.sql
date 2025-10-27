-- Migration: Recreate analytics_events table with proper structure
-- Created: 2025-10-27
-- Description: Drops existing analytics_events table and recreates it with correct schema,
--              including event_type CHECK constraint, RLS policies, optimized indexes, and triggers
-- Task: 68 - Crear tabla 'analytics_events' en Supabase con tracking de eventos de usuario

-- ========================================
-- DROP EXISTING TABLE
-- ========================================
-- Drop existing analytics_events table to start fresh with correct structure
DROP TABLE IF EXISTS public.analytics_events CASCADE;

-- ========================================
-- CREATE ANALYTICS_EVENTS TABLE
-- ========================================
CREATE TABLE public.analytics_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (
        event_type IN (
            'fasting_started',
            'fasting_completed',
            'fasting_interrupted',
            'panic_button_used',
            'meditation_attempted',
            'meditation_completed',
            'hydration_logged',
            'plan_changed',
            'content_viewed',
            'subscription_converted'
        )
    ),
    event_data JSONB DEFAULT '{}',
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    session_id TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- TABLE COMMENTS
-- ========================================
COMMENT ON TABLE public.analytics_events IS 'User event tracking for analytics and behavior analysis';
COMMENT ON COLUMN public.analytics_events.event_id IS 'Unique identifier for the event';
COMMENT ON COLUMN public.analytics_events.user_id IS 'User who triggered the event';
COMMENT ON COLUMN public.analytics_events.event_type IS 'Type of event (constrained to valid values)';
COMMENT ON COLUMN public.analytics_events.event_data IS 'Flexible JSON data associated with the event';
COMMENT ON COLUMN public.analytics_events.timestamp IS 'When the event occurred';
COMMENT ON COLUMN public.analytics_events.session_id IS 'Session identifier for grouping related events';
COMMENT ON COLUMN public.analytics_events.updated_at IS 'Last update timestamp (auto-managed by trigger)';

-- ========================================
-- ENABLE ROW LEVEL SECURITY
-- ========================================
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

-- ========================================
-- RLS POLICIES
-- ========================================

-- Policy: Users can only access their own analytics events
CREATE POLICY "users_own_analytics_only"
ON public.analytics_events
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Service role (admin) can access all events for aggregations
CREATE POLICY "admin_aggregate_analytics_only"
ON public.analytics_events
FOR SELECT
USING (auth.role() = 'service_role');

-- Policy: Service role can manage all events
CREATE POLICY "service_role_can_manage_analytics"
ON public.analytics_events
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- ========================================
-- POLICY COMMENTS
-- ========================================
COMMENT ON POLICY "users_own_analytics_only" ON public.analytics_events IS
    'Users can only SELECT, INSERT, UPDATE, DELETE their own analytics events';
COMMENT ON POLICY "admin_aggregate_analytics_only" ON public.analytics_events IS
    'Service role can SELECT all events for aggregate analytics and reporting';
COMMENT ON POLICY "service_role_can_manage_analytics" ON public.analytics_events IS
    'Service role has full access to manage analytics events';

-- ========================================
-- OPTIMIZED INDEXES
-- ========================================

-- Index for querying user events by type
CREATE INDEX idx_analytics_events_user_type
ON public.analytics_events (user_id, event_type);

-- Index for time-based queries by event type
CREATE INDEX idx_analytics_events_type_timestamp
ON public.analytics_events (event_type, timestamp DESC);

-- Index for session-based analysis
CREATE INDEX idx_analytics_events_session
ON public.analytics_events (session_id)
WHERE session_id IS NOT NULL;

-- ========================================
-- INDEX COMMENTS
-- ========================================
COMMENT ON INDEX idx_analytics_events_user_type IS
    'Optimizes queries filtering by user and event type';
COMMENT ON INDEX idx_analytics_events_type_timestamp IS
    'Optimizes time-series queries by event type';
COMMENT ON INDEX idx_analytics_events_session IS
    'Optimizes session-based event grouping queries';

-- ========================================
-- TRIGGER FUNCTION: Auto-update updated_at
-- ========================================
CREATE OR REPLACE FUNCTION update_analytics_events_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS trigger_update_analytics_events_timestamp ON public.analytics_events;
CREATE TRIGGER trigger_update_analytics_events_timestamp
BEFORE UPDATE ON public.analytics_events
FOR EACH ROW
EXECUTE FUNCTION update_analytics_events_timestamp();

COMMENT ON FUNCTION update_analytics_events_timestamp() IS
    'Automatically updates updated_at timestamp for analytics_events';

-- ========================================
-- RETENTION POLICY FUNCTION
-- ========================================
-- Note: cleanup_old_analytics_events() function already exists from previous migration
-- Reference: supabase/migrations/20251026_create_triggers.sql
-- Usage: SELECT cleanup_old_analytics_events(730); -- 2 years = 730 days

COMMENT ON TABLE public.analytics_events IS
    'User event tracking for analytics. Use cleanup_old_analytics_events(730) for 2-year retention policy.';

-- ========================================
-- TODO: FUTURE ENHANCEMENTS
-- ========================================
-- TODO: Implement table partitioning for better performance at scale
--       - Use PARTITION BY RANGE (timestamp) for monthly partitions
--       - Consider pg_partman extension for automatic partition management
--       - Example: CREATE TABLE analytics_events (PARTITION BY RANGE (timestamp))
--       - Create partitions: analytics_events_y2024m01, analytics_events_y2024m02, etc.
--       - Set up automatic partition creation with pg_partman or cron job
--
-- TODO: Set up automated retention policy
--       - Configure pg_cron to run cleanup_old_analytics_events(730) daily
--       - Alternative: Use Supabase edge functions with scheduled invocations
--       - Schedule: Run at 2 AM daily to remove events older than 2 years
--
-- TODO: Consider materialized views for common analytics aggregations
--       - Example: Daily event counts by type
--       - Example: User engagement metrics by cohort
--       - Refresh schedule: Daily or hourly depending on requirements
