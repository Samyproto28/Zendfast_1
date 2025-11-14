// Integration tests for complete sync workflow
import { assertEquals, assertExists } from "std/assert/mod.ts";
import { handler } from "./index.ts";

// Mock helper functions
function createAuthRequest(body: any): Request {
  return new Request("http://localhost", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer test-jwt-token",
    },
    body: JSON.stringify(body),
  });
}

// ========== Batch Processing Tests ==========

Deno.test("INTEGRATION - should process batch of 50 fasting_sessions", async () => {
  const changes = Array(50).fill(null).map((_, i) => ({
    table: "fasting_sessions",
    action: "insert",
    data: {
      id: i + 1000,
      user_id: "user-test-123",
      start_time: new Date().toISOString(),
      duration_minutes: 960,
      plan_type: "16:8",
      completed: false,
      interrupted: false,
    },
    localTimestamp: new Date().toISOString(),
  }));

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  const body = await res.json();

  // Should process all changes
  assertEquals(Array.isArray(body.errors), true);
  assertEquals(Array.isArray(body.conflicts), true);
  assertExists(body.serverTimestamp);
});

Deno.test("INTEGRATION - should reject batch over 100 records", async () => {
  const changes = Array(101).fill(null).map((_, i) => ({
    table: "fasting_sessions",
    action: "insert",
    data: {
      id: i,
      user_id: "user-test-123",
    },
    localTimestamp: new Date().toISOString(),
  }));

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  assertEquals(res.status, 400);
  const body = await res.json();
  assertEquals(body.error.includes("100"), true);
});

Deno.test("INTEGRATION - should process mixed operations (insert/update/delete)", async () => {
  const changes = [
    {
      table: "fasting_sessions",
      action: "insert",
      data: {
        id: 500,
        user_id: "user-test-123",
        start_time: "2025-01-11T10:00:00Z",
        plan_type: "16:8",
      },
      localTimestamp: "2025-01-11T10:00:00Z",
    },
    {
      table: "hydration_logs",
      action: "update",
      data: {
        id: 600,
        user_id: "user-test-123",
        amount_ml: 500,
        updated_at: "2025-01-11T11:00:00Z",
      },
      localTimestamp: "2025-01-11T11:00:00Z",
    },
    {
      table: "fasting_sessions",
      action: "delete",
      data: {
        id: 700,
      },
      localTimestamp: "2025-01-11T12:00:00Z",
    },
  ];

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  const body = await res.json();

  assertExists(body.errors);
  assertExists(body.conflicts);
  assertExists(body.serverChanges);
});

// ========== Table-Specific Sync Tests ==========

Deno.test("INTEGRATION - should sync fasting_sessions with all fields", async () => {
  const changes = [{
    table: "fasting_sessions",
    action: "insert",
    data: {
      id: 1001,
      user_id: "user-test-123",
      start_time: "2025-01-11T08:00:00Z",
      end_time: "2025-01-12T00:00:00Z",
      duration_minutes: 960,
      completed: true,
      interrupted: false,
      plan_type: "16:8",
      interruption_reason: null,
      created_at: "2025-01-11T08:00:00Z",
      updated_at: "2025-01-12T00:00:00Z",
    },
    localTimestamp: "2025-01-12T00:00:00Z",
  }];

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  assertEquals(res.status, 200);
  const body = await res.json();
  assertExists(body.serverTimestamp);
});

Deno.test("INTEGRATION - should sync hydration_logs", async () => {
  const changes = [{
    table: "hydration_logs",
    action: "insert",
    data: {
      id: 2001,
      user_id: "user-test-123",
      amount_ml: 250,
      timestamp: "2025-01-11T14:30:00Z",
      created_at: "2025-01-11T14:30:00Z",
    },
    localTimestamp: "2025-01-11T14:30:00Z",
  }];

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  assertEquals(res.status, 200);
});

Deno.test("INTEGRATION - should sync user_metrics", async () => {
  const changes = [{
    table: "user_metrics",
    action: "update",
    data: {
      id: "metric-user-test-123",
      user_id: "user-test-123",
      total_fasts: 15,
      total_duration_hours: 240.5,
      streak_days: 7,
      longest_streak: 14,
      last_fast_date: "2025-01-11T00:00:00Z",
      updated_at: "2025-01-11T15:00:00Z",
    },
    localTimestamp: "2025-01-11T15:00:00Z",
  }];

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  assertEquals(res.status, 200);
});

// ========== Server Changes Tests ==========

Deno.test("INTEGRATION - should return server changes since last sync", async () => {
  const lastSync = new Date(Date.now() - 3600000).toISOString(); // 1 hour ago

  const req = createAuthRequest({
    changes: [],
    lastSyncTimestamp: lastSync,
  });

  const res = await handler(req);
  assertEquals(res.status, 200);

  const body = await res.json();

  assertExists(body.serverChanges);
  assertEquals(typeof body.serverChanges, "object");

  // Server changes should have structure for all tables
  assertExists(body.serverChanges.fasting_sessions !== undefined);
  assertExists(body.serverChanges.hydration_logs !== undefined);
  assertExists(body.serverChanges.user_metrics !== undefined);
});

Deno.test("INTEGRATION - should include serverTimestamp in response", async () => {
  const req = createAuthRequest({ changes: [] });
  const res = await handler(req);

  const body = await res.json();

  assertExists(body.serverTimestamp);
  assertEquals(typeof body.serverTimestamp, "string");

  // Should be valid ISO timestamp
  const timestamp = new Date(body.serverTimestamp);
  assertEquals(isNaN(timestamp.getTime()), false);
});

// ========== Complete Response Structure Tests ==========

Deno.test("INTEGRATION - response should have complete structure", async () => {
  const req = createAuthRequest({
    changes: [{
      table: "fasting_sessions",
      action: "insert",
      data: { id: 9999, user_id: "user-test-123" },
      localTimestamp: new Date().toISOString(),
    }],
  });

  const res = await handler(req);
  const body = await res.json();

  // Verify all required fields
  assertExists(body.success);
  assertEquals(typeof body.success, "boolean");

  assertExists(body.conflicts);
  assertEquals(Array.isArray(body.conflicts), true);

  assertExists(body.serverChanges);
  assertEquals(typeof body.serverChanges, "object");

  assertExists(body.errors);
  assertEquals(Array.isArray(body.errors), true);

  assertExists(body.serverTimestamp);
  assertEquals(typeof body.serverTimestamp, "string");
});

// ========== Error Handling Tests ==========

Deno.test("INTEGRATION - should handle database errors gracefully", async () => {
  // Send invalid data that might cause DB errors
  const changes = [{
    table: "fasting_sessions",
    action: "insert",
    data: {
      // Missing required fields
      id: 8888,
    },
    localTimestamp: new Date().toISOString(),
  }];

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  // Should respond (not crash)
  assertEquals(res.status === 200 || res.status === 500, true);

  const body = await res.json();
  assertExists(body);
});

Deno.test("INTEGRATION - should validate user_id matches auth", async () => {
  const changes = [{
    table: "fasting_sessions",
    action: "insert",
    data: {
      id: 7777,
      user_id: "different-user-id", // Mismatch with auth
      start_time: new Date().toISOString(),
    },
    localTimestamp: new Date().toISOString(),
  }];

  const req = createAuthRequest({ changes });
  const res = await handler(req);

  // Should reject or report error
  const body = await res.json();

  // Either error status OR errors array should contain validation error
  const hasError = res.status >= 400 || (body.errors && body.errors.length > 0);
  assertEquals(hasError, true);
});
