# Backup Data Edge Function

**Automated daily backups of critical user data with compression, encryption, and 30-day retention**

## 📋 Overview

This Supabase Edge Function performs automated daily backups of critical user data from the Zendfast application. It extracts data from PostgreSQL, compresses it with GZIP, encrypts it with AES-256-GCM, and stores it securely in Supabase Storage.

### Features

- ✅ **Service Role Authentication** - Only callable with service role key (not user JWTs)
- ✅ **Rate Limiting** - Prevents multiple simultaneous executions (5-minute cooldown)
- ✅ **Data Extraction** - Calls PostgreSQL `backup_critical_data()` function
- ✅ **GZIP Compression** - Reduces backup file size by 50-70%
- ✅ **AES-256-GCM Encryption** - Military-grade encryption with unique IV per backup
- ✅ **Storage Upload** - Encrypted backups uploaded to Supabase Storage bucket
- ✅ **Automated Retention** - Deletes backups older than 30 days automatically
- ✅ **Failure Notifications** - Email (Resend) + OneSignal push alerts on errors
- ✅ **System Logging** - Records all backup events to `system_logs` table

---

## 🗂️ Data Backed Up

The function backs up data from the last 24 hours (configurable) from these tables:

| Table | Description | Columns |
|-------|-------------|---------|
| `fasting_sessions` | User fasting session records | id, user_id, start_time, end_time, duration_minutes, completed, interrupted, plan_type |
| `user_profiles` | User profile and settings | id, weight_kg, height_cm, onboarding status, theme, notifications, subscription |
| `hydration_logs` | Water intake logs | id, user_id, amount_ml, timestamp |

### Sample Backup Structure

```json
{
  "backup_timestamp": "2025-01-12T14:30:00.000Z",
  "hours_covered": 24,
  "cutoff_time": "2025-01-11T14:30:00.000Z",
  "counts": {
    "fasting_sessions_count": 150,
    "user_profiles_count": 45,
    "hydration_logs_count": 320
  },
  "data": {
    "fasting_sessions": [...],
    "user_profiles": [...],
    "hydration_logs": [...]
  }
}
```

---

## 🔐 Security

### Encryption

- **Algorithm**: AES-256-GCM (Galois/Counter Mode)
- **Key Derivation**: PBKDF2 with 100,000 iterations and SHA-256
- **Initialization Vector**: 96-bit (12 bytes) random IV per backup
- **Salt**: 128-bit (16 bytes) random salt per backup

### File Format

Encrypted backup files have salt and IV prepended to the ciphertext:

```
[Salt: 16 bytes] + [IV: 12 bytes] + [Encrypted Data: variable]
```

This allows decryption without storing salt/IV separately.

### Filename Convention

```
backup_YYYYMMDD_HHMMSS.json.gz.enc
```

Examples:
- `backup_20250112_143000.json.gz.enc`
- `backup_20250113_020000.json.gz.enc`

---

## ⚙️ Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | Your Supabase project URL | `https://xxxxx.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role secret key | `eyJhbGciOiJIUzI1NiIs...` |
| `BACKUP_ENCRYPTION_KEY` | 256-bit encryption key (base64) | `Generate with: openssl rand -base64 32` |

### Optional (For Failure Notifications)

| Variable | Description | Example |
|----------|-------------|---------|
| `RESEND_API_KEY` | Resend API key for email notifications | `re_xxxxxxxxxxxxx` |
| `ADMIN_EMAIL` | Admin email address for failure alerts | `admin@yourcompany.com` |
| `ONESIGNAL_API_KEY` | OneSignal REST API key for push notifications | `OTxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `ONESIGNAL_APP_ID` | OneSignal App ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |

**Note**: If notification variables are not set, notifications will be skipped (backup will still succeed).

---

## 🚀 Setup Instructions

### 1. Run Database Migrations

Apply the migrations in order:

```bash
# Navigate to Supabase directory
cd supabase

# Apply migrations
supabase migration up

# Or manually apply each migration:
psql $DATABASE_URL < migrations/20250112000000_create_system_logs_table.sql
psql $DATABASE_URL < migrations/20250112000001_create_backup_functions.sql
psql $DATABASE_URL < migrations/20250112000002_create_backup_bucket.sql
psql $DATABASE_URL < migrations/20250112000003_schedule_daily_backup.sql
```

### 2. Generate Encryption Key

```bash
# Generate a secure 256-bit encryption key
openssl rand -base64 32

# Output example:
# bXyZ1aBc2dEf3gHi4jKl5mNo6pQr7sT8uVw9xYz0ABC=
```

### 3. Configure Environment Variables

In Supabase Dashboard:

1. Go to **Edge Functions** → **backup-data** → **Settings**
2. Add environment variables:

```env
BACKUP_ENCRYPTION_KEY=<output-from-openssl-command>
RESEND_API_KEY=re_xxxxxxxxxxxxx
ADMIN_EMAIL=admin@yourcompany.com
ONESIGNAL_API_KEY=OTxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Or via CLI:

```bash
supabase secrets set BACKUP_ENCRYPTION_KEY=<your-key-here>
supabase secrets set RESEND_API_KEY=<resend-api-key>
supabase secrets set ADMIN_EMAIL=<admin-email>
supabase secrets set ONESIGNAL_API_KEY=<onesignal-api-key>
supabase secrets set ONESIGNAL_APP_ID=<onesignal-app-id>
```

**Get API Keys**:
- **Resend**: Sign up at [resend.com](https://resend.com) → API Keys
- **OneSignal**: Sign up at [onesignal.com](https://onesignal.com) → Settings → Keys & IDs

### 4. Deploy Edge Function

```bash
# Deploy the function
supabase functions deploy backup-data

# Verify deployment
supabase functions list
```

### 5. Enable pg_cron Extension

1. Go to Supabase Dashboard → **Database** → **Extensions**
2. Enable `pg_cron` extension
3. The daily backup job will be scheduled automatically at 2 AM UTC

---

## 🧪 Testing

### Unit Tests

Run the unit tests locally (requires Deno):

```bash
cd supabase/functions/backup-data

# Run unit tests (Subtasks 65.1 & 65.2)
deno test --allow-env --allow-net --allow-read index.test.ts

# Run integration tests (Subtask 65.3)
deno test --allow-env --allow-net --allow-read integration.test.ts
```

**Test Coverage**:
- **Unit Tests**: 24 tests (auth, rate limiting, compression, encryption)
- **Integration Tests**: 21 tests (storage, retention, logging, notifications, E2E)

### Manual Test Trigger

Trigger a backup manually via HTTP:

```bash
# Get your service role key from Supabase Dashboard
export SERVICE_ROLE_KEY="your-service-role-key"

# Trigger backup
curl -X POST \
  https://your-project.supabase.co/functions/v1/backup-data \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"source": "manual_test"}'
```

Expected response:

```json
{
  "status": "success",
  "message": "Backup completed successfully",
  "filename": "backup_20250112_143000.json.gz.enc",
  "timestamp": "2025-01-12T14:30:00.000Z",
  "request_source": "manual_test",
  "execution_time_ms": 2456,
  "deleted_old_backups": 3,
  "data_stats": {
    "original_size_bytes": 524288,
    "compressed_size_bytes": 157286,
    "encrypted_size_bytes": 157314,
    "compression_ratio": "30.0%",
    "record_counts": {
      "fasting_sessions_count": 150,
      "user_profiles_count": 45,
      "hydration_logs_count": 320
    }
  }
}
```

### Test via PostgreSQL Function

```sql
-- Trigger backup via PostgreSQL function (service role required)
SELECT public.trigger_backup_manually();
```

---

## 🔄 Scheduled Execution

The backup runs automatically via pg_cron at **2 AM UTC daily**.

### View Scheduled Jobs

```sql
SELECT * FROM cron.job WHERE jobname = 'daily-backup-automated';
```

### View Job Execution History

```sql
SELECT *
FROM cron.job_run_details
WHERE jobid = (
  SELECT jobid
  FROM cron.job
  WHERE jobname = 'daily-backup-automated'
)
ORDER BY start_time DESC
LIMIT 10;
```

### Manually Unschedule (if needed)

```sql
SELECT cron.unschedule('daily-backup-automated');
```

---

## 📊 Monitoring

### Check System Logs

```sql
-- View recent backup events
SELECT
  event_type,
  event_data,
  backup_size_bytes,
  error_message,
  created_at
FROM system_logs
WHERE event_type LIKE 'backup%' OR event_type LIKE 'retention%' OR event_type LIKE 'notification%'
ORDER BY created_at DESC
LIMIT 20;
```

**Event Types Logged**:
- `backup_started` - Backup execution initiated
- `backup_success` - Backup completed successfully (includes file size, compression ratio, deletion count)
- `backup_failure` - Backup failed (includes error message)
- `retention_cleanup` - Old backups deleted (includes file names and count)
- `notification_sent` - Failure notifications sent (includes OneSignal/email status)
- `notification_failed` - Notification attempt failed

**Example Log Query for Success Events**:
```sql
SELECT
  event_data->>'filename' as filename,
  event_data->>'execution_time_ms' as execution_ms,
  event_data->>'deleted_old_backups' as deleted_count,
  backup_size_bytes,
  created_at
FROM system_logs
WHERE event_type = 'backup_success'
ORDER BY created_at DESC
LIMIT 10;
```

### Check Backup Files in Storage

```sql
-- List backups in storage bucket
SELECT
  name,
  created_at,
  metadata,
  ROUND(metadata->>'size'::numeric / 1024 / 1024, 2) as size_mb
FROM storage.objects
WHERE bucket_id = 'backups'
ORDER BY created_at DESC;
```

**View Retention Policy Status**:
```sql
-- Find backups older than 30 days (eligible for deletion)
SELECT
  name,
  created_at,
  NOW() - created_at as age,
  metadata->>'size' as size_bytes
FROM storage.objects
WHERE bucket_id = 'backups'
  AND created_at < NOW() - INTERVAL '30 days'
ORDER BY created_at ASC;
```

---

## 🔓 Decrypting Backups

### Manual Decryption Script (TypeScript/Deno)

```typescript
// decrypt-backup.ts
const encryptionKey = Deno.env.get("BACKUP_ENCRYPTION_KEY")!;
const filename = Deno.args[0]; // e.g., backup_20250112_143000.json.gz.enc

// Read encrypted file
const encryptedData = await Deno.readFile(filename);

// Extract salt, IV, and ciphertext
const salt = encryptedData.slice(0, 16);
const iv = encryptedData.slice(16, 28);
const ciphertext = encryptedData.slice(28);

// Derive key
const encoder = new TextEncoder();
const keyMaterial = await crypto.subtle.importKey(
  "raw",
  encoder.encode(encryptionKey),
  "PBKDF2",
  false,
  ["deriveBits", "deriveKey"]
);

const key = await crypto.subtle.deriveKey(
  { name: "PBKDF2", salt: salt, iterations: 100000, hash: "SHA-256" },
  keyMaterial,
  { name: "AES-GCM", length: 256 },
  true,
  ["encrypt", "decrypt"]
);

// Decrypt
const decrypted = await crypto.subtle.decrypt(
  { name: "AES-GCM", iv: iv },
  key,
  ciphertext
);

// Decompress
import { gunzip } from "jsr:@deno-library/compress@0.5.5";
const decompressed = gunzip(new Uint8Array(decrypted));

// Convert to JSON
const decoder = new TextDecoder();
const json = decoder.decode(decompressed);
const backupData = JSON.parse(json);

console.log(JSON.stringify(backupData, null, 2));
```

Run:

```bash
deno run --allow-env --allow-read decrypt-backup.ts backup_20250112_143000.json.gz.enc > decrypted.json
```

---

## 🚨 Troubleshooting

### Backup Fails - "Missing encryption key"

**Solution**: Set `BACKUP_ENCRYPTION_KEY` environment variable in Edge Function settings.

```bash
supabase secrets set BACKUP_ENCRYPTION_KEY=$(openssl rand -base64 32)
```

### Backup Fails - "Rate limit exceeded"

**Cause**: Another backup is running or completed within the last 5 minutes.

**Solution**: Wait 5 minutes, or manually reset rate limiter by redeploying the function.

### Backup Fails - "Failed to extract backup data"

**Possible causes**:
1. PostgreSQL function `backup_critical_data()` not created (run migrations)
2. Service role key lacks permissions

**Check PostgreSQL function**:

```sql
SELECT public.backup_critical_data(24);
```

### Backup Fails - "Failed to upload to storage"

**Possible causes**:
1. Storage bucket 'backups' not created (run migrations)
2. Service role key lacks storage permissions
3. File already exists (duplicate filename)

**Check storage bucket**:
```sql
SELECT * FROM storage.buckets WHERE name = 'backups';
```

### Notifications Not Sending

**Check environment variables are set**:
```bash
supabase secrets list
```

**Required for notifications**:
- `RESEND_API_KEY` - For email notifications
- `ADMIN_EMAIL` - Recipient email address
- `ONESIGNAL_API_KEY` - For push notifications
- `ONESIGNAL_APP_ID` - OneSignal app identifier

**Note**: If notification variables are missing, the backup will still succeed. Check `system_logs` for `notification_failed` events.

### Daily Backup Not Running

**Check pg_cron is enabled**:

```sql
SELECT * FROM pg_extension WHERE extname = 'pg_cron';
```

**Verify cron job exists**:

```sql
SELECT * FROM cron.job WHERE jobname = 'daily-backup-automated';
```

---

## 📈 Performance

### Typical Execution Times

| Dataset Size | Records | Original Size | Compressed Size | Execution Time |
|--------------|---------|---------------|-----------------|----------------|
| Small | <100 | ~50 KB | ~15 KB | <1 second |
| Medium | 100-1000 | ~500 KB | ~150 KB | 1-3 seconds |
| Large | 1000-10000 | ~5 MB | ~1.5 MB | 5-15 seconds |
| Very Large | >10000 | ~50 MB | ~15 MB | 30-60 seconds |

### Optimization Tips

1. **Reduce backup frequency** - If 24-hour backups are too frequent, increase to 48 hours
2. **Partition data** - For very large datasets, consider splitting by user cohorts
3. **Compress more aggressively** - Consider LZMA instead of GZIP for better compression

---

## 🔒 Security Best Practices

1. **Never commit encryption keys** - Use environment variables only
2. **Rotate encryption keys annually** - Update `BACKUP_ENCRYPTION_KEY` yearly
3. **Restrict service role access** - Only use for automated tasks
4. **Monitor backup access** - Check `system_logs` for unauthorized access attempts
5. **Test decryption regularly** - Verify backups can be restored

---

## 📝 Implementation Status

### ✅ Completed - Task 65 (100%)

**Subtask 65.1: Base Edge Function Structure**
- [x] Service role authentication (not user JWT)
- [x] Rate limiting (5-minute cooldown)
- [x] CORS handling
- [x] Request validation (GET/POST only)
- [x] Environment variable validation
- [x] Unit tests (8 tests)

**Subtask 65.2: Data Processing**
- [x] Data extraction from PostgreSQL (`backup_critical_data()`)
- [x] GZIP compression (50-70% size reduction)
- [x] AES-256-GCM encryption (PBKDF2 key derivation)
- [x] Filename generation (`backup_YYYYMMDD_HHMMSS.json.gz.enc`)
- [x] Unit tests (16 tests for compression/encryption)

**Subtask 65.3: Storage, Retention & Notifications**
- [x] Upload encrypted backup to Supabase Storage
- [x] 30-day retention policy implementation
- [x] System logs recording (backup_started, backup_success, backup_failure, retention_cleanup, notification_sent)
- [x] Email notification on failure (Resend API)
- [x] OneSignal push notification on failure
- [x] Integration tests (21 tests for full workflow)

**Database Migrations**
- [x] `system_logs` table with RLS policies
- [x] `backup_critical_data()` PostgreSQL function
- [x] `backups` storage bucket with RLS policies
- [x] pg_cron daily backup job (2 AM UTC)
- [x] `trigger_backup_manually()` function for testing

**Documentation**
- [x] Comprehensive README with setup instructions
- [x] API documentation and examples
- [x] Decryption script
- [x] Troubleshooting guide
- [x] Monitoring queries

---

## 📚 Related Documentation

- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [pg_cron Extension](https://supabase.com/docs/guides/database/extensions/pgcron)
- [Supabase Storage](https://supabase.com/docs/guides/storage)
- [Web Crypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API)

---

## 🤝 Support

For issues or questions:

1. Check `system_logs` table for error messages
2. Review Edge Function logs in Supabase Dashboard
3. Verify all environment variables are set correctly
4. Test manually with curl command above

---

**Last Updated**: 2025-01-12
**Version**: 1.0.0 (Task 65 Complete - All Subtasks Implemented)
**Status**: Production Ready
