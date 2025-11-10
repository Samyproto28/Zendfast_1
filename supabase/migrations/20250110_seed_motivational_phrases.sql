-- Migration: Seed initial motivational phrases
-- Date: 2025-01-10
-- Description: Insert 6 initial motivational phrases for panic modal

-- Insert initial motivational phrases
INSERT INTO public.motivational_phrases (text, subtitle, icon_name, category, order_index, is_active)
VALUES
  (
    'Eres más fuerte de lo que crees',
    'Confía en ti mismo',
    'favorite',
    'motivation',
    0,
    TRUE
  ),
  (
    'Bebe agua lentamente',
    'Hidratación consciente',
    'water_drop',
    'anti_binge',
    1,
    TRUE
  ),
  (
    'Toma 5 respiraciones profundas',
    'Técnica 4-7-8',
    'air',
    'calm',
    2,
    TRUE
  ),
  (
    'Sal a caminar 5 minutos',
    'Movimiento consciente',
    'directions_walk',
    'calm',
    3,
    TRUE
  ),
  (
    'Llama a un amigo',
    'Apoyo social',
    'phone',
    'motivation',
    4,
    TRUE
  ),
  (
    'Medita 5 minutos',
    'Ejercicio de respiración guiada',
    'self_improvement',
    'calm',
    5,
    TRUE
  )
ON CONFLICT DO NOTHING;

-- Verify data was inserted
DO $$
DECLARE
  phrase_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO phrase_count FROM public.motivational_phrases;
  RAISE NOTICE 'Total motivational phrases in database: %', phrase_count;

  IF phrase_count >= 6 THEN
    RAISE NOTICE 'Seed data successfully inserted!';
  ELSE
    RAISE WARNING 'Expected at least 6 phrases, found %', phrase_count;
  END IF;
END $$;
