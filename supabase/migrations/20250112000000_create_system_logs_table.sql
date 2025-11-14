-- Create system_logs table for logging backup events and other system operations
-- Migration: 20250112000000
-- Purpose: Track backup execution, failures, and other system-level events

CREATE TABLE IF NOT EXISTS public.system_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL CHECK (event_type IN (
        'backup_success',
        'backup_failure',
        'backup_started',
        'retention_cleanup',
        'notification_sent',
        'notification_failed'
    )),
    event_data JSONB DEFAULT '{}'::jsonb,
    backup_size_bytes BIGINT,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index for efficient querying by event type and date
CREATE INDEX IF NOT EXISTS idx_system_logs_event_type ON public.system_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_system_logs_created_at ON public.system_logs(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.system_logs ENABLE ROW LEVEL SECURITY;

-- Policy: Only service role can read system logs
CREATE POLICY "Service role can read system logs"
    ON public.system_logs
    FOR SELECT
    USING (auth.role() = 'service_role');

-- Policy: Only service role can insert system logs
CREATE POLICY "Service role can insert system logs"
    ON public.system_logs
    FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

-- Add comment for documentation
COMMENT ON TABLE public.system_logs IS 'System-level event logging for backups, notifications, and operations';
COMMENT ON COLUMN public.system_logs.event_type IS 'Type of system event (backup_success, backup_failure, etc.)';
COMMENT ON COLUMN public.system_logs.event_data IS 'Additional metadata in JSONB format (filenames, counts, etc.)';
COMMENT ON COLUMN public.system_logs.backup_size_bytes IS 'Size of backup file in bytes (if applicable)';
COMMENT ON COLUMN public.system_logs.error_message IS 'Error details if event_type indicates failure';
