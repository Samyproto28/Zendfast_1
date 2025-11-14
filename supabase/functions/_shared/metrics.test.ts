/**
 * Unit tests for metrics calculation functions
 * Following TDD approach
 */

import { assertEquals } from "std/assert/mod.ts";
import { calculateTotalHours } from "./metrics.ts";
import type { FastingSession } from "./types.ts";

// Helper to create mock fasting sessions
function createMockSession(
  overrides: Partial<FastingSession>
): FastingSession {
  return {
    id: 1,
    user_id: "test-user-id",
    start_time: "2025-01-01T00:00:00Z",
    end_time: "2025-01-01T16:00:00Z",
    duration_minutes: 960,
    completed: true,
    interrupted: false,
    plan_type: "16_8",
    interruption_reason: null,
    created_at: "2025-01-01T00:00:00Z",
    updated_at: "2025-01-01T00:00:00Z",
    sync_version: 1,
    ...overrides,
  };
}

Deno.test("calculateTotalHours - returns 0 for empty sessions array", () => {
  const result = calculateTotalHours([]);
  assertEquals(result, 0);
});

Deno.test("calculateTotalHours - sums duration of completed sessions only", () => {
  const sessions = [
    createMockSession({ completed: true, duration_minutes: 960 }), // 16 hours
    createMockSession({ id: 2, completed: true, duration_minutes: 720 }), // 12 hours
    createMockSession({ id: 3, completed: false, duration_minutes: 480 }), // Should be ignored
  ];
  const result = calculateTotalHours(sessions);
  assertEquals(result, 28); // 16 + 12 = 28 hours
});

Deno.test("calculateTotalHours - handles null duration_minutes gracefully", () => {
  const sessions = [
    createMockSession({ completed: true, duration_minutes: 960 }), // 16 hours
    createMockSession({ id: 2, completed: true, duration_minutes: null }), // Null - treat as 0
  ];
  const result = calculateTotalHours(sessions);
  assertEquals(result, 16);
});

Deno.test("calculateTotalHours - ignores interrupted sessions", () => {
  const sessions = [
    createMockSession({ completed: true, duration_minutes: 960 }), // 16 hours
    createMockSession({
      id: 2,
      completed: false,
      interrupted: true,
      duration_minutes: 600,
    }), // Should be ignored
  ];
  const result = calculateTotalHours(sessions);
  assertEquals(result, 16);
});

Deno.test("calculateTotalHours - rounds to 2 decimal places", () => {
  const sessions = [
    createMockSession({ completed: true, duration_minutes: 100 }), // 1.6666... hours
  ];
  const result = calculateTotalHours(sessions);
  // Should round to 2 decimal places
  assertEquals(Math.round(result * 100) / 100, 1.67);
});

// ============================================================================
// calculateCurrentStreak tests
// ============================================================================

import { calculateCurrentStreak } from "./metrics.ts";

Deno.test("calculateCurrentStreak - returns 0 for no sessions", () => {
  const result = calculateCurrentStreak([]);
  assertEquals(result, 0);
});

Deno.test("calculateCurrentStreak - counts consecutive days from most recent", () => {
  const sessions = [
    createMockSession({ completed: true, start_time: "2025-01-11T10:00:00Z" }), // Today
    createMockSession({ id: 2, completed: true, start_time: "2025-01-10T10:00:00Z" }), // Yesterday
    createMockSession({ id: 3, completed: true, start_time: "2025-01-09T10:00:00Z" }), // 2 days ago
    createMockSession({ id: 4, completed: false, start_time: "2025-01-08T10:00:00Z" }), // Breaks streak
    createMockSession({ id: 5, completed: true, start_time: "2025-01-07T10:00:00Z" }), // Should not count
  ];
  const result = calculateCurrentStreak(sessions);
  assertEquals(result, 3);
});

Deno.test("calculateCurrentStreak - breaks on gap day", () => {
  const sessions = [
    createMockSession({ completed: true, start_time: "2025-01-11T10:00:00Z" }), // Today
    createMockSession({ id: 2, completed: true, start_time: "2025-01-09T10:00:00Z" }), // Gap!
  ];
  const result = calculateCurrentStreak(sessions);
  assertEquals(result, 1); // Only today counts
});

Deno.test("calculateCurrentStreak - ignores incomplete fasts", () => {
  const sessions = [
    createMockSession({ completed: true, start_time: "2025-01-11T10:00:00Z" }), // Today
    createMockSession({ id: 2, completed: false, start_time: "2025-01-10T10:00:00Z" }), // Incomplete
  ];
  const result = calculateCurrentStreak(sessions);
  assertEquals(result, 1); // Only today counts
});

Deno.test("calculateCurrentStreak - handles same day multiple fasts", () => {
  const sessions = [
    createMockSession({ completed: true, start_time: "2025-01-11T14:00:00Z" }), // Today afternoon
    createMockSession({ id: 2, completed: true, start_time: "2025-01-11T08:00:00Z" }), // Today morning
    createMockSession({ id: 3, completed: true, start_time: "2025-01-10T10:00:00Z" }), // Yesterday
  ];
  const result = calculateCurrentStreak(sessions);
  assertEquals(result, 2); // 2 different days
});

Deno.test("calculateCurrentStreak - returns 1 for single completed fast", () => {
  const sessions = [
    createMockSession({ completed: true, start_time: "2025-01-11T10:00:00Z" }),
  ];
  const result = calculateCurrentStreak(sessions);
  assertEquals(result, 1);
});

// ============================================================================
// calculateSuccessRate tests
// ============================================================================

import { calculateSuccessRate } from "./metrics.ts";

Deno.test("calculateSuccessRate - returns 0 for no sessions", () => {
  const result = calculateSuccessRate([]);
  assertEquals(result, 0);
});

Deno.test("calculateSuccessRate - calculates percentage correctly", () => {
  const sessions = [
    createMockSession({ completed: true }),
    createMockSession({ id: 2, completed: true }),
    createMockSession({ id: 3, completed: false }),
    createMockSession({ id: 4, completed: false }),
  ];
  const result = calculateSuccessRate(sessions);
  assertEquals(result, 50); // 2/4 = 50%
});

Deno.test("calculateSuccessRate - returns 100 for all completed", () => {
  const sessions = [
    createMockSession({ completed: true }),
    createMockSession({ id: 2, completed: true }),
  ];
  const result = calculateSuccessRate(sessions);
  assertEquals(result, 100);
});

Deno.test("calculateSuccessRate - returns 0 for all incomplete", () => {
  const sessions = [
    createMockSession({ completed: false }),
    createMockSession({ id: 2, completed: false }),
  ];
  const result = calculateSuccessRate(sessions);
  assertEquals(result, 0);
});

// ============================================================================
// calculatePanicUsage tests
// ============================================================================

import { calculatePanicUsage } from "./metrics.ts";
import type { AnalyticsEvent } from "./types.ts";

function createMockPanicEvent(
  overrides: Partial<AnalyticsEvent>
): AnalyticsEvent {
  return {
    event_id: "event-1",
    user_id: "test-user-id",
    event_type: "panic_button_used",
    event_data: {},
    timestamp: "2025-01-11T10:00:00Z",
    session_id: "1",
    updated_at: "2025-01-11T10:00:00Z",
    ...overrides,
  };
}

Deno.test("calculatePanicUsage - returns null metrics for no panic events", () => {
  const sessions = [createMockSession({ completed: true })];
  const panicEvents: AnalyticsEvent[] = [];
  const result = calculatePanicUsage(sessions, panicEvents);

  assertEquals(result.completionRateAfterPanic, null);
  assertEquals(result.usageFrequency, 0);
  assertEquals(result.totalPanicEvents, 0);
});

Deno.test("calculatePanicUsage - calculates completion rate after panic", () => {
  const sessions = [
    createMockSession({ id: 1, completed: true }), // Panic used, completed
    createMockSession({ id: 2, completed: false }), // Panic used, interrupted
    createMockSession({ id: 3, completed: true }), // No panic
  ];
  const panicEvents = [
    createMockPanicEvent({ session_id: "1" }),
    createMockPanicEvent({ event_id: "event-2", session_id: "2" }),
  ];
  const result = calculatePanicUsage(sessions, panicEvents);

  assertEquals(result.completionRateAfterPanic, 50); // 1/2 = 50%
});

Deno.test("calculatePanicUsage - calculates average elapsed time at panic", () => {
  const sessions = [
    createMockSession({ id: 1, duration_minutes: 960 }), // 16-hour fast
  ];
  const panicEvents = [
    createMockPanicEvent({
      session_id: "1",
      event_data: { elapsed_minutes: 480 }, // 8 hours in
    }),
  ];
  const result = calculatePanicUsage(sessions, panicEvents);

  assertEquals(result.averageElapsedMinutesAtPanic, 480);
  assertEquals(result.averageProgressPercentageAtPanic, 50); // 50% through fast
});

Deno.test("calculatePanicUsage - handles multiple panic events per session", () => {
  const sessions = [createMockSession({ id: 1 })];
  const panicEvents = [
    createMockPanicEvent({ session_id: "1" }),
    createMockPanicEvent({ event_id: "event-2", session_id: "1" }),
    createMockPanicEvent({ event_id: "event-3", session_id: "1" }),
  ];
  const result = calculatePanicUsage(sessions, panicEvents);

  assertEquals(result.averagePanicsPerSession, 3);
  assertEquals(result.totalPanicEvents, 3);
});

Deno.test("calculatePanicUsage - calculates usage frequency", () => {
  const sessions = [
    createMockSession({ id: 1 }),
    createMockSession({ id: 2 }),
    createMockSession({ id: 3 }),
  ];
  const panicEvents = [
    createMockPanicEvent({ session_id: "1" }),
    createMockPanicEvent({ event_id: "event-2", session_id: "2" }),
  ];
  const result = calculatePanicUsage(sessions, panicEvents);

  // 2 panic events / 3 sessions = 0.67 (rounded to 2 decimal places)
  assertEquals(Math.round(result.usageFrequency * 100) / 100, 0.67);
});
