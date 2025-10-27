-- Migration: Add missing tables and columns
-- Created: 2025-10-26
-- Description: Adds motivational_phrases and user_metrics tables, plus daily_hydration_goal column

-- Add daily_hydration_goal to user_profiles table
ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS daily_hydration_goal INTEGER DEFAULT 2000;

COMMENT ON COLUMN public.user_profiles.daily_hydration_goal IS 'Daily hydration goal in milliliters';

-- Create motivational_phrases table
CREATE TABLE IF NOT EXISTS public.motivational_phrases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phrase_text TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('inicio_ayuno', 'durante_ayuno', 'finalizacion_ayuno', 'general', 'hidratacion', 'mindfulness')),
    language TEXT NOT NULL DEFAULT 'es' CHECK (language IN ('es', 'en')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_motivational_phrases_category ON public.motivational_phrases(category);
CREATE INDEX IF NOT EXISTS idx_motivational_phrases_language ON public.motivational_phrases(language);

COMMENT ON TABLE public.motivational_phrases IS 'Motivational phrases for users during fasting journey';
COMMENT ON COLUMN public.motivational_phrases.category IS 'Category of the phrase (inicio_ayuno, durante_ayuno, finalizacion_ayuno, general, hidratacion, mindfulness)';

-- Create user_metrics table
CREATE TABLE IF NOT EXISTS public.user_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_fasts INTEGER NOT NULL DEFAULT 0,
    total_duration_hours NUMERIC(10, 2) NOT NULL DEFAULT 0,
    streak_days INTEGER NOT NULL DEFAULT 0,
    last_fast_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create indexes for user_metrics
CREATE INDEX IF NOT EXISTS idx_user_metrics_user_id ON public.user_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_user_metrics_last_fast_date ON public.user_metrics(last_fast_date);

COMMENT ON TABLE public.user_metrics IS 'Aggregated metrics and statistics for each user';
COMMENT ON COLUMN public.user_metrics.total_fasts IS 'Total number of completed fasts';
COMMENT ON COLUMN public.user_metrics.total_duration_hours IS 'Total fasting duration in hours';
COMMENT ON COLUMN public.user_metrics.streak_days IS 'Current fasting streak in days';
COMMENT ON COLUMN public.user_metrics.last_fast_date IS 'Date of the most recent completed fast';
