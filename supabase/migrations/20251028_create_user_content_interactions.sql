-- Migration: Create user_content_interactions table
-- Created: 2025-10-28
-- Description: Implements user content interaction tracking with automatic popularity metrics
-- Task: 69 - Create user_content_interactions table for tracking educational content interactions

-- ========================================
-- STEP 1: Add popularity fields to learning_content table
-- ========================================

ALTER TABLE public.learning_content
ADD COLUMN IF NOT EXISTS popularity_score NUMERIC(10, 2) DEFAULT 0 NOT NULL,
ADD COLUMN IF NOT EXISTS interaction_count INTEGER DEFAULT 0 NOT NULL;

CREATE INDEX IF NOT EXISTS idx_learning_content_popularity
ON public.learning_content(popularity_score DESC);

COMMENT ON COLUMN public.learning_content.popularity_score IS 'Calculated popularity score based on user interactions (views×1 + favorites×3 + shares×5 + completions×2)';
COMMENT ON COLUMN public.learning_content.interaction_count IS 'Total count of all user interactions (excluding soft-deleted)';

-- ========================================
-- STEP 2: Create ENUM type for interaction types
-- ========================================

DO $$ BEGIN
    CREATE TYPE interaction_type_enum AS ENUM ('viewed', 'favorited', 'shared', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

COMMENT ON TYPE interaction_type_enum IS 'Types of user interactions with educational content';

-- ========================================
-- STEP 3: Create user_content_interactions table (Subtask 69.1)
-- ========================================

CREATE TABLE IF NOT EXISTS public.user_content_interactions (
    interaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_id UUID NOT NULL REFERENCES public.learning_content(id) ON DELETE CASCADE,
    interaction_type interaction_type_enum NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    time_spent_seconds INTEGER,
    progress_percentage INTEGER,
    deleted_at TIMESTAMPTZ,

    -- Unique constraint to prevent duplicate interaction types per user/content pair
    CONSTRAINT unique_user_content_interaction UNIQUE(user_id, content_id, interaction_type),

    -- Validation constraints
    CONSTRAINT check_progress_percentage CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT check_time_spent_seconds CHECK (time_spent_seconds >= 0)
);

COMMENT ON TABLE public.user_content_interactions IS 'Tracks user interactions with educational content including views, favorites, shares, and completions';
COMMENT ON COLUMN public.user_content_interactions.interaction_id IS 'Unique identifier for the interaction record';
COMMENT ON COLUMN public.user_content_interactions.user_id IS 'User who performed the interaction';
COMMENT ON COLUMN public.user_content_interactions.content_id IS 'Learning content that was interacted with';
COMMENT ON COLUMN public.user_content_interactions.interaction_type IS 'Type of interaction: viewed, favorited, shared, or completed';
COMMENT ON COLUMN public.user_content_interactions.timestamp IS 'When the interaction occurred';
COMMENT ON COLUMN public.user_content_interactions.time_spent_seconds IS 'Duration of interaction in seconds (for viewed/completed)';
COMMENT ON COLUMN public.user_content_interactions.progress_percentage IS 'Completion percentage (0-100) for content progress tracking';
COMMENT ON COLUMN public.user_content_interactions.deleted_at IS 'Soft delete timestamp - when set, interaction is excluded from metrics but preserved for analytics';

-- ========================================
-- STEP 4: Create composite indexes (Subtask 69.2)
-- ========================================

-- Index for querying user's interactions by type
CREATE INDEX IF NOT EXISTS idx_user_content_interactions_user_type
ON public.user_content_interactions(user_id, interaction_type)
WHERE deleted_at IS NULL;

-- Index for querying content's interactions by type
CREATE INDEX IF NOT EXISTS idx_user_content_interactions_content_type
ON public.user_content_interactions(content_id, interaction_type)
WHERE deleted_at IS NULL;

-- Index for time-based queries (most recent interactions)
CREATE INDEX IF NOT EXISTS idx_user_content_interactions_timestamp
ON public.user_content_interactions(timestamp DESC)
WHERE deleted_at IS NULL;

-- Additional index for soft delete filtering
CREATE INDEX IF NOT EXISTS idx_user_content_interactions_deleted_at
ON public.user_content_interactions(deleted_at)
WHERE deleted_at IS NOT NULL;

-- ========================================
-- STEP 5: Enable RLS and create security policies (Subtask 69.2)
-- ========================================

ALTER TABLE public.user_content_interactions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own interactions
CREATE POLICY "Users can view own content interactions"
ON public.user_content_interactions
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can create their own interactions
CREATE POLICY "Users can insert own content interactions"
ON public.user_content_interactions
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own interactions
CREATE POLICY "Users can update own content interactions"
ON public.user_content_interactions
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own interactions (soft delete by setting deleted_at)
CREATE POLICY "Users can delete own content interactions"
ON public.user_content_interactions
FOR DELETE
USING (auth.uid() = user_id);

-- Policy: Service role has full access for admin operations
CREATE POLICY "Service role can manage all content interactions"
ON public.user_content_interactions
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

COMMENT ON POLICY "Users can view own content interactions" ON public.user_content_interactions IS 'Users can only view their own interaction records';
COMMENT ON POLICY "Users can insert own content interactions" ON public.user_content_interactions IS 'Users can only create interactions for themselves';
COMMENT ON POLICY "Users can update own content interactions" ON public.user_content_interactions IS 'Users can only update their own interactions (e.g., progress updates)';
COMMENT ON POLICY "Users can delete own content interactions" ON public.user_content_interactions IS 'Users can soft delete their own interactions';

-- ========================================
-- STEP 6: Create trigger function for automatic popularity updates (Subtask 69.3)
-- ========================================

CREATE OR REPLACE FUNCTION update_content_popularity_metrics()
RETURNS TRIGGER AS $$
DECLARE
    affected_content_id UUID;
    view_count INTEGER;
    favorite_count INTEGER;
    share_count INTEGER;
    completion_count INTEGER;
    calculated_popularity NUMERIC(10, 2);
    total_interactions INTEGER;
BEGIN
    -- Determine which content_id was affected
    IF TG_OP = 'DELETE' THEN
        affected_content_id := OLD.content_id;
    ELSE
        affected_content_id := NEW.content_id;
    END IF;

    -- Count interactions by type for this content (excluding soft-deleted)
    SELECT
        COUNT(*) FILTER (WHERE interaction_type = 'viewed') AS views,
        COUNT(*) FILTER (WHERE interaction_type = 'favorited') AS favorites,
        COUNT(*) FILTER (WHERE interaction_type = 'shared') AS shares,
        COUNT(*) FILTER (WHERE interaction_type = 'completed') AS completions,
        COUNT(*) AS total
    INTO view_count, favorite_count, share_count, completion_count, total_interactions
    FROM public.user_content_interactions
    WHERE content_id = affected_content_id
      AND deleted_at IS NULL;

    -- Calculate popularity score using the formula:
    -- views × 1 + favorites × 3 + shares × 5 + completions × 2
    calculated_popularity := (
        (COALESCE(view_count, 0) * 1) +
        (COALESCE(favorite_count, 0) * 3) +
        (COALESCE(share_count, 0) * 5) +
        (COALESCE(completion_count, 0) * 2)
    );

    -- Update the learning_content table with new metrics
    UPDATE public.learning_content
    SET
        popularity_score = calculated_popularity,
        interaction_count = total_interactions,
        updated_at = NOW()
    WHERE id = affected_content_id;

    -- Return appropriate value based on operation
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_content_popularity_metrics() IS 'Automatically updates learning_content popularity_score and interaction_count when user_content_interactions changes. Formula: views×1 + favorites×3 + shares×5 + completions×2';

-- ========================================
-- STEP 7: Create trigger on user_content_interactions (Subtask 69.3)
-- ========================================

DROP TRIGGER IF EXISTS trigger_update_content_popularity_metrics ON public.user_content_interactions;

CREATE TRIGGER trigger_update_content_popularity_metrics
AFTER INSERT OR UPDATE OR DELETE ON public.user_content_interactions
FOR EACH ROW
EXECUTE FUNCTION update_content_popularity_metrics();

COMMENT ON TRIGGER trigger_update_content_popularity_metrics ON public.user_content_interactions IS 'Fires after any interaction insert/update/delete to recalculate content popularity metrics';

-- ========================================
-- HELPER FUNCTION: Soft delete interactions
-- ========================================

CREATE OR REPLACE FUNCTION soft_delete_interaction(p_interaction_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    rows_affected INTEGER;
BEGIN
    UPDATE public.user_content_interactions
    SET deleted_at = NOW()
    WHERE interaction_id = p_interaction_id
      AND user_id = auth.uid()
      AND deleted_at IS NULL;

    GET DIAGNOSTICS rows_affected = ROW_COUNT;

    RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION soft_delete_interaction(UUID) IS 'Helper function to soft delete an interaction by setting deleted_at timestamp. Returns true if successful, false if not found or already deleted.';

-- ========================================
-- HELPER FUNCTION: Get content popularity breakdown
-- ========================================

CREATE OR REPLACE FUNCTION get_content_popularity_breakdown(p_content_id UUID)
RETURNS TABLE(
    content_id UUID,
    view_count BIGINT,
    favorite_count BIGINT,
    share_count BIGINT,
    completion_count BIGINT,
    total_interactions BIGINT,
    popularity_score NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p_content_id,
        COUNT(*) FILTER (WHERE interaction_type = 'viewed'),
        COUNT(*) FILTER (WHERE interaction_type = 'favorited'),
        COUNT(*) FILTER (WHERE interaction_type = 'shared'),
        COUNT(*) FILTER (WHERE interaction_type = 'completed'),
        COUNT(*),
        (
            (COUNT(*) FILTER (WHERE interaction_type = 'viewed') * 1) +
            (COUNT(*) FILTER (WHERE interaction_type = 'favorited') * 3) +
            (COUNT(*) FILTER (WHERE interaction_type = 'shared') * 5) +
            (COUNT(*) FILTER (WHERE interaction_type = 'completed') * 2)
        )::NUMERIC(10, 2)
    FROM public.user_content_interactions
    WHERE content_id = p_content_id
      AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_content_popularity_breakdown(UUID) IS 'Returns detailed breakdown of interactions and calculated popularity score for a specific content item';

-- ========================================
-- MIGRATION COMPLETE
-- ========================================

-- Grant necessary permissions
GRANT SELECT ON public.user_content_interactions TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.user_content_interactions TO authenticated;
GRANT EXECUTE ON FUNCTION soft_delete_interaction(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_content_popularity_breakdown(UUID) TO anon, authenticated;
