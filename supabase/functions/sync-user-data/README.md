# Sync-User-Data Edge Function

## Overview

Bidirectional data synchronization Edge Function for Zendfast app. Synchronizes data between local Isar database and Supabase with conflict resolution, batch processing, and comprehensive error handling.

## Features

✅ **JWT Authentication** - Validates user tokens and ensures data isolation
✅ **Rate Limiting** - 100 requests per minute per user
✅ **Conflict Resolution** - Last-write-wins strategy based on timestamps
✅ **Batch Processing** - Process up to 100 records per request
✅ **Multi-table Sync** - Supports fasting_sessions, hydration_logs, user_metrics
✅ **Server Changes Detection** - Returns changes since last sync
✅ **Error Handling** - Comprehensive error reporting with retry capability

## API Specification

### Endpoint

```
POST /sync-user-data
```

### Headers

```
Authorization: Bearer <jwt-token>
Content-Type: application/json
```

### Request Body

```typescript
{
  changes: LocalChange[];
  lastSyncTimestamp?: string; // ISO 8601
}

interface LocalChange {
  table: "fasting_sessions" | "hydration_logs" | "user_metrics";
  action: "insert" | "update" | "delete";
  data: Record<string, any>;
  localTimestamp: string; // ISO 8601
}
```

### Response

```typescript
{
  success: boolean;
  conflicts: Conflict[];
  serverChanges: ServerChanges;
  errors: SyncError[];
  serverTimestamp: string; // ISO 8601
}

interface Conflict {
  table: string;
  localData: Record<string, any>;
  remoteData: Record<string, any>;
  resolvedData?: Record<string, any>;
}

interface ServerChanges {
  fasting_sessions?: any[];
  hydration_logs?: any[];
  user_metrics?: any[];
}

interface SyncError {
  table: string;
  action: string;
  error: string;
  data?: Record<string, any>;
}
```

## Usage Example

```typescript
const response = await supabase.functions.invoke('sync-user-data', {
  body: {
    changes: [
      {
        table: 'fasting_sessions',
        action: 'insert',
        data: {
          id: 123,
          user_id: 'user-abc',
          start_time: '2025-01-11T10:00:00Z',
          duration_minutes: 960,
          plan_type: '16:8',
          completed: false,
          interrupted: false,
        },
        localTimestamp: '2025-01-11T10:00:00Z',
      },
    ],
    lastSyncTimestamp: '2025-01-11T08:00:00Z',
  },
});

if (response.data.success) {
  // Apply server changes to local database
  const serverChanges = response.data.serverChanges;

  // Handle conflicts
  const conflicts = response.data.conflicts;

  // Save new sync timestamp
  const lastSync = response.data.serverTimestamp;
}
```

## Conflict Resolution Strategy

**Last-Write-Wins (LWW)**

1. Compare `updated_at` timestamps between local and remote records
2. If local is newer → local wins, update remote
3. If remote is newer → remote wins, report conflict
4. If same timestamp → local wins (client preference)
5. Delete actions always win regardless of timestamp

**Timestamp Priority:**
1. `updated_at` (preferred)
2. `created_at`
3. `timestamp`
4. `localTimestamp` (fallback)

## Data Validation

- **User Isolation**: All records must have matching `user_id`
- **Batch Size**: Maximum 100 changes per request
- **Required Fields**: Varies by table (see schemas below)

## Supported Tables

### fasting_sessions

```typescript
{
  id: number;
  user_id: string;
  start_time: string;
  end_time?: string;
  duration_minutes?: number;
  completed: boolean;
  interrupted: boolean;
  plan_type: string;
  interruption_reason?: string;
  created_at: string;
  updated_at: string;
}
```

### hydration_logs

```typescript
{
  id: number;
  user_id: string;
  amount_ml: number;
  timestamp: string;
  created_at: string;
}
```

### user_metrics

```typescript
{
  id: string;
  user_id: string;
  total_fasts: number;
  total_duration_hours: number;
  streak_days: number;
  longest_streak: number;
  last_fast_date?: string;
  created_at: string;
  updated_at: string;
}
```

## Testing

### Run Tests

```bash
cd supabase/functions
deno test --allow-env --allow-net --allow-read sync-user-data/
```

### Test Coverage

- ✅ JWT authentication validation
- ✅ Rate limiting enforcement
- ✅ Request validation (method, body, batch size)
- ✅ Conflict resolution algorithm
- ✅ Batch processing (1-100 records)
- ✅ Multi-table sync operations
- ✅ Server changes detection
- ✅ Error handling and reporting
- ✅ User data isolation
- ✅ CORS handling

### Test Files

- `auth.test.ts` - JWT authentication tests
- `rateLimit.test.ts` - Rate limiting tests
- `conflictResolver.test.ts` - Conflict resolution tests
- `index.test.ts` - Handler unit tests
- `integration.test.ts` - End-to-end integration tests

## Environment Variables

Required in Supabase Edge Function environment:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Error Codes

| Status | Meaning |
|--------|---------|
| 200 | Success (check `success` field for operation status) |
| 400 | Bad request (invalid JSON, missing fields, batch too large) |
| 401 | Unauthorized (missing/invalid JWT) |
| 405 | Method not allowed (use POST) |
| 429 | Rate limit exceeded |
| 500 | Internal server error |

## Performance

- **Batch Size**: Up to 100 records per request
- **Rate Limit**: 100 requests/minute per user
- **Timeout**: 30 seconds per request
- **Concurrent Processing**: Server changes fetched in parallel

## Security

- ✅ JWT validation on every request
- ✅ User data isolation (user_id enforcement)
- ✅ Rate limiting per user
- ✅ Input validation and sanitization
- ✅ Error messages don't leak sensitive data

## Client Integration

See `lib/services/supabase_sync_service.dart` in the Flutter app for client-side sync implementation.

## Development

Built with:
- Deno (Edge Runtime)
- Supabase Edge Functions
- TypeScript
- Last-Write-Wins conflict resolution

Developed using Test-Driven Development (TDD) methodology.

## License

Part of Zendfast project.
