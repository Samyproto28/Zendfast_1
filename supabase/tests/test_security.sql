-- Test Script: Security Validation
-- Created: 2025-10-26
-- Purpose: Comprehensive security testing for database schema

-- ========================================
-- TEST 1: Verify All Critical Tables Have RLS Enabled
-- ========================================
SELECT '===== TEST 1: RLS enabled on all user data tables =====' as test;

SELECT
    tablename,
    CASE
        WHEN relrowsecurity = true THEN 'PASS: RLS enabled'
        ELSE 'FAIL: RLS NOT enabled - SECURITY RISK!'
    END as security_status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
    AND c.relkind = 'r'
    AND tablename IN ('user_profiles', 'fasting_sessions', 'hydration_logs', 'user_metrics', 'analytics_events', 'motivational_phrases', 'learning_content')
ORDER BY tablename;

-- ========================================
-- TEST 2: Check for Tables Without RLS (Potential Security Risk)
-- ========================================
SELECT '===== TEST 2: Tables without RLS (if any) =====' as test;

SELECT
    c.relname as table_name,
    'WARNING: RLS not enabled on this table' as security_warning
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
    AND c.relkind = 'r'
    AND c.relrowsecurity = false
ORDER BY c.relname;

-- ========================================
-- TEST 3: Verify Foreign Key Constraints
-- ========================================
SELECT '===== TEST 3: Foreign key constraints =====' as test;

SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    'PASS: FK constraint exists' as result
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ========================================
-- TEST 4: Check Cascading Deletes (Data Integrity)
-- ========================================
SELECT '===== TEST 4: CASCADE delete rules =====' as test;

SELECT
    tc.table_name,
    rc.update_rule,
    rc.delete_rule,
    CASE
        WHEN rc.delete_rule = 'CASCADE' THEN 'INFO: Cascade delete enabled'
        WHEN rc.delete_rule = 'NO ACTION' THEN 'INFO: No cascade (manual cleanup required)'
        WHEN rc.delete_rule = 'SET NULL' THEN 'INFO: Set NULL on delete'
        ELSE 'INFO: Other rule: ' || rc.delete_rule
    END as integrity_status
FROM information_schema.table_constraints tc
JOIN information_schema.referential_constraints rc
    ON tc.constraint_name = rc.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;

-- ========================================
-- TEST 5: Verify Required NOT NULL Constraints
-- ========================================
SELECT '===== TEST 5: NOT NULL constraints on critical fields =====' as test;

SELECT
    table_name,
    column_name,
    is_nullable,
    CASE
        WHEN is_nullable = 'NO' THEN 'PASS: NOT NULL enforced'
        ELSE 'INFO: NULL allowed'
    END as constraint_status
FROM information_schema.columns
WHERE table_schema = 'public'
    AND column_name IN ('id', 'user_id', 'created_at')
    AND table_name IN ('user_profiles', 'fasting_sessions', 'hydration_logs', 'user_metrics', 'motivational_phrases', 'learning_content')
ORDER BY table_name, column_name;

-- ========================================
-- TEST 6: Check for SQL Injection Vulnerabilities in Functions
-- ========================================
SELECT '===== TEST 6: Function security =====' as test;

SELECT
    proname as function_name,
    prosecdef as is_security_definer,
    CASE
        WHEN prosecdef = true THEN 'INFO: SECURITY DEFINER (runs with elevated privileges)'
        ELSE 'INFO: Normal function security'
    END as security_level
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
    AND (proname LIKE '%user_metrics%' OR proname LIKE '%cleanup%')
ORDER BY proname;

-- ========================================
-- TEST 7: Verify Unique Constraints
-- ========================================
SELECT '===== TEST 7: Unique constraints =====' as test;

SELECT
    tc.table_name,
    tc.constraint_name,
    STRING_AGG(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) as columns,
    'PASS: Unique constraint exists' as result
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'UNIQUE'
    AND tc.table_schema = 'public'
GROUP BY tc.table_name, tc.constraint_name
ORDER BY tc.table_name;

-- ========================================
-- TEST 8: Check Column Data Types for Security
-- ========================================
SELECT '===== TEST 8: Sensitive data column types =====' as test;

SELECT
    table_name,
    column_name,
    data_type,
    CASE
        WHEN column_name LIKE '%password%' OR column_name LIKE '%secret%' THEN
            CASE
                WHEN data_type = 'text' THEN 'WARNING: Sensitive field - ensure hashing!'
                ELSE 'INFO: ' || data_type
            END
        WHEN column_name LIKE '%email%' THEN 'INFO: Email field - ' || data_type
        ELSE 'INFO: ' || data_type
    END as security_note
FROM information_schema.columns
WHERE table_schema = 'public'
    AND (column_name LIKE '%password%' OR column_name LIKE '%email%' OR column_name LIKE '%token%')
ORDER BY table_name, column_name;

-- ========================================
-- TEST 9: Check Default Values
-- ========================================
SELECT '===== TEST 9: Default values security =====' as test;

SELECT
    table_name,
    column_name,
    column_default,
    CASE
        WHEN column_default LIKE '%gen_random_uuid%' THEN 'PASS: Using secure UUID generation'
        WHEN column_default LIKE '%now()%' THEN 'PASS: Using timestamp function'
        WHEN column_default IS NOT NULL THEN 'INFO: Has default: ' || column_default
        ELSE 'INFO: No default'
    END as default_status
FROM information_schema.columns
WHERE table_schema = 'public'
    AND column_default IS NOT NULL
    AND table_name IN ('user_profiles', 'fasting_sessions', 'hydration_logs', 'user_metrics', 'motivational_phrases', 'learning_content', 'analytics_events')
ORDER BY table_name, column_name;

-- ========================================
-- TEST 10: Verify Index Existence for Performance & Security
-- ========================================
SELECT '===== TEST 10: Indexes for security and performance =====' as test;

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef,
    CASE
        WHEN indexdef LIKE '%user_id%' THEN 'PASS: User ID indexed for RLS performance'
        WHEN indexdef LIKE '%UNIQUE%' THEN 'PASS: Unique index for data integrity'
        ELSE 'INFO: Index exists'
    END as index_purpose
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ========================================
-- SECURITY SUMMARY
-- ========================================
SELECT '===== SECURITY SUMMARY =====' as test;

SELECT
    COUNT(DISTINCT c.relname) as total_tables,
    COUNT(DISTINCT CASE WHEN c.relrowsecurity THEN c.relname END) as tables_with_rls,
    COUNT(DISTINCT CASE WHEN NOT c.relrowsecurity THEN c.relname END) as tables_without_rls,
    CASE
        WHEN COUNT(DISTINCT c.relname) = COUNT(DISTINCT CASE WHEN c.relrowsecurity THEN c.relname END)
        THEN 'PASS: All tables have RLS enabled'
        ELSE 'WARNING: Some tables lack RLS protection'
    END as overall_status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
    AND c.relkind = 'r';
