-- Migration: Create automated triggers
-- Created: 2025-10-26
-- Description: Create triggers for user_metrics updates and analytics cleanup

-- ========================================
-- TRIGGER: Auto-update user_metrics when fast is completed
-- ========================================

CREATE OR REPLACE FUNCTION update_user_metrics_on_fast_complete()
RETURNS TRIGGER AS $$
DECLARE
    duration_hours NUMERIC(10, 2);
    previous_fast_date TIMESTAMPTZ;
    current_streak INTEGER;
BEGIN
    -- Only proceed if the fast was just marked as completed
    IF NEW.completed = true AND (OLD.completed IS NULL OR OLD.completed = false) THEN

        -- Calculate duration in hours
        duration_hours := NEW.duration_minutes / 60.0;

        -- Get existing metrics for this user, if any
        SELECT last_fast_date, streak_days
        INTO previous_fast_date, current_streak
        FROM public.user_metrics
        WHERE user_id = NEW.user_id;

        -- Calculate new streak
        IF previous_fast_date IS NULL THEN
            -- First fast ever
            current_streak := 1;
        ELSIF DATE(NEW.end_time) = DATE(previous_fast_date) + INTERVAL '1 day' THEN
            -- Consecutive day - increment streak
            current_streak := COALESCE(current_streak, 0) + 1;
        ELSIF DATE(NEW.end_time) > DATE(previous_fast_date) + INTERVAL '1 day' THEN
            -- Gap in fasting - reset streak
            current_streak := 1;
        ELSE
            -- Same day or earlier - keep streak
            current_streak := COALESCE(current_streak, 1);
        END IF;

        -- Insert or update user_metrics
        INSERT INTO public.user_metrics (
            user_id,
            total_fasts,
            total_duration_hours,
            streak_days,
            last_fast_date,
            created_at,
            updated_at
        ) VALUES (
            NEW.user_id,
            1,
            duration_hours,
            current_streak,
            NEW.end_time,
            NOW(),
            NOW()
        )
        ON CONFLICT (user_id) DO UPDATE SET
            total_fasts = user_metrics.total_fasts + 1,
            total_duration_hours = user_metrics.total_duration_hours + duration_hours,
            streak_days = current_streak,
            last_fast_date = GREATEST(user_metrics.last_fast_date, NEW.end_time),
            updated_at = NOW();

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS trigger_update_user_metrics_on_fast_complete ON public.fasting_sessions;
CREATE TRIGGER trigger_update_user_metrics_on_fast_complete
AFTER UPDATE ON public.fasting_sessions
FOR EACH ROW
EXECUTE FUNCTION update_user_metrics_on_fast_complete();

COMMENT ON FUNCTION update_user_metrics_on_fast_complete() IS 'Automatically updates user_metrics when a fasting session is completed';

-- ========================================
-- TRIGGER: Auto-update updated_at timestamp for user_metrics
-- ========================================

CREATE OR REPLACE FUNCTION update_user_metrics_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS trigger_update_user_metrics_timestamp ON public.user_metrics;
CREATE TRIGGER trigger_update_user_metrics_timestamp
BEFORE UPDATE ON public.user_metrics
FOR EACH ROW
EXECUTE FUNCTION update_user_metrics_timestamp();

COMMENT ON FUNCTION update_user_metrics_timestamp() IS 'Automatically updates the updated_at timestamp for user_metrics';

-- ========================================
-- FUNCTION: Cleanup old analytics events
-- ========================================

CREATE OR REPLACE FUNCTION cleanup_old_analytics_events(days_to_keep INTEGER DEFAULT 90)
RETURNS TABLE(deleted_count BIGINT) AS $$
DECLARE
    rows_deleted BIGINT;
BEGIN
    -- Delete analytics events older than the specified number of days
    DELETE FROM public.analytics_events
    WHERE created_at < NOW() - (days_to_keep || ' days')::INTERVAL;

    GET DIAGNOSTICS rows_deleted = ROW_COUNT;

    RETURN QUERY SELECT rows_deleted;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION cleanup_old_analytics_events(INTEGER) IS 'Deletes analytics events older than specified days (default 90). Returns count of deleted rows.';

-- ========================================
-- SCHEDULED CLEANUP (if pg_cron is available)
-- ========================================

-- Note: pg_cron extension must be enabled for scheduled jobs
-- This can be enabled manually in Supabase dashboard
-- Example usage (to be run manually if pg_cron is enabled):
--
-- SELECT cron.schedule(
--     'cleanup-old-analytics',
--     '0 2 * * *', -- Run at 2 AM daily
--     $$ SELECT cleanup_old_analytics_events(90); $$
-- );

-- For manual cleanup, users can run:
-- SELECT cleanup_old_analytics_events(90);
