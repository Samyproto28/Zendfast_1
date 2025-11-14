-- Schedule daily backup job using pg_cron
-- Migration: 20250112000003
-- Purpose: Configure automated daily backups at 2 AM UTC

-- Note: pg_cron extension must be enabled in Supabase Dashboard first
-- Go to: Dashboard > Database > Extensions > Enable pg_cron

-- Create the daily backup cron job
-- Runs at 2 AM UTC every day
-- Uses pg_net to make HTTP POST request to backup-data Edge Function
SELECT cron.schedule(
    'daily-backup-automated',                    -- Job name
    '0 2 * * *',                                  -- Cron schedule: 2 AM UTC daily
    $$
    SELECT
        net.http_post(
            url := current_setting('app.settings.supabase_url') || '/functions/v1/backup-data',
            headers := jsonb_build_object(
                'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key'),
                'Content-Type', 'application/json'
            ),
            body := jsonb_build_object(
                'source', 'pg_cron',
                'scheduled', true
            )
        ) AS request_id;
    $$
);

-- Create a helper function to manually trigger backup (for testing)
CREATE OR REPLACE FUNCTION public.trigger_backup_manually()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_response JSONB;
BEGIN
    -- Only allow service role to trigger manual backups
    IF auth.role() != 'service_role' THEN
        RAISE EXCEPTION 'Only service role can trigger manual backups';
    END IF;

    -- Make HTTP request to backup-data Edge Function
    SELECT INTO v_response
        net.http_post(
            url := current_setting('app.settings.supabase_url') || '/functions/v1/backup-data',
            headers := jsonb_build_object(
                'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key'),
                'Content-Type', 'application/json'
            ),
            body := jsonb_build_object(
                'source', 'manual_trigger',
                'scheduled', false
            )
        );

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Backup triggered manually',
        'response', v_response,
        'timestamp', NOW()
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM,
            'timestamp', NOW()
        );
END;
$$;

-- Grant execute to service role only
REVOKE ALL ON FUNCTION public.trigger_backup_manually() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.trigger_backup_manually() TO service_role;

-- Add helpful comments
COMMENT ON FUNCTION public.trigger_backup_manually() IS
'Manually trigger a backup execution. Service role only. Useful for testing and emergency backups.';

-- Note: To view scheduled jobs, run:
-- SELECT * FROM cron.job WHERE jobname = 'daily-backup-automated';

-- Note: To unschedule the job (if needed), run:
-- SELECT cron.unschedule('daily-backup-automated');

-- Note: To view job execution history, run:
-- SELECT * FROM cron.job_run_details WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-backup-automated') ORDER BY start_time DESC LIMIT 10;
