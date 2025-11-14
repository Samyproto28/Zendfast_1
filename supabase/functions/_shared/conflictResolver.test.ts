// Tests for conflict resolution algorithm
import { assertEquals, assertExists } from "std/assert/mod.ts";
import { resolveConflict } from "./conflictResolver.ts";
import type { LocalChange } from "./syncTypes.ts";

// ========== Timestamp Comparison Tests ==========

Deno.test("resolveConflict - local newer wins (last-write-wins)", () => {
  const localChange: LocalChange = {
    table: "fasting_sessions",
    action: "update",
    data: {
      id: 1,
      user_id: "user-123",
      plan_type: "16:8",
      updated_at: "2025-01-11T12:00:00Z", // Newer
    },
    localTimestamp: "2025-01-11T12:00:00Z",
  };

  const remoteRecord = {
    id: 1,
    user_id: "user-123",
    plan_type: "14:10",
    updated_at: "2025-01-11T11:00:00Z", // Older
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertEquals(result.winner, "local");
  assertEquals(result.shouldUpdate, true);
  assertExists(result.finalData);
  assertEquals(result.finalData.plan_type, "16:8"); // Local data wins
  assertEquals(result.conflict, undefined); // No conflict reported when local wins
});

Deno.test("resolveConflict - remote newer wins (last-write-wins)", () => {
  const localChange: LocalChange = {
    table: "fasting_sessions",
    action: "update",
    data: {
      id: 1,
      user_id: "user-123",
      plan_type: "16:8",
      updated_at: "2025-01-11T11:00:00Z", // Older
    },
    localTimestamp: "2025-01-11T11:00:00Z",
  };

  const remoteRecord = {
    id: 1,
    user_id: "user-123",
    plan_type: "14:10",
    updated_at: "2025-01-11T12:00:00Z", // Newer
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertEquals(result.winner, "remote");
  assertEquals(result.shouldUpdate, false); // Don't update remote with older local data
  assertExists(result.conflict); // Conflict should be reported
  assertEquals(result.conflict!.table, "fasting_sessions");
  assertExists(result.conflict!.localData);
  assertExists(result.conflict!.remoteData);
});

Deno.test("resolveConflict - handles same timestamp (tie-breaker)", () => {
  const sameTimestamp = "2025-01-11T12:00:00Z";

  const localChange: LocalChange = {
    table: "hydration_logs",
    action: "update",
    data: {
      id: 5,
      amount_ml: 500,
      updated_at: sameTimestamp,
    },
    localTimestamp: sameTimestamp,
  };

  const remoteRecord = {
    id: 5,
    amount_ml: 250,
    updated_at: sameTimestamp,
  };

  const result = resolveConflict(localChange, remoteRecord);

  // With same timestamp, prefer local (client wins tie)
  assertEquals(result.winner, "local");
  assertEquals(result.shouldUpdate, true);
});

// ========== Field Handling Tests ==========

Deno.test("resolveConflict - uses created_at if updated_at missing", () => {
  const localChange: LocalChange = {
    table: "fasting_sessions",
    action: "insert",
    data: {
      id: 10,
      created_at: "2025-01-11T12:00:00Z",
    },
    localTimestamp: "2025-01-11T12:00:00Z",
  };

  const remoteRecord = {
    id: 10,
    created_at: "2025-01-11T11:00:00Z",
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertEquals(result.winner, "local");
  assertEquals(result.shouldUpdate, true);
});

Deno.test("resolveConflict - handles records without timestamps gracefully", () => {
  const localChange: LocalChange = {
    table: "user_metrics",
    action: "update",
    data: {
      id: "metric-1",
      total_fasts: 10,
    },
    localTimestamp: "2025-01-11T12:00:00Z",
  };

  const remoteRecord = {
    id: "metric-1",
    total_fasts: 8,
  };

  const result = resolveConflict(localChange, remoteRecord);

  // Should fall back to localTimestamp when remote has no timestamp
  assertEquals(result.winner, "local");
  assertEquals(result.shouldUpdate, true);
});

// ========== Insert Action Tests ==========

Deno.test("resolveConflict - insert action with no remote record", () => {
  const localChange: LocalChange = {
    table: "fasting_sessions",
    action: "insert",
    data: {
      user_id: "user-123",
      start_time: "2025-01-11T10:00:00Z",
      plan_type: "16:8",
    },
    localTimestamp: "2025-01-11T10:00:00Z",
  };

  const result = resolveConflict(localChange, null);

  assertEquals(result.winner, "local");
  assertEquals(result.shouldUpdate, true);
  assertEquals(result.conflict, undefined);
});

// ========== Delete Action Tests ==========

Deno.test("resolveConflict - delete action always wins", () => {
  const localChange: LocalChange = {
    table: "hydration_logs",
    action: "delete",
    data: {
      id: 15,
    },
    localTimestamp: "2025-01-11T12:00:00Z",
  };

  const remoteRecord = {
    id: 15,
    amount_ml: 300,
    updated_at: "2025-01-11T13:00:00Z", // Even with newer remote timestamp
  };

  const result = resolveConflict(localChange, remoteRecord);

  // Delete should win regardless of timestamp
  assertEquals(result.winner, "local");
  assertEquals(result.shouldUpdate, true);
  assertEquals(result.conflict, undefined);
});

// ========== Different Table Tests ==========

Deno.test("resolveConflict - works with fasting_sessions table", () => {
  const localChange: LocalChange = {
    table: "fasting_sessions",
    action: "update",
    data: {
      id: 100,
      completed: true,
      updated_at: "2025-01-11T15:00:00Z",
    },
    localTimestamp: "2025-01-11T15:00:00Z",
  };

  const remoteRecord = {
    id: 100,
    completed: false,
    updated_at: "2025-01-11T14:00:00Z",
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertEquals(result.winner, "local");
  assertEquals(result.finalData.completed, true);
});

Deno.test("resolveConflict - works with hydration_logs table", () => {
  const localChange: LocalChange = {
    table: "hydration_logs",
    action: "update",
    data: {
      id: 50,
      amount_ml: 600,
      timestamp: "2025-01-11T16:00:00Z",
    },
    localTimestamp: "2025-01-11T16:00:00Z",
  };

  const remoteRecord = {
    id: 50,
    amount_ml: 500,
    timestamp: "2025-01-11T17:00:00Z", // Remote newer
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertEquals(result.winner, "remote");
  assertExists(result.conflict);
});

Deno.test("resolveConflict - works with user_metrics table", () => {
  const localChange: LocalChange = {
    table: "user_metrics",
    action: "update",
    data: {
      id: "metric-abc",
      total_fasts: 25,
      updated_at: "2025-01-11T18:00:00Z",
    },
    localTimestamp: "2025-01-11T18:00:00Z",
  };

  const remoteRecord = {
    id: "metric-abc",
    total_fasts: 20,
    updated_at: "2025-01-11T17:00:00Z",
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertEquals(result.winner, "local");
  assertEquals(result.finalData.total_fasts, 25);
});

// ========== Conflict Reporting Tests ==========

Deno.test("resolveConflict - conflict includes all necessary data", () => {
  const localChange: LocalChange = {
    table: "fasting_sessions",
    action: "update",
    data: {
      id: 200,
      interrupted: true,
      updated_at: "2025-01-11T10:00:00Z",
    },
    localTimestamp: "2025-01-11T10:00:00Z",
  };

  const remoteRecord = {
    id: 200,
    interrupted: false,
    updated_at: "2025-01-11T11:00:00Z",
  };

  const result = resolveConflict(localChange, remoteRecord);

  assertExists(result.conflict);
  assertEquals(result.conflict!.table, "fasting_sessions");
  assertEquals(result.conflict!.localData.interrupted, true);
  assertEquals(result.conflict!.remoteData.interrupted, false);
  assertExists(result.conflict!.resolvedData);
  assertEquals(result.conflict!.resolvedData.interrupted, false); // Remote wins
});
