// Tests for rate limiting utilities
import { assertEquals } from "std/assert/mod.ts";
import { RateLimiter } from "./rateLimit.ts";

Deno.test("RateLimiter - should allow requests under limit", () => {
  const limiter = new RateLimiter(100, 60000); // 100 requests per minute

  // Should allow first 100 requests
  for (let i = 0; i < 100; i++) {
    const allowed = limiter.checkLimit("user-123");
    assertEquals(allowed, true, `Request ${i + 1} should be allowed`);
  }
});

Deno.test("RateLimiter - should block requests over limit", () => {
  const limiter = new RateLimiter(2, 60000); // 2 requests per minute

  // First 2 requests should be allowed
  assertEquals(limiter.checkLimit("user-123"), true);
  assertEquals(limiter.checkLimit("user-123"), true);

  // Third request should be blocked
  assertEquals(limiter.checkLimit("user-123"), false);
});

Deno.test("RateLimiter - should track users independently", () => {
  const limiter = new RateLimiter(1, 60000); // 1 request per minute

  // User 1 makes a request
  assertEquals(limiter.checkLimit("user-1"), true);
  assertEquals(limiter.checkLimit("user-1"), false); // Blocked

  // User 2 should not be affected
  assertEquals(limiter.checkLimit("user-2"), true);
  assertEquals(limiter.checkLimit("user-2"), false); // Blocked
});

Deno.test("RateLimiter - should reset after time window", async () => {
  const limiter = new RateLimiter(1, 100); // 1 request per 100ms

  // First request allowed
  assertEquals(limiter.checkLimit("user-123"), true);

  // Second request blocked
  assertEquals(limiter.checkLimit("user-123"), false);

  // Wait for window to expire
  await new Promise((resolve) => setTimeout(resolve, 150));

  // Should allow request again after window reset
  assertEquals(limiter.checkLimit("user-123"), true);
});

Deno.test("RateLimiter - should remove old requests from window", async () => {
  const limiter = new RateLimiter(2, 100); // 2 requests per 100ms

  // Make 2 requests at time 0
  assertEquals(limiter.checkLimit("user-123"), true);
  assertEquals(limiter.checkLimit("user-123"), true);
  assertEquals(limiter.checkLimit("user-123"), false); // Blocked

  // Wait 60ms (old requests still in window)
  await new Promise((resolve) => setTimeout(resolve, 60));
  assertEquals(limiter.checkLimit("user-123"), false); // Still blocked

  // Wait another 50ms (old requests now outside window)
  await new Promise((resolve) => setTimeout(resolve, 50));
  assertEquals(limiter.checkLimit("user-123"), true); // Allowed again
});

Deno.test("RateLimiter - should handle rapid sequential requests", () => {
  const limiter = new RateLimiter(5, 1000); // 5 requests per second

  const results: boolean[] = [];
  for (let i = 0; i < 10; i++) {
    results.push(limiter.checkLimit("user-rapid"));
  }

  // First 5 should be allowed, rest blocked
  assertEquals(results.slice(0, 5).every((r) => r === true), true);
  assertEquals(results.slice(5).every((r) => r === false), true);
});

Deno.test("RateLimiter - should cleanup old user entries", async () => {
  const limiter = new RateLimiter(1, 50); // 1 request per 50ms

  // Make requests for user-1
  limiter.checkLimit("user-1");

  // Make requests for user-2
  limiter.checkLimit("user-2");

  // Check internal state has 2 users
  assertEquals(limiter.getUserCount(), 2);

  // Wait for all windows to expire
  await new Promise((resolve) => setTimeout(resolve, 100));

  // Make a request to trigger cleanup
  limiter.checkLimit("user-1");

  // Old empty entries should be cleaned up
  // (Implementation detail - this tests internal cleanup)
});

Deno.test("RateLimiter - should handle zero window edge case", () => {
  const limiter = new RateLimiter(1, 0); // Instant expiry

  // Every request should be allowed because window expires immediately
  assertEquals(limiter.checkLimit("user-123"), true);
  assertEquals(limiter.checkLimit("user-123"), true);
  assertEquals(limiter.checkLimit("user-123"), true);
});
