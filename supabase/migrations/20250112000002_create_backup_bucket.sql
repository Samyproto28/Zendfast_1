-- Create Supabase Storage bucket for encrypted backups
-- Migration: 20250112000002
-- Purpose: Configure storage bucket for daily backup files with proper RLS policies

-- Create the backups storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'backups',
    'backups',
    false,  -- Private bucket
    104857600,  -- 100MB file size limit
    ARRAY['application/octet-stream']  -- Encrypted files are binary
)
ON CONFLICT (id) DO UPDATE
SET
    public = false,
    file_size_limit = 104857600,
    allowed_mime_types = ARRAY['application/octet-stream'];

-- Enable RLS on storage.objects for this bucket
-- (RLS is enabled by default, but we make it explicit)

-- Policy: Only service role can upload to backups bucket
CREATE POLICY "Service role can upload backups"
    ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'backups'
        AND auth.role() = 'service_role'
    );

-- Policy: Only service role can read from backups bucket
CREATE POLICY "Service role can read backups"
    ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'backups'
        AND auth.role() = 'service_role'
    );

-- Policy: Only service role can delete from backups bucket (for retention cleanup)
CREATE POLICY "Service role can delete old backups"
    ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'backups'
        AND auth.role() = 'service_role'
    );

-- Policy: Only service role can update backup metadata
CREATE POLICY "Service role can update backup metadata"
    ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'backups'
        AND auth.role() = 'service_role'
    )
    WITH CHECK (
        bucket_id = 'backups'
        AND auth.role() = 'service_role'
    );

-- Add helpful comment
COMMENT ON COLUMN storage.buckets.id IS 'Bucket ID - backups bucket stores encrypted daily backup files';
