-- Migration: Add RLS Policies for new tables
-- Created: 2025-10-26
-- Description: Enable RLS and create security policies for motivational_phrases and user_metrics

-- Enable RLS on motivational_phrases table
ALTER TABLE public.motivational_phrases ENABLE ROW LEVEL SECURITY;

-- Enable RLS on user_metrics table
ALTER TABLE public.user_metrics ENABLE ROW LEVEL SECURITY;

-- ========================================
-- MOTIVATIONAL_PHRASES POLICIES
-- ========================================

-- Allow public read access to all motivational phrases
CREATE POLICY "Anyone can view motivational phrases"
ON public.motivational_phrases
FOR SELECT
USING (true);

-- Only admins can insert motivational phrases (service_role)
CREATE POLICY "Service role can insert motivational phrases"
ON public.motivational_phrases
FOR INSERT
WITH CHECK (auth.role() = 'service_role');

-- Only admins can update motivational phrases
CREATE POLICY "Service role can update motivational phrases"
ON public.motivational_phrases
FOR UPDATE
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- Only admins can delete motivational phrases
CREATE POLICY "Service role can delete motivational phrases"
ON public.motivational_phrases
FOR DELETE
USING (auth.role() = 'service_role');

-- ========================================
-- USER_METRICS POLICIES
-- ========================================

-- Users can view their own metrics
CREATE POLICY "Users can view own metrics"
ON public.user_metrics
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own metrics (auto-created on first fast)
CREATE POLICY "Users can insert own metrics"
ON public.user_metrics
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own metrics
CREATE POLICY "Users can update own metrics"
ON public.user_metrics
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own metrics
CREATE POLICY "Users can delete own metrics"
ON public.user_metrics
FOR DELETE
USING (auth.uid() = user_id);

-- Service role has full access to user_metrics for admin operations
CREATE POLICY "Service role can manage all user metrics"
ON public.user_metrics
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- ========================================
-- COMMENTS
-- ========================================

COMMENT ON POLICY "Anyone can view motivational phrases" ON public.motivational_phrases IS 'Public read access for all users';
COMMENT ON POLICY "Users can view own metrics" ON public.user_metrics IS 'Users can only view their own aggregated metrics';
