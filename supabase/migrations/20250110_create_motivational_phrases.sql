-- Migration: Create motivational_phrases table for panic modal
-- Date: 2025-01-10
-- Description: Table to store motivational phrases shown in panic modal during difficult fasting moments

-- Create motivational_phrases table
CREATE TABLE IF NOT EXISTS public.motivational_phrases (
  id SERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  subtitle TEXT,
  icon_name TEXT NOT NULL,
  category TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_motivational_phrases_category ON public.motivational_phrases(category);
CREATE INDEX idx_motivational_phrases_is_active ON public.motivational_phrases(is_active);
CREATE INDEX idx_motivational_phrases_order_index ON public.motivational_phrases(order_index);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_motivational_phrases_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_motivational_phrases_updated_at
  BEFORE UPDATE ON public.motivational_phrases
  FOR EACH ROW
  EXECUTE FUNCTION public.update_motivational_phrases_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE public.motivational_phrases ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Anyone can read active motivational phrases
CREATE POLICY "Anyone can read active motivational phrases"
  ON public.motivational_phrases
  FOR SELECT
  USING (is_active = TRUE);

-- RLS Policy: Only authenticated users can view inactive phrases (for admin purposes)
CREATE POLICY "Authenticated users can read all motivational phrases"
  ON public.motivational_phrases
  FOR SELECT
  TO authenticated
  USING (TRUE);

-- RLS Policy: Only service role can insert/update/delete phrases
CREATE POLICY "Service role can manage motivational phrases"
  ON public.motivational_phrases
  FOR ALL
  TO service_role
  USING (TRUE)
  WITH CHECK (TRUE);

-- Add comments for documentation
COMMENT ON TABLE public.motivational_phrases IS 'Motivational phrases displayed in panic modal to provide emotional support during fasting';
COMMENT ON COLUMN public.motivational_phrases.id IS 'Unique identifier for the phrase';
COMMENT ON COLUMN public.motivational_phrases.text IS 'Main text of the motivational phrase';
COMMENT ON COLUMN public.motivational_phrases.subtitle IS 'Optional subtitle or additional context';
COMMENT ON COLUMN public.motivational_phrases.icon_name IS 'Material Icons name to display with the phrase';
COMMENT ON COLUMN public.motivational_phrases.category IS 'Category for filtering: motivation, anti_binge, calm';
COMMENT ON COLUMN public.motivational_phrases.order_index IS 'Order in which phrases should be displayed';
COMMENT ON COLUMN public.motivational_phrases.is_active IS 'Whether the phrase is active and should be shown to users';
COMMENT ON COLUMN public.motivational_phrases.created_at IS 'Timestamp when the phrase was created';
COMMENT ON COLUMN public.motivational_phrases.updated_at IS 'Timestamp when the phrase was last updated';
