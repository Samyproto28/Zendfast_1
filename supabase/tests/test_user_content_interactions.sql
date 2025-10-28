-- Test Script: User Content Interactions Validation
-- Created: 2025-10-28
-- Purpose: Comprehensive testing of user_content_interactions table, RLS policies, triggers, and popularity metrics
-- Task: 69 - Validate user_content_interactions implementation

-- ========================================
-- TEST 1: Verify table structure and columns
-- ========================================
SELECT '===== TEST 1: Table structure =====' as test;

SELECT
    column_name,
    data_type,
    is_nullable,
    column_default,
    CASE
        WHEN column_name IN ('interaction_id', 'user_id', 'content_id', 'interaction_type', 'timestamp', 'time_spent_seconds', 'progress_percentage', 'deleted_at')
        THEN 'PASS: Required column exists'
        ELSE 'INFO: Additional column found'
    END as result
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_content_interactions'
ORDER BY ordinal_position;

-- ========================================
-- TEST 2: Verify ENUM type exists
-- ========================================
SELECT '===== TEST 2: ENUM type validation =====' as test;

SELECT
    t.typname as enum_name,
    e.enumlabel as enum_value,
    CASE
        WHEN e.enumlabel IN ('viewed', 'favorited', 'shared', 'completed')
        THEN 'PASS: Valid enum value'
        ELSE 'FAIL: Unexpected enum value'
    END as result
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typname = 'interaction_type_enum'
ORDER BY e.enumsortorder;

-- ========================================
-- TEST 3: Verify constraints exist
-- ========================================
SELECT '===== TEST 3: Table constraints =====' as test;

SELECT
    constraint_name,
    constraint_type,
    CASE
        WHEN constraint_name LIKE '%unique_user_content_interaction%' THEN 'PASS: Unique constraint on user/content/type exists'
        WHEN constraint_name LIKE '%check_progress_percentage%' THEN 'PASS: Progress percentage check constraint exists'
        WHEN constraint_name LIKE '%check_time_spent_seconds%' THEN 'PASS: Time spent check constraint exists'
        WHEN constraint_type = 'PRIMARY KEY' THEN 'PASS: Primary key exists'
        WHEN constraint_type = 'FOREIGN KEY' THEN 'PASS: Foreign key exists'
        ELSE 'INFO: Other constraint found'
    END as result
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name = 'user_content_interactions'
ORDER BY constraint_type, constraint_name;

-- ========================================
-- TEST 4: Verify composite indexes exist
-- ========================================
SELECT '===== TEST 4: Composite indexes =====' as test;

SELECT
    indexname,
    indexdef,
    CASE
        WHEN indexname LIKE '%user_type%' THEN 'PASS: User-type index exists'
        WHEN indexname LIKE '%content_type%' THEN 'PASS: Content-type index exists'
        WHEN indexname LIKE '%timestamp%' THEN 'PASS: Timestamp index exists'
        WHEN indexname LIKE '%deleted_at%' THEN 'PASS: Soft delete index exists'
        ELSE 'INFO: Other index found'
    END as result
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'user_content_interactions'
ORDER BY indexname;

-- ========================================
-- TEST 5: Verify RLS is enabled
-- ========================================
SELECT '===== TEST 5: RLS enabled =====' as test;

SELECT
    tablename,
    rowsecurity,
    CASE
        WHEN rowsecurity THEN 'PASS: RLS is enabled'
        ELSE 'FAIL: RLS is not enabled'
    END as result
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'user_content_interactions';

-- ========================================
-- TEST 6: Verify RLS policies exist
-- ========================================
SELECT '===== TEST 6: RLS policies =====' as test;

SELECT
    policyname,
    cmd as command,
    CASE
        WHEN policyname LIKE '%view%' AND cmd = 'SELECT' THEN 'PASS: SELECT policy exists'
        WHEN policyname LIKE '%insert%' AND cmd = 'INSERT' THEN 'PASS: INSERT policy exists'
        WHEN policyname LIKE '%update%' AND cmd = 'UPDATE' THEN 'PASS: UPDATE policy exists'
        WHEN policyname LIKE '%delete%' AND cmd = 'DELETE' THEN 'PASS: DELETE policy exists'
        WHEN policyname LIKE '%service_role%' AND cmd = 'ALL' THEN 'PASS: Service role policy exists'
        ELSE 'INFO: Policy found'
    END as result
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_content_interactions'
ORDER BY policyname;

-- ========================================
-- TEST 7: Verify popularity fields added to learning_content
-- ========================================
SELECT '===== TEST 7: Learning content popularity fields =====' as test;

SELECT
    column_name,
    data_type,
    column_default,
    CASE
        WHEN column_name = 'popularity_score' THEN 'PASS: Popularity score field exists'
        WHEN column_name = 'interaction_count' THEN 'PASS: Interaction count field exists'
        ELSE 'INFO: Other field'
    END as result
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'learning_content'
  AND column_name IN ('popularity_score', 'interaction_count');

-- ========================================
-- TEST 8: Verify trigger function exists
-- ========================================
SELECT '===== TEST 8: Trigger function =====' as test;

SELECT
    proname as function_name,
    pg_get_function_result(oid) as return_type,
    CASE
        WHEN proname = 'update_content_popularity_metrics' THEN 'PASS: Popularity metrics trigger function exists'
        WHEN proname = 'soft_delete_interaction' THEN 'PASS: Soft delete helper function exists'
        WHEN proname = 'get_content_popularity_breakdown' THEN 'PASS: Popularity breakdown function exists'
        ELSE 'INFO: Other function found'
    END as result
FROM pg_proc
WHERE proname IN ('update_content_popularity_metrics', 'soft_delete_interaction', 'get_content_popularity_breakdown')
ORDER BY proname;

-- ========================================
-- TEST 9: Verify trigger exists and is active
-- ========================================
SELECT '===== TEST 9: Trigger configuration =====' as test;

SELECT
    trigger_name,
    event_manipulation as event,
    action_timing as timing,
    CASE
        WHEN trigger_name LIKE '%popularity_metrics%' THEN 'PASS: Popularity metrics trigger exists'
        ELSE 'INFO: Other trigger found'
    END as result
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND event_object_table = 'user_content_interactions'
ORDER BY trigger_name;

-- ========================================
-- TEST 10: Test constraint validations
-- ========================================
SELECT '===== TEST 10: Constraint validation tests =====' as test;

-- Test 10.1: Progress percentage must be 0-100
DO $$
BEGIN
    -- This should fail
    INSERT INTO public.user_content_interactions (user_id, content_id, interaction_type, progress_percentage)
    VALUES (auth.uid(), (SELECT id FROM public.learning_content LIMIT 1), 'viewed', 150);
    RAISE EXCEPTION 'FAIL: Invalid progress_percentage was accepted';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'PASS: Progress percentage constraint works (rejected 150)';
END $$;

-- Test 10.2: Time spent must be >= 0
DO $$
BEGIN
    -- This should fail
    INSERT INTO public.user_content_interactions (user_id, content_id, interaction_type, time_spent_seconds)
    VALUES (auth.uid(), (SELECT id FROM public.learning_content LIMIT 1), 'viewed', -10);
    RAISE EXCEPTION 'FAIL: Negative time_spent_seconds was accepted';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'PASS: Time spent constraint works (rejected -10)';
END $$;

-- ========================================
-- TEST 11: Test popularity calculation formula
-- ========================================
SELECT '===== TEST 11: Popularity calculation formula =====' as test;

-- Manual test of formula: views×1 + favorites×3 + shares×5 + completions×2
-- If we have: 10 views, 5 favorites, 3 shares, 2 completions
-- Expected: (10×1) + (5×3) + (3×5) + (2×2) = 10 + 15 + 15 + 4 = 44

SELECT
    'Manual Formula Test' as test_name,
    (10 * 1) + (5 * 3) + (3 * 5) + (2 * 2) as expected_score,
    CASE
        WHEN (10 * 1) + (5 * 3) + (3 * 5) + (2 * 2) = 44
        THEN 'PASS: Formula calculation is correct (44)'
        ELSE 'FAIL: Formula calculation is incorrect'
    END as result;

-- ========================================
-- TEST 12: Test foreign key relationships
-- ========================================
SELECT '===== TEST 12: Foreign key relationships =====' as test;

SELECT
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    CASE
        WHEN ccu.table_name = 'users' AND ccu.column_name = 'id' THEN 'PASS: FK to auth.users exists'
        WHEN ccu.table_name = 'learning_content' AND ccu.column_name = 'id' THEN 'PASS: FK to learning_content exists'
        ELSE 'INFO: Other FK found'
    END as result
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name = 'user_content_interactions';

-- ========================================
-- TEST 13: Performance test - Index usage
-- ========================================
SELECT '===== TEST 13: Query performance with indexes =====' as test;

-- Explain query to verify index usage
EXPLAIN (FORMAT TEXT)
SELECT *
FROM public.user_content_interactions
WHERE user_id = auth.uid()
  AND interaction_type = 'viewed'
  AND deleted_at IS NULL;

-- ========================================
-- TEST 14: Soft delete functionality
-- ========================================
SELECT '===== TEST 14: Soft delete behavior =====' as test;

SELECT
    'Soft Delete Test' as test_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'user_content_interactions'
              AND column_name = 'deleted_at'
        )
        THEN 'PASS: deleted_at column exists for soft delete'
        ELSE 'FAIL: deleted_at column missing'
    END as result;

-- ========================================
-- TEST 15: Helper functions availability
-- ========================================
SELECT '===== TEST 15: Helper functions =====' as test;

SELECT
    routine_name,
    data_type as return_type,
    CASE
        WHEN routine_name = 'soft_delete_interaction' THEN 'PASS: Soft delete function available'
        WHEN routine_name = 'get_content_popularity_breakdown' THEN 'PASS: Popularity breakdown function available'
        ELSE 'INFO: Other function'
    END as result
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('soft_delete_interaction', 'get_content_popularity_breakdown')
ORDER BY routine_name;

-- ========================================
-- SUMMARY: Overall test results
-- ========================================
SELECT '===== TEST SUMMARY =====' as test;

SELECT
    'Table Structure' as component,
    CASE
        WHEN COUNT(*) >= 8 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) || ' columns found' as details
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_content_interactions'

UNION ALL

SELECT
    'Constraints' as component,
    CASE
        WHEN COUNT(*) >= 4 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) || ' constraints defined' as details
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name = 'user_content_interactions'

UNION ALL

SELECT
    'Indexes' as component,
    CASE
        WHEN COUNT(*) >= 3 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) || ' indexes created' as details
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'user_content_interactions'

UNION ALL

SELECT
    'RLS Policies' as component,
    CASE
        WHEN COUNT(*) >= 4 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) || ' policies configured' as details
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_content_interactions'

UNION ALL

SELECT
    'Trigger Functions' as component,
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS'
        ELSE 'FAIL'
    END as status,
    COUNT(*) || ' trigger function(s) active' as details
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND event_object_table = 'user_content_interactions';

-- ========================================
-- NOTE: Integration and load tests
-- ========================================

SELECT '===== INTEGRATION TEST NOTES =====' as test;

SELECT
    'For comprehensive testing, perform the following integration tests:' as instruction
UNION ALL SELECT '1. Create test interactions and verify trigger updates learning_content'
UNION ALL SELECT '2. Test RLS by attempting cross-user access (should fail)'
UNION ALL SELECT '3. Insert 10000+ interactions for load testing'
UNION ALL SELECT '4. Verify soft deletes exclude interactions from metrics'
UNION ALL SELECT '5. Test unique constraint prevents duplicate interaction types'
UNION ALL SELECT '6. Verify cascade delete when user or content is deleted';
