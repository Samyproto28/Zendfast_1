/**
 * JSON response utilities for Edge Functions
 */

import { corsHeaders } from "./cors.ts";

/**
 * Creates a JSON response with CORS headers
 */
export function jsonResponse(
  data: unknown,
  status = 200,
  additionalHeaders: Record<string, string> = {}
): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
      ...additionalHeaders,
    },
  });
}

/**
 * Creates an error response with CORS headers
 */
export function errorResponse(
  message: string,
  status = 500,
  details?: string
): Response {
  return jsonResponse(
    {
      error: message,
      ...(details && { details }),
    },
    status
  );
}

/**
 * Validates that a string is a valid UUID v4
 */
export function isValidUUID(uuid: string): boolean {
  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
}
