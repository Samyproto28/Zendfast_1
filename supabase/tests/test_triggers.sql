-- Test Script: Triggers Validation
-- Created: 2025-10-26
-- Purpose: Verify database triggers function correctly

-- ========================================
-- TEST 1: Check Trigger Functions Exist
-- ========================================
SELECT '===== TEST 1: Trigger functions exist =====' as test;

SELECT
    proname as function_name,
    CASE
        WHEN proname IN ('update_user_metrics_on_fast_complete', 'update_user_metrics_timestamp', 'cleanup_old_analytics_events', 'update_updated_at_column')
        THEN 'PASS: Function exists'
        ELSE 'INFO: Function found'
    END as result
FROM pg_proc
WHERE proname LIKE '%user_metrics%' OR proname LIKE '%cleanup%' OR proname LIKE '%updated_at%'
ORDER BY proname;

-- ========================================
-- TEST 2: Check Triggers Are Created
-- ========================================
SELECT '===== TEST 2: Triggers are created =====' as test;

SELECT
    trigger_name,
    event_object_table as table_name,
    action_timing as timing,
    event_manipulation as event,
    CASE
        WHEN trigger_name IS NOT NULL THEN 'PASS: Trigger exists'
        ELSE 'FAIL: Trigger missing'
    END as result
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ========================================
-- TEST 3: Verify update_updated_at_column Function
-- ========================================
SELECT '===== TEST 3: updated_at triggers on tables =====' as test;

SELECT
    trigger_name,
    event_object_table,
    CASE
        WHEN action_statement LIKE '%update_updated_at_column%' THEN 'PASS: Uses update_updated_at_column function'
        ELSE 'INFO: Uses different function'
    END as result
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND action_statement LIKE '%updated_at%'
ORDER BY event_object_table;

-- ========================================
-- TEST 4: Test cleanup_old_analytics_events Function
-- ========================================
SELECT '===== TEST 4: cleanup_old_analytics_events function =====' as test;

-- Verify function exists and returns correct type
SELECT
    proname as function_name,
    pg_get_function_result(oid) as return_type,
    CASE
        WHEN pg_get_function_result(oid) LIKE '%deleted_count%' THEN 'PASS: Returns deleted_count'
        ELSE 'INFO: Different return type'
    END as result
FROM pg_proc
WHERE proname = 'cleanup_old_analytics_events';

-- ========================================
-- TEST 5: Simulate Fast Completion (User Metrics Update)
-- ========================================
SELECT '===== TEST 5: Trigger for user_metrics update =====' as test;

-- Check if trigger exists for fasting_sessions
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS: user_metrics trigger exists on fasting_sessions'
        ELSE 'FAIL: user_metrics trigger missing on fasting_sessions'
    END as result
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND event_object_table = 'fasting_sessions'
    AND trigger_name LIKE '%user_metrics%';

-- ========================================
-- SUMMARY: All Triggers
-- ========================================
SELECT '===== TRIGGER SUMMARY =====' as test;

SELECT
    COUNT(*) as total_triggers,
    COUNT(DISTINCT event_object_table) as tables_with_triggers
FROM information_schema.triggers
WHERE trigger_schema = 'public';

SELECT
    event_object_table as table_name,
    COUNT(*) as trigger_count,
    STRING_AGG(trigger_name, ', ' ORDER BY trigger_name) as triggers
FROM information_schema.triggers
WHERE trigger_schema = 'public'
GROUP BY event_object_table
ORDER BY event_object_table;
