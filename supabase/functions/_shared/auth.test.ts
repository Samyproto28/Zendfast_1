// Tests for JWT authentication utilities
import { assertEquals, assertExists } from "std/assert/mod.ts";
import { validateJWT } from "./auth.ts";

Deno.test("validateJWT - should reject missing Authorization header", async () => {
  const mockRequest = new Request("http://localhost", {
    method: "POST",
  });

  const result = await validateJWT(mockRequest);

  assertEquals(result.success, false);
  assertEquals(result.error, "Missing Authorization header");
  assertEquals(result.userId, undefined);
});

Deno.test("validateJWT - should reject malformed Authorization header", async () => {
  const mockRequest = new Request("http://localhost", {
    method: "POST",
    headers: {
      "Authorization": "InvalidFormat",
    },
  });

  const result = await validateJWT(mockRequest);

  assertEquals(result.success, false);
  assertExists(result.error);
});

Deno.test("validateJWT - should reject empty Bearer token", async () => {
  const mockRequest = new Request("http://localhost", {
    method: "POST",
    headers: {
      "Authorization": "Bearer ",
    },
  });

  const result = await validateJWT(mockRequest);

  assertEquals(result.success, false);
  assertExists(result.error);
});

Deno.test("validateJWT - should reject invalid JWT token", async () => {
  const mockRequest = new Request("http://localhost", {
    method: "POST",
    headers: {
      "Authorization": "Bearer invalid-jwt-token-12345",
    },
  });

  const result = await validateJWT(mockRequest);

  assertEquals(result.success, false);
  assertExists(result.error);
});

// Note: Testing valid JWT requires actual Supabase connection
// This will be tested in integration tests with real tokens
Deno.test("validateJWT - should handle missing environment variables", async () => {
  // Save current env vars
  const savedUrl = Deno.env.get("SUPABASE_URL");
  const savedKey = Deno.env.get("SUPABASE_ANON_KEY");

  // Remove env vars
  Deno.env.delete("SUPABASE_URL");
  Deno.env.delete("SUPABASE_ANON_KEY");

  const mockRequest = new Request("http://localhost", {
    method: "POST",
    headers: {
      "Authorization": "Bearer some-token",
    },
  });

  const result = await validateJWT(mockRequest);

  assertEquals(result.success, false);
  assertEquals(result.error, "Server configuration error");

  // Restore env vars
  if (savedUrl) Deno.env.set("SUPABASE_URL", savedUrl);
  if (savedKey) Deno.env.set("SUPABASE_ANON_KEY", savedKey);
});
