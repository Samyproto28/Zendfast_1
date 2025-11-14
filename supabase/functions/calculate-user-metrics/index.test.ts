/**
 * Tests for calculate-user-metrics Edge Function
 * Following TDD approach: Write tests first, then implement
 */

import { assertEquals, assertExists } from "std/assert/mod.ts";
import { handler } from "./index.ts";

Deno.test("Base Structure - should return 400 when userId is missing", async () => {
  const req = new Request("http://localhost", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({}),
  });

  const res = await handler(req);
  assertEquals(res.status, 400);

  const body = await res.json();
  assertExists(body.error);
  assertEquals(body.error, "Invalid or missing userId");
});

Deno.test("Base Structure - should return 400 for invalid UUID format", async () => {
  const req = new Request("http://localhost", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId: "invalid-uuid-123" }),
  });

  const res = await handler(req);
  assertEquals(res.status, 400);

  const body = await res.json();
  assertExists(body.error);
  assertEquals(body.error, "Invalid or missing userId");
});

Deno.test("Base Structure - should handle OPTIONS request with CORS headers", async () => {
  const req = new Request("http://localhost", {
    method: "OPTIONS",
  });

  const res = await handler(req);
  assertEquals(res.status, 200);
  assertEquals(res.headers.get("Access-Control-Allow-Origin"), "*");
  assertEquals(
    res.headers.get("Access-Control-Allow-Methods"),
    "POST, OPTIONS"
  );
});

Deno.test("Base Structure - should return 400 for invalid JSON", async () => {
  const req = new Request("http://localhost", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: "not-valid-json{{{",
  });

  const res = await handler(req);
  assertEquals(res.status, 400);

  const body = await res.json();
  assertExists(body.error);
});

Deno.test("Base Structure - should return CORS headers in all responses", async () => {
  const req = new Request("http://localhost", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({}),
  });

  const res = await handler(req);
  assertEquals(res.headers.get("Access-Control-Allow-Origin"), "*");
  assertEquals(res.headers.get("Content-Type"), "application/json");
});

Deno.test("Base Structure - should accept valid UUID", async () => {
  const validUUID = "550e8400-e29b-41d4-a716-446655440000";
  const req = new Request("http://localhost", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId: validUUID }),
  });

  const res = await handler(req);
  // For now, we expect it to fail because we haven't implemented the full logic
  // But it should NOT be a 400 validation error
  // It might be 500 (no Supabase connection) or 200 (if mock data works)
  assertEquals(res.status !== 400, true);
});
