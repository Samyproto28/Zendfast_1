# Supabase Database Tests

This directory contains comprehensive test scripts for validating database security, functionality, and integrity.

## Test Files

### 1. test_rls_policies.sql
**Purpose:** Verify Row Level Security (RLS) policies are correctly configured

**Tests:**
- ✅ Public read access to motivational_phrases (130 phrases verified)
- ✅ RLS enabled on all user data tables
- ✅ Policy counts per table (24 total policies)
- ✅ Policy configurations (USING and WITH CHECK clauses)

**How to Run:**
```sql
-- Via Supabase Dashboard SQL Editor
\i supabase/tests/test_rls_policies.sql

-- Or execute specific tests
SELECT COUNT(*) FROM motivational_phrases; -- Should return 130+
```

**Expected Results:**
- All user tables have RLS enabled
- motivational_phrases: 4 policies
- user_metrics: 5 policies
- user_profiles: 4 policies
- fasting_sessions: 4 policies
- hydration_logs: 4 policies
- analytics_events: 2 policies
- learning_content: 1 policy

### 2. test_triggers.sql
**Purpose:** Validate database triggers and automated functions

**Tests:**
- ✅ Trigger functions exist (3 functions)
- ✅ Triggers are created (4 triggers)
- ✅ update_updated_at_column implementation
- ✅ cleanup_old_analytics_events function
- ✅ user_metrics auto-update trigger

**How to Run:**
```sql
\i supabase/tests/test_triggers.sql
```

**Expected Results:**
- `update_user_metrics_on_fast_complete` - Exists and linked to fasting_sessions
- `update_user_metrics_timestamp` - Exists and linked to user_metrics
- `cleanup_old_analytics_events` - Returns deleted_count
- `update_updated_at_column` - Exists and linked to multiple tables

### 3. test_security.sql
**Purpose:** Comprehensive security validation and vulnerability checks

**Tests:**
- ✅ All critical tables have RLS enabled
- ✅ Foreign key constraints configured
- ✅ CASCADE delete rules validated
- ✅ NOT NULL constraints on critical fields
- ✅ Function security levels (SECURITY DEFINER check)
- ✅ Unique constraints
- ✅ Sensitive data column types
- ✅ Default values security
- ✅ Index existence for performance & security

**How to Run:**
```sql
\i supabase/tests/test_security.sql
```

**Expected Results:**
- All tables with user data have RLS enabled
- Foreign keys properly configured with CASCADE where appropriate
- No SQL injection vulnerabilities in functions
- Indexes exist on user_id columns for RLS performance

## Test Results Summary

### ✅ Passing Tests (as of 2025-10-26)

#### RLS Policies
- **130 motivational phrases** accessible publicly ✓
- **RLS enabled** on user_metrics ✓
- **RLS enabled** on user_profiles ✓
- **RLS enabled** on fasting_sessions ✓
- **RLS enabled** on hydration_logs ✓
- **RLS enabled** on analytics_events ✓
- **24 total RLS policies** across 7 tables ✓

#### Triggers
- **4 triggers created** successfully ✓
- **trigger_update_user_metrics_on_fast_complete** on fasting_sessions ✓
- **update_learning_content_updated_at** on learning_content ✓
- **trigger_update_user_metrics_timestamp** on user_metrics ✓
- **update_user_profiles_updated_at** on user_profiles ✓

#### Functions
- **cleanup_old_analytics_events** exists ✓
- **update_user_metrics_on_fast_complete** exists ✓
- **update_user_metrics_timestamp** exists ✓

### ⚠️ Warnings (Non-Critical)

From Supabase advisors:
- Function search_path mutable on some functions (security consideration)
- Postgres version has security patches available (upgrade recommended)

These are informational warnings and do not affect core functionality.

## Manual Testing Scenarios

### Scenario 1: Test User Metrics Trigger

```sql
-- Create test user (requires authenticated session)
-- This would be done through your app's auth flow

-- Insert a fasting session
INSERT INTO fasting_sessions (user_id, start_time, end_time, duration_minutes, plan_type, completed)
VALUES (
    auth.uid(),
    NOW() - INTERVAL '16 hours',
    NOW(),
    960, -- 16 hours
    '16:8',
    true
);

-- Check that user_metrics was auto-updated
SELECT * FROM user_metrics WHERE user_id = auth.uid();
-- Should show total_fasts = 1, total_duration_hours = 16, streak_days = 1
```

### Scenario 2: Test RLS Policies

```sql
-- Try to access another user's data (should fail)
-- This test requires two authenticated users

-- User A tries to access User B's fasting sessions
SELECT * FROM fasting_sessions WHERE user_id = '<user-b-uuid>';
-- Should return empty if User A is authenticated, demonstrating RLS works
```

### Scenario 3: Test Cleanup Function

```sql
-- Insert old analytics event
INSERT INTO analytics_events (user_id, event_name, timestamp, created_at)
VALUES (
    auth.uid(),
    'test_event',
    NOW() - INTERVAL '100 days',
    NOW() - INTERVAL '100 days'
);

-- Run cleanup
SELECT cleanup_old_analytics_events(90);
-- Should return count of deleted rows

-- Verify old event was deleted
SELECT COUNT(*) FROM analytics_events
WHERE created_at < NOW() - INTERVAL '90 days';
-- Should return 0
```

## Automated Testing

To automate these tests in CI/CD:

```bash
#!/bin/bash
# run_tests.sh

SUPABASE_DB_URL="your-connection-string"

echo "Running RLS Policy Tests..."
psql $SUPABASE_DB_URL -f supabase/tests/test_rls_policies.sql

echo "Running Trigger Tests..."
psql $SUPABASE_DB_URL -f supabase/tests/test_triggers.sql

echo "Running Security Tests..."
psql $SUPABASE_DB_URL -f supabase/tests/test_security.sql

echo "All tests completed!"
```

## Continuous Monitoring

### Weekly Checks
- Run security advisors
- Verify RLS policies are still enabled
- Check trigger execution counts

### Monthly Maintenance
- Execute `cleanup_old_analytics_events(90)`
- Review security advisor recommendations
- Verify index performance

## Troubleshooting

### Issue: RLS blocking legitimate queries
**Solution:** Check that `auth.uid()` is properly set in the session

### Issue: Triggers not firing
**Solution:** Verify trigger is enabled:
```sql
SELECT tgenabled FROM pg_trigger WHERE tgname = 'trigger_name';
-- 'O' = enabled, 'D' = disabled
```

### Issue: Performance degradation
**Solution:** Check indexes exist on RLS policy columns:
```sql
SELECT * FROM pg_indexes WHERE schemaname = 'public';
```

## Additional Resources

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Trigger Documentation](https://www.postgresql.org/docs/current/triggers.html)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/database/securing-your-database)

## Contributing

When adding new tests:
1. Follow the existing naming convention
2. Include clear test descriptions
3. Add expected results in comments
4. Update this README with new test information
