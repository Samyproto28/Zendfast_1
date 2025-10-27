# Supabase Database Migrations

This directory contains all database migrations for the ZendFast application.

## Migration Files

### Applied Migrations

1. **20251026_add_missing_tables.sql**
   - Adds `motivational_phrases` table with 6 categories
   - Adds `user_metrics` table for user statistics
   - Adds `daily_hydration_goal` column to `user_profiles`
   - Creates indexes for better query performance

2. **20251026_add_rls_policies.sql**
   - Enables Row Level Security on `motivational_phrases` and `user_metrics`
   - Creates public read access for motivational phrases
   - Restricts user_metrics to owner access only
   - Adds service_role policies for admin operations

3. **20251026_create_triggers.sql**
   - **update_user_metrics_on_fast_complete**: Auto-updates user metrics when fasting session completes
   - **update_user_metrics_timestamp**: Auto-updates `updated_at` field
   - **cleanup_old_analytics_events**: Function to delete analytics older than 90 days

4. **20251026_seed_data.sql**
   - Inserts 130+ motivational phrases in Spanish (6 categories)
   - Inserts 20+ learning content articles in Spanish
   - Comprehensive content for intermittent fasting app

## Database Schema Overview

### Tables

#### `motivational_phrases`
- Stores motivational messages in multiple categories
- Categories: inicio_ayuno, durante_ayuno, finalizacion_ayuno, general, hidratacion, mindfulness
- Public read access via RLS

#### `user_metrics`
- Aggregated statistics per user
- Fields: total_fasts, total_duration_hours, streak_days, last_fast_date
- Auto-updated via triggers
- User-scoped access via RLS

#### `user_profiles` (enhanced)
- Added `daily_hydration_goal` (INTEGER, default 2000ml)

### Security Features

#### Row Level Security (RLS)
All user data tables have RLS enabled:
- Users can only access their own data
- Public tables (motivational_phrases, learning_content) have read-only access
- Service role has administrative access

#### Triggers
- Automatic metric calculation on fast completion
- Automatic timestamp updates
- Data cleanup utilities

### Indexes
- `idx_motivational_phrases_category` - Fast category queries
- `idx_motivational_phrases_language` - Language filtering
- `idx_user_metrics_user_id` - User metric lookups
- `idx_user_metrics_last_fast_date` - Streak calculations

## How to Apply Migrations

### Using Supabase Dashboard
1. Navigate to SQL Editor in Supabase Dashboard
2. Copy contents of migration file
3. Execute in order

### Using Supabase CLI
```bash
# Apply a specific migration
supabase db push --db-url <your-db-url>

# Or apply migrations manually
psql <connection-string> -f 20251026_add_missing_tables.sql
```

### Using MCP (if configured)
Migrations have been applied via the Supabase MCP server.

## Testing

See `/supabase/tests/README.md` for testing documentation.

## Rollback Procedures

To rollback migrations, you would need to:

1. **20251026_seed_data.sql**
   ```sql
   TRUNCATE motivational_phrases;
   DELETE FROM learning_content WHERE author LIKE 'Dr.%' OR author LIKE 'Dra.%';
   ```

2. **20251026_create_triggers.sql**
   ```sql
   DROP TRIGGER IF EXISTS trigger_update_user_metrics_on_fast_complete ON fasting_sessions;
   DROP TRIGGER IF EXISTS trigger_update_user_metrics_timestamp ON user_metrics;
   DROP FUNCTION IF EXISTS update_user_metrics_on_fast_complete();
   DROP FUNCTION IF EXISTS update_user_metrics_timestamp();
   DROP FUNCTION IF EXISTS cleanup_old_analytics_events(INTEGER);
   ```

3. **20251026_add_rls_policies.sql**
   ```sql
   DROP POLICY IF EXISTS "Anyone can view motivational phrases" ON motivational_phrases;
   DROP POLICY IF EXISTS "Service role can insert motivational phrases" ON motivational_phrases;
   -- ... (drop other policies)
   ALTER TABLE motivational_phrases DISABLE ROW LEVEL SECURITY;
   ALTER TABLE user_metrics DISABLE ROW LEVEL SECURITY;
   ```

4. **20251026_add_missing_tables.sql**
   ```sql
   DROP TABLE IF EXISTS user_metrics CASCADE;
   DROP TABLE IF EXISTS motivational_phrases CASCADE;
   ALTER TABLE user_profiles DROP COLUMN IF EXISTS daily_hydration_goal;
   ```

## Maintenance

### Cleanup Old Analytics
Run periodically (recommended: monthly):
```sql
SELECT cleanup_old_analytics_events(90); -- Deletes analytics older than 90 days
```

### Verify RLS Policies
```sql
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;
```

### Check Trigger Status
```sql
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

## Notes

- All timestamps use `TIMESTAMPTZ` for timezone awareness
- UUIDs are generated using `gen_random_uuid()`
- Foreign keys use CASCADE delete for data integrity
- Content is primarily in Spanish for target audience
