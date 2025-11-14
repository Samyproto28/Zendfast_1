/**
 * CORS utilities for Edge Functions
 */

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/**
 * Handles CORS preflight requests
 */
export function handleCORS(): Response {
  return new Response("ok", {
    status: 200,
    headers: corsHeaders,
  });
}

/**
 * Adds CORS headers to an existing response
 */
export function addCORSHeaders(response: Response): Response {
  const headers = new Headers(response.headers);
  Object.entries(corsHeaders).forEach(([key, value]) => {
    headers.set(key, value);
  });

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
