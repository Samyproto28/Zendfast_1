-- Test Script: Analytics Events Table Validation
-- Created: 2025-10-27
-- Purpose: Comprehensive testing of analytics_events table structure, constraints, RLS policies, and functionality
-- Related Task: Task 68 - Crear tabla 'analytics_events' en Supabase

-- ========================================
-- TEST 1: Table Structure Validation
-- ========================================
SELECT '===== TEST 1: Verify analytics_events table structure =====' as test;

-- Check all required columns exist with correct types
SELECT
    CASE
        WHEN COUNT(*) = 7 THEN 'PASS: All 7 columns exist'
        ELSE 'FAIL: Expected 7 columns, found ' || COUNT(*)
    END as result
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'analytics_events';

-- Verify column types
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default,
    CASE
        WHEN column_name = 'event_id' AND data_type = 'uuid' AND is_nullable = 'NO' THEN 'PASS'
        WHEN column_name = 'user_id' AND data_type = 'uuid' AND is_nullable = 'NO' THEN 'PASS'
        WHEN column_name = 'event_type' AND data_type = 'text' AND is_nullable = 'NO' THEN 'PASS'
        WHEN column_name = 'event_data' AND data_type = 'jsonb' THEN 'PASS'
        WHEN column_name = 'timestamp' AND data_type = 'timestamp with time zone' AND is_nullable = 'NO' THEN 'PASS'
        WHEN column_name = 'session_id' AND data_type = 'text' THEN 'PASS'
        WHEN column_name = 'updated_at' AND data_type = 'timestamp with time zone' AND is_nullable = 'NO' THEN 'PASS'
        ELSE 'FAIL'
    END as column_check
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'analytics_events'
ORDER BY ordinal_position;

-- ========================================
-- TEST 2: Primary Key and Foreign Key Validation
-- ========================================
SELECT '===== TEST 2: Verify primary and foreign keys =====' as test;

-- Check primary key
SELECT
    CASE
        WHEN COUNT(*) = 1 AND constraint_name = 'analytics_events_pkey' THEN 'PASS: Primary key on event_id'
        ELSE 'FAIL: Primary key not configured correctly'
    END as result
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND table_name = 'analytics_events'
AND constraint_type = 'PRIMARY KEY';

-- Check foreign key to auth.users
SELECT
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS: Foreign key to auth.users exists'
        ELSE 'FAIL: Foreign key to auth.users missing'
    END as result
FROM information_schema.table_constraints tc
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_schema = 'public'
AND tc.table_name = 'analytics_events'
AND tc.constraint_type = 'FOREIGN KEY'
AND ccu.table_name = 'users';

-- ========================================
-- TEST 3: CHECK Constraint Validation
-- ========================================
SELECT '===== TEST 3: Verify event_type CHECK constraint =====' as test;

-- Check that CHECK constraint exists
SELECT
    CASE
        WHEN COUNT(*) >= 1 THEN 'PASS: CHECK constraint exists on event_type'
        ELSE 'FAIL: CHECK constraint missing'
    END as result
FROM information_schema.check_constraints
WHERE constraint_schema = 'public'
AND constraint_name LIKE '%analytics_events%event_type%';

-- Test valid event_type values (should succeed - this is a logic test, actual insert requires auth)
SELECT '--- Valid event_type values that should be accepted:' as info;
SELECT unnest(ARRAY[
    'fasting_started',
    'fasting_completed',
    'fasting_interrupted',
    'panic_button_used',
    'meditation_attempted',
    'meditation_completed',
    'hydration_logged',
    'plan_changed',
    'content_viewed',
    'subscription_converted'
]) as valid_event_types;

-- ========================================
-- TEST 4: RLS Enabled Validation
-- ========================================
SELECT '===== TEST 4: Verify RLS is enabled =====' as test;

SELECT
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled on analytics_events'
        ELSE 'FAIL: RLS not enabled on analytics_events'
    END as result
FROM pg_class
WHERE relname = 'analytics_events';

-- ========================================
-- TEST 5: RLS Policies Validation
-- ========================================
SELECT '===== TEST 5: Verify RLS policies exist =====' as test;

-- Count policies
SELECT
    CASE
        WHEN COUNT(*) = 3 THEN 'PASS: All 3 required policies exist'
        ELSE 'FAIL: Expected 3 policies, found ' || COUNT(*)
    END as result
FROM pg_policies
WHERE tablename = 'analytics_events';

-- List all policies
SELECT
    policyname,
    cmd as operation,
    roles,
    CASE
        WHEN policyname = 'users_own_analytics_only' AND cmd = 'ALL' THEN 'PASS'
        WHEN policyname = 'admin_aggregate_analytics_only' AND cmd = 'SELECT' THEN 'PASS'
        WHEN policyname = 'service_role_can_manage_analytics' AND cmd = 'ALL' THEN 'PASS'
        ELSE 'CHECK'
    END as policy_check
FROM pg_policies
WHERE tablename = 'analytics_events'
ORDER BY policyname;

-- ========================================
-- TEST 6: Indexes Validation
-- ========================================
SELECT '===== TEST 6: Verify optimized indexes exist =====' as test;

-- Check all required indexes
SELECT
    indexname,
    indexdef,
    CASE
        WHEN indexname = 'analytics_events_pkey' THEN 'PASS: Primary key index'
        WHEN indexname = 'idx_analytics_events_user_type' THEN 'PASS: User-type composite index'
        WHEN indexname = 'idx_analytics_events_type_timestamp' THEN 'PASS: Type-timestamp index'
        WHEN indexname = 'idx_analytics_events_session' THEN 'PASS: Session partial index'
        ELSE 'INFO: ' || indexname
    END as index_check
FROM pg_indexes
WHERE tablename = 'analytics_events'
AND schemaname = 'public'
ORDER BY indexname;

-- Count indexes
SELECT
    CASE
        WHEN COUNT(*) >= 4 THEN 'PASS: At least 4 indexes exist (pkey + 3 custom)'
        ELSE 'FAIL: Expected at least 4 indexes, found ' || COUNT(*)
    END as result
FROM pg_indexes
WHERE tablename = 'analytics_events'
AND schemaname = 'public';

-- ========================================
-- TEST 7: Trigger Function Validation
-- ========================================
SELECT '===== TEST 7: Verify updated_at trigger exists =====' as test;

-- Check trigger function exists
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: update_analytics_events_timestamp() function exists'
        ELSE 'FAIL: Trigger function missing'
    END as result
FROM pg_proc
WHERE proname = 'update_analytics_events_timestamp';

-- Check trigger exists
SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: Trigger configured on analytics_events'
        ELSE 'FAIL: Trigger not configured'
    END as result
FROM pg_trigger
WHERE tgname = 'trigger_update_analytics_events_timestamp';

-- ========================================
-- TEST 8: JSONB event_data Field Test
-- ========================================
SELECT '===== TEST 8: Verify JSONB field functionality =====' as test;

-- Verify default value is empty object
SELECT
    CASE
        WHEN column_default = '''{}''::jsonb' THEN 'PASS: event_data defaults to {}'
        ELSE 'INFO: event_data default is ' || COALESCE(column_default, 'NULL')
    END as result
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'analytics_events'
AND column_name = 'event_data';

-- ========================================
-- TEST 9: Comments/Documentation Validation
-- ========================================
SELECT '===== TEST 9: Verify table and column comments =====' as test;

-- Check table comment
SELECT
    CASE
        WHEN obj_description('public.analytics_events'::regclass) IS NOT NULL
        THEN 'PASS: Table comment exists'
        ELSE 'FAIL: Table comment missing'
    END as result;

-- Check column comments
SELECT
    column_name,
    CASE
        WHEN col_description('public.analytics_events'::regclass, ordinal_position) IS NOT NULL
        THEN 'PASS: Comment exists'
        ELSE 'INFO: No comment'
    END as comment_status
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'analytics_events'
ORDER BY ordinal_position;

-- ========================================
-- TEST 10: Cleanup Function Reference
-- ========================================
SELECT '===== TEST 10: Verify cleanup function exists =====' as test;

SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS: cleanup_old_analytics_events() function exists'
        ELSE 'FAIL: Cleanup function missing'
    END as result
FROM pg_proc
WHERE proname = 'cleanup_old_analytics_events';

-- ========================================
-- TEST 11: Performance - Index Usage Simulation
-- ========================================
SELECT '===== TEST 11: Verify indexes improve query performance =====' as test;

-- Note: EXPLAIN ANALYZE requires actual data, this just verifies the query planner can use indexes
EXPLAIN (FORMAT TEXT)
SELECT event_id, event_type, timestamp
FROM public.analytics_events
WHERE user_id = gen_random_uuid()
AND event_type = 'fasting_started'
ORDER BY timestamp DESC
LIMIT 10;

SELECT 'INFO: Check EXPLAIN output above for idx_analytics_events_user_type usage' as note;

-- ========================================
-- TEST SUMMARY
-- ========================================
SELECT '===== TEST SUMMARY =====' as test;

-- Summary of table configuration
SELECT
    'analytics_events' as table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'analytics_events') as column_count,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'analytics_events') as policy_count,
    (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'analytics_events') as index_count,
    (SELECT COUNT(*) FROM pg_trigger WHERE tgrelid = 'public.analytics_events'::regclass) as trigger_count,
    (SELECT relrowsecurity FROM pg_class WHERE relname = 'analytics_events') as rls_enabled;

-- List all constraints
SELECT
    constraint_name,
    constraint_type,
    CASE
        WHEN constraint_type = 'PRIMARY KEY' THEN 'PASS'
        WHEN constraint_type = 'FOREIGN KEY' THEN 'PASS'
        WHEN constraint_type = 'CHECK' THEN 'PASS'
        ELSE 'INFO'
    END as status
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND table_name = 'analytics_events'
ORDER BY constraint_type, constraint_name;

SELECT '===== ALL TESTS COMPLETED =====' as test;
SELECT 'Review results above for any FAIL statuses' as note;
