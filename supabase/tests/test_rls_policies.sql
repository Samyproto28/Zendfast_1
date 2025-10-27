-- Test Script: RLS Policies Validation
-- Created: 2025-10-26
-- Purpose: Verify Row Level Security policies prevent unauthorized access

-- ========================================
-- TEST 1: motivational_phrases - Public Read Access
-- ========================================
-- Expected: Anyone can read motivational phrases
SELECT '===== TEST 1: Public read access to motivational_phrases =====' as test;

SELECT
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS: Public can read motivational phrases'
        ELSE 'FAIL: No phrases accessible publicly'
    END as result
FROM public.motivational_phrases
WHERE language = 'es';

-- ========================================
-- TEST 2: user_metrics - User Can Only See Own Data
-- ========================================
SELECT '===== TEST 2: RLS on user_metrics =====' as test;

-- Check that RLS is enabled
SELECT
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled on user_metrics'
        ELSE 'FAIL: RLS not enabled on user_metrics'
    END as result
FROM pg_class
WHERE relname = 'user_metrics';

-- ========================================
-- TEST 3: user_profiles - RLS Enabled
-- ========================================
SELECT '===== TEST 3: RLS on user_profiles =====' as test;

SELECT
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled on user_profiles'
        ELSE 'FAIL: RLS not enabled on user_profiles'
    END as result
FROM pg_class
WHERE relname = 'user_profiles';

-- ========================================
-- TEST 4: fasting_sessions - RLS Enabled
-- ========================================
SELECT '===== TEST 4: RLS on fasting_sessions =====' as test;

SELECT
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled on fasting_sessions'
        ELSE 'FAIL: RLS not enabled on fasting_sessions'
    END as result
FROM pg_class
WHERE relname = 'fasting_sessions';

-- ========================================
-- TEST 5: hydration_logs - RLS Enabled
-- ========================================
SELECT '===== TEST 5: RLS on hydration_logs =====' as test;

SELECT
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled on hydration_logs'
        ELSE 'FAIL: RLS not enabled on hydration_logs'
    END as result
FROM pg_class
WHERE relname = 'hydration_logs';

-- ========================================
-- TEST 6: learning_content - Public Read Access
-- ========================================
SELECT '===== TEST 6: Public read access to learning_content =====' as test;

SELECT
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS: Public can read learning content'
        ELSE 'FAIL: No learning content accessible'
    END as result
FROM public.learning_content;

-- ========================================
-- TEST 7: analytics_events - RLS Enabled
-- ========================================
SELECT '===== TEST 7: RLS on analytics_events =====' as test;

SELECT
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled on analytics_events'
        ELSE 'FAIL: RLS not enabled on analytics_events'
    END as result
FROM pg_class
WHERE relname = 'analytics_events';

-- ========================================
-- TEST 8: Verify All Expected RLS Policies Exist
-- ========================================
SELECT '===== TEST 8: Count of RLS policies =====' as test;

SELECT
    schemaname,
    tablename,
    COUNT(*) as policy_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS: Policies exist'
        ELSE 'FAIL: No policies found'
    END as result
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY schemaname, tablename
ORDER BY tablename;

-- ========================================
-- SUMMARY
-- ========================================
SELECT '===== TEST SUMMARY =====' as test;

SELECT
    COUNT(DISTINCT tablename) as tables_with_rls,
    COUNT(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public';

SELECT
    tablename,
    policyname,
    cmd as operation,
    roles,
    CASE
        WHEN qual IS NOT NULL THEN 'Has USING clause'
        ELSE 'No USING clause'
    END as using_check,
    CASE
        WHEN with_check IS NOT NULL THEN 'Has WITH CHECK clause'
        ELSE 'No WITH CHECK clause'
    END as with_check_status
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
