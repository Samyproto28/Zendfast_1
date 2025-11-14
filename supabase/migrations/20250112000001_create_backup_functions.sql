-- Create backup_critical_data() PostgreSQL function for extracting user data
-- Migration: 20250112000001
-- Purpose: Extract fasting_sessions, user_profiles, and hydration_logs for backups

CREATE OR REPLACE FUNCTION public.backup_critical_data(p_hours INTEGER DEFAULT 24)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
    v_cutoff_time TIMESTAMPTZ;
    v_fasting_sessions JSONB;
    v_user_profiles JSONB;
    v_hydration_logs JSONB;
    v_record_counts JSONB;
BEGIN
    -- Calculate cutoff time
    v_cutoff_time := NOW() - (p_hours || ' hours')::INTERVAL;

    -- Extract fasting_sessions from last p_hours
    SELECT COALESCE(jsonb_agg(row_to_json(fs)), '[]'::jsonb)
    INTO v_fasting_sessions
    FROM (
        SELECT
            id,
            user_id,
            start_time,
            end_time,
            duration_minutes,
            completed,
            interrupted,
            plan_type,
            created_at,
            updated_at,
            sync_version
        FROM public.fasting_sessions
        WHERE created_at >= v_cutoff_time
           OR updated_at >= v_cutoff_time
        ORDER BY created_at DESC
    ) fs;

    -- Extract user_profiles for users with recent activity
    SELECT COALESCE(jsonb_agg(row_to_json(up)), '[]'::jsonb)
    INTO v_user_profiles
    FROM (
        SELECT DISTINCT
            up.id,
            up.created_at,
            up.updated_at,
            up.weight_kg,
            up.height_cm,
            up.is_first_time_faster,
            up.onboarding_completed,
            up.detox_plan_recommended,
            up.detox_plan_accepted,
            up.ml_per_glass,
            up.daily_hydration_goal,
            up.theme_mode,
            up.notifications_enabled,
            up.notification_water_enabled,
            up.notification_motivation_enabled,
            up.notification_educational_enabled,
            up.subscription_status,
            up.subscription_type,
            up.subscription_expires_at
        FROM public.user_profiles up
        INNER JOIN public.fasting_sessions fs
            ON up.id = fs.user_id
        WHERE fs.created_at >= v_cutoff_time
           OR fs.updated_at >= v_cutoff_time
        ORDER BY up.updated_at DESC
    ) up;

    -- Extract hydration_logs from last p_hours
    SELECT COALESCE(jsonb_agg(row_to_json(hl)), '[]'::jsonb)
    INTO v_hydration_logs
    FROM (
        SELECT
            id,
            user_id,
            amount_ml,
            timestamp,
            created_at
        FROM public.hydration_logs
        WHERE created_at >= v_cutoff_time
           OR timestamp >= v_cutoff_time
        ORDER BY created_at DESC
    ) hl;

    -- Build result with counts for verification
    v_record_counts := jsonb_build_object(
        'fasting_sessions_count', jsonb_array_length(v_fasting_sessions),
        'user_profiles_count', jsonb_array_length(v_user_profiles),
        'hydration_logs_count', jsonb_array_length(v_hydration_logs)
    );

    -- Combine all data into single JSONB response
    v_result := jsonb_build_object(
        'backup_timestamp', NOW(),
        'hours_covered', p_hours,
        'cutoff_time', v_cutoff_time,
        'counts', v_record_counts,
        'data', jsonb_build_object(
            'fasting_sessions', v_fasting_sessions,
            'user_profiles', v_user_profiles,
            'hydration_logs', v_hydration_logs
        )
    );

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        -- Return error details in JSONB format
        RETURN jsonb_build_object(
            'error', true,
            'error_message', SQLERRM,
            'error_detail', SQLSTATE,
            'timestamp', NOW()
        );
END;
$$;

-- Grant execute permission to service role only
REVOKE ALL ON FUNCTION public.backup_critical_data(INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.backup_critical_data(INTEGER) TO service_role;

-- Add comment for documentation
COMMENT ON FUNCTION public.backup_critical_data(INTEGER) IS
'Extracts critical user data (fasting_sessions, user_profiles, hydration_logs) from the last N hours for backup purposes. Returns JSONB with data and metadata. Service role only.';
