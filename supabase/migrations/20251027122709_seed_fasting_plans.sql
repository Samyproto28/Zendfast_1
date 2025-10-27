-- Migration: Seed fasting_plans table
-- Created: 2025-10-27
-- Description: Creates fasting_plans table and seeds with 7 predefined plans including carnivore detox

-- ========================================
-- TABLE: fasting_plans
-- ========================================

-- Create fasting_plans table with comprehensive schema
CREATE TABLE IF NOT EXISTS public.fasting_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_name TEXT NOT NULL UNIQUE,
    fasting_hours INT NOT NULL,
    eating_hours INT NOT NULL,
    description TEXT,
    difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    recommended_for TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add table and column comments for documentation
COMMENT ON TABLE public.fasting_plans IS 'Predefined fasting plans available in the app';
COMMENT ON COLUMN public.fasting_plans.id IS 'Unique identifier for the fasting plan';
COMMENT ON COLUMN public.fasting_plans.plan_name IS 'Display name of the fasting plan (e.g., 12/12, 16/8)';
COMMENT ON COLUMN public.fasting_plans.fasting_hours IS 'Duration of fasting window in hours';
COMMENT ON COLUMN public.fasting_plans.eating_hours IS 'Duration of eating window in hours';
COMMENT ON COLUMN public.fasting_plans.description IS 'Detailed description of the plan in Spanish';
COMMENT ON COLUMN public.fasting_plans.difficulty_level IS 'Difficulty level: beginner, intermediate, or advanced';
COMMENT ON COLUMN public.fasting_plans.recommended_for IS 'What this plan is recommended for (e.g., fat loss, autophagy)';
COMMENT ON COLUMN public.fasting_plans.is_default IS 'Whether this is the default plan for new users';

-- Create index for common queries
CREATE INDEX IF NOT EXISTS idx_fasting_plans_difficulty ON public.fasting_plans(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_fasting_plans_default ON public.fasting_plans(is_default) WHERE is_default = true;

-- ========================================
-- SEED DATA: 7 Fasting Plans
-- ========================================

INSERT INTO public.fasting_plans (
    plan_name,
    fasting_hours,
    eating_hours,
    description,
    difficulty_level,
    recommended_for,
    is_default
) VALUES
-- Plan 1: 12/12 (Beginner - Default)
(
    '12/12',
    12,
    12,
    'Plan principiante: ayuna 12 horas, come 12 horas. Ideal para alineación del ritmo circadiano.',
    'beginner',
    'Alineación del ritmo circadiano',
    true
),
-- Plan 2: 14/10 (Beginner)
(
    '14/10',
    14,
    10,
    'Paso intermedio: ayuna 14 horas, come 10 horas. Suave entrada a la quema de grasa.',
    'beginner',
    'Quema suave de grasa',
    false
),
-- Plan 3: 16/8 (Intermediate - Most Popular)
(
    '16/8',
    16,
    8,
    'Más popular: ayuna 16 horas, come 8 horas. Equilibrio perfecto entre pérdida de grasa y autofagia.',
    'intermediate',
    'Pérdida de grasa y autofagia',
    false
),
-- Plan 4: 18/6 (Advanced)
(
    '18/6',
    18,
    6,
    'Avanzado: ayuna 18 horas, come 6 horas. Cetosis profunda y mayor autofagia.',
    'advanced',
    'Cetosis profunda',
    false
),
-- Plan 5: 24h OMAD (Advanced)
(
    '24h',
    24,
    0,
    'OMAD (Una Comida Al Día): ayuno de 24 horas. Máxima autofagia y regeneración celular.',
    'advanced',
    'Máxima autofagia',
    false
),
-- Plan 6: 48h Extended Fast (Advanced)
(
    '48h',
    48,
    0,
    'Ayuno extendido: 48 horas solo agua. Reparación celular profunda y renovación.',
    'advanced',
    'Reparación celular',
    false
),
-- Plan 7: Desintoxicación 48h Carnívoro (Beginner)
(
    'Desintoxicación 48h',
    48,
    0,
    'Plan carnívoro de 48h: solo carne, huevos, pescado, sal y agua. Elimina antojos de azúcar antes del ayuno intermitente.',
    'beginner',
    'Reducción de antojos de azúcar',
    false
)
ON CONFLICT (plan_name)
DO UPDATE SET
    fasting_hours = EXCLUDED.fasting_hours,
    eating_hours = EXCLUDED.eating_hours,
    description = EXCLUDED.description,
    difficulty_level = EXCLUDED.difficulty_level,
    recommended_for = EXCLUDED.recommended_for,
    is_default = EXCLUDED.is_default,
    updated_at = NOW();

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

-- Enable RLS on fasting_plans table
ALTER TABLE public.fasting_plans ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access (reference data)
CREATE POLICY "Anyone can view fasting plans"
ON public.fasting_plans
FOR SELECT
USING (true);

-- Service role can manage fasting plans
CREATE POLICY "Service role can manage fasting plans"
ON public.fasting_plans
FOR ALL
USING (auth.jwt() ->> 'role' = 'service_role');

COMMENT ON POLICY "Anyone can view fasting plans" ON public.fasting_plans IS
'Allows public read access to fasting plans - they are reference data';

-- ========================================
-- TRIGGER: Auto-update updated_at
-- ========================================

-- Create or replace the trigger function for updated_at
CREATE OR REPLACE FUNCTION update_fasting_plans_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS trigger_update_fasting_plans_timestamp ON public.fasting_plans;
CREATE TRIGGER trigger_update_fasting_plans_timestamp
BEFORE UPDATE ON public.fasting_plans
FOR EACH ROW
EXECUTE FUNCTION update_fasting_plans_timestamp();

COMMENT ON FUNCTION update_fasting_plans_timestamp() IS
'Automatically updates the updated_at timestamp for fasting_plans table';
