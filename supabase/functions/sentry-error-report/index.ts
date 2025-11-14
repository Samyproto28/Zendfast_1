/**
 * Sentry Error Report Edge Function
 * Receives error reports from other Edge Functions and forwards to Sentry
 * Implements: Validation, Sanitization, Rate Limiting, Circuit Breaker
 */

/**
 * CORS headers for cross-function communication
 */
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/**
 * Error request payload structure
 */
interface ErrorPayload {
  error: string;
  userId: string;
  context: Record<string, unknown>;
  stackTrace?: string;
  functionName?: string;
  timestamp?: number;
}

/**
 * Sanitized context type
 */
interface SanitizedContext {
  [key: string]: unknown;
}

/**
 * Rate Limiter Class
 * Implements sliding window rate limiting per user
 */
export class RateLimiter {
  private requests: Map<string, number[]> = new Map();

  constructor(
    private maxRequests: number, // e.g., 10
    private windowMs: number // e.g., 60000 (1 minute)
  ) {}

  /**
   * Check if user is within rate limit
   * @param userId - User ID to check
   * @returns True if within limit, false if exceeded
   */
  checkLimit(userId: string): boolean {
    const now = Date.now();
    const userRequests = this.requests.get(userId) || [];

    // Remove old requests outside time window
    const validRequests = userRequests.filter(
      (timestamp) => now - timestamp < this.windowMs
    );

    if (validRequests.length >= this.maxRequests) {
      this.requests.set(userId, validRequests);
      return false; // Rate limit exceeded
    }

    validRequests.push(now);
    this.requests.set(userId, validRequests);

    // Cleanup to prevent memory leaks (1% chance)
    this.cleanup(now);

    return true; // Allow request
  }

  /**
   * Cleanup old entries to prevent memory leaks
   * @param now - Current timestamp
   */
  private cleanup(now: number): void {
    if (Math.random() > 0.01) return; // Run 1% of the time

    for (const [userId, timestamps] of this.requests.entries()) {
      const validTimestamps = timestamps.filter(
        (ts) => now - ts < this.windowMs
      );
      if (validTimestamps.length === 0) {
        this.requests.delete(userId);
      }
    }
  }
}

/**
 * Circuit Breaker Class
 * Implements circuit breaker pattern to prevent cascading failures
 */
export class CircuitBreaker {
  private failureCount: number = 0;
  private lastFailureTime: number = 0;
  private state: "CLOSED" | "OPEN" | "HALF_OPEN" = "CLOSED";

  constructor(
    private threshold: number = 5, // Fail 5 times
    private resetTimeoutMs: number = 300_000 // Pause 5 minutes
  ) {}

  /**
   * Check if circuit allows attempt
   * @returns True if can attempt, false if blocked
   */
  canAttempt(): boolean {
    const now = Date.now();

    if (this.state === "OPEN") {
      // Check if timeout has passed
      if (now - this.lastFailureTime >= this.resetTimeoutMs) {
        this.state = "HALF_OPEN";
        return true; // Try one request
      }
      return false; // Still paused
    }

    return true; // CLOSED or HALF_OPEN
  }

  /**
   * Record successful operation
   */
  recordSuccess(): void {
    this.failureCount = 0;
    this.state = "CLOSED";
  }

  /**
   * Record failed operation
   */
  recordFailure(): void {
    this.failureCount++;
    this.lastFailureTime = Date.now();

    if (this.failureCount >= this.threshold) {
      this.state = "OPEN";
      console.warn(
        `🔴 Circuit breaker OPEN - paused for ${this.resetTimeoutMs / 1000}s`
      );
    }
  }

  /**
   * Get current circuit state
   * @returns Current state
   */
  getState(): string {
    return this.state;
  }
}

/**
 * Environment validation result
 */
interface EnvValidation {
  valid: boolean;
  missing?: string[];
}

/**
 * Allowlist of safe fields to include in context
 */
const ALLOWED_FIELDS = new Set([
  "function_name",
  "stack_trace",
  "timestamp",
  "error_type",
  "user_agent",
  "platform",
  "environment",
  "request_id",
  "http_status",
  "url",
  "method",
]);

/**
 * Sensitive field patterns to redact
 */
const SENSITIVE_PATTERNS = [
  /password/i,
  /token/i,
  /key/i,
  /secret/i,
  /auth/i,
  /bearer/i,
  /email/i,
  /phone/i,
  /ssn/i,
  /credit/i,
  /card/i,
  /api[_-]?key/i,
];

/**
 * Sanitize data by removing sensitive fields and applying allowlist
 * @param context - Context object to sanitize
 * @returns Sanitized context object
 */
export function sanitizeData(
  context: Record<string, unknown>
): SanitizedContext {
  const sanitized: SanitizedContext = {};

  for (const [key, value] of Object.entries(context)) {
    // Check if key matches sensitive pattern
    const isSensitive = SENSITIVE_PATTERNS.some((pattern) =>
      pattern.test(key)
    );

    if (isSensitive) {
      sanitized[key] = "[REDACTED]";
      continue;
    }

    // Only include if in allowlist
    if (ALLOWED_FIELDS.has(key)) {
      // Recursively sanitize nested objects
      if (typeof value === "object" && value !== null && !Array.isArray(value)) {
        sanitized[key] = sanitizeData(value as Record<string, unknown>);
      } else {
        sanitized[key] = value;
      }
    }
  }

  return sanitized;
}

/**
 * Validate required environment variables
 * @returns Validation result with missing variables if any
 */
function validateEnvironment(): EnvValidation {
  const required = ["SENTRY_DSN", "SENTRY_PROJECT_ID", "SENTRY_AUTH_TOKEN"];
  const missing = required.filter((key) => !Deno.env.get(key));

  if (missing.length > 0) {
    return { valid: false, missing };
  }

  return { valid: true };
}

/**
 * Create JSON response
 * @param data - Response data
 * @param status - HTTP status code
 * @returns Response object
 */
function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });
}

/**
 * Create error response
 * @param message - Error message
 * @param status - HTTP status code
 * @returns Error response
 */
function errorResponse(message: string, status = 500): Response {
  return jsonResponse({ error: message }, status);
}

/**
 * Validate error payload structure
 * @param payload - Payload to validate
 * @returns True if valid, false otherwise
 */
function validatePayload(payload: unknown): payload is ErrorPayload {
  if (typeof payload !== "object" || payload === null) {
    return false;
  }

  const p = payload as Partial<ErrorPayload>;

  return (
    typeof p.error === "string" &&
    typeof p.userId === "string" &&
    typeof p.context === "object" &&
    p.context !== null
  );
}

/**
 * Rate limiters for error reporting
 * - Minute limiter: 10 errors per minute per user
 * - Hour limiter: 100 errors per hour per user
 */
const minuteRateLimiter = new RateLimiter(10, 60_000); // 10 per minute
const hourRateLimiter = new RateLimiter(100, 3_600_000); // 100 per hour

/**
 * Circuit breaker for Sentry API calls
 */
const sentryCircuitBreaker = new CircuitBreaker(5, 300_000); // 5 failures, 5 min pause

/**
 * Sentry API timeout in milliseconds
 */
export const SENTRY_TIMEOUT_MS = 10_000; // 10 seconds

/**
 * Build Sentry API URL
 * @param projectId - Sentry project ID
 * @returns Sentry envelope endpoint URL
 */
export function buildSentryUrl(projectId: string): string {
  return `https://sentry.io/api/${projectId}/envelope/`;
}

/**
 * Format error payload as Sentry envelope
 * @param payload - Error payload
 * @returns Sentry envelope string (3 lines)
 */
export function formatSentryEnvelope(payload: ErrorPayload): string {
  const eventId = crypto.randomUUID();
  const sentryDsn = Deno.env.get("SENTRY_DSN") || "";
  const environment = Deno.env.get("ENVIRONMENT") || "development";

  // Envelope header
  const envelopeHeader = {
    event_id: eventId,
    dsn: sentryDsn,
    sent_at: new Date().toISOString(),
  };

  // Item header
  const itemHeader = {
    type: "event",
    content_type: "application/json",
  };

  // Event payload
  const event = {
    event_id: eventId,
    timestamp: payload.timestamp
      ? Math.floor(payload.timestamp / 1000)
      : Math.floor(Date.now() / 1000),
    platform: "edge-function",
    environment,
    level: "error",
    message: payload.error,
    user: { id: payload.userId },
    extra: sanitizeData(payload.context),
    tags: {
      function_name: payload.functionName || "unknown",
    },
  };

  // Add stack trace if available
  if (payload.stackTrace) {
    (event as any).stacktrace = { frames: [{ filename: "edge-function", function: payload.functionName }] };
  }

  // Join with newlines to create envelope
  return [
    JSON.stringify(envelopeHeader),
    JSON.stringify(itemHeader),
    JSON.stringify(event),
  ].join("\n");
}

/**
 * Send error to Sentry API
 * @param payload - Error payload
 * @returns True if sent successfully, false otherwise
 */
async function sendToSentry(payload: ErrorPayload): Promise<boolean> {
  // Check circuit breaker
  if (!sentryCircuitBreaker.canAttempt()) {
    console.warn("🔴 Circuit breaker OPEN - skipping Sentry send");
    return false;
  }

  try {
    const projectId = Deno.env.get("SENTRY_PROJECT_ID");
    const authToken = Deno.env.get("SENTRY_AUTH_TOKEN");

    if (!projectId || !authToken) {
      throw new Error("Missing SENTRY_PROJECT_ID or SENTRY_AUTH_TOKEN");
    }

    const url = buildSentryUrl(projectId);
    const envelope = formatSentryEnvelope(payload);

    // Create abort controller for timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), SENTRY_TIMEOUT_MS);

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${authToken}`,
          "Content-Type": "application/x-sentry-envelope",
        },
        body: envelope,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.ok) {
        sentryCircuitBreaker.recordSuccess();
        console.log("✅ Error sent to Sentry successfully");
        return true;
      } else {
        const errorText = await response.text();
        console.error(
          `⚠️ Sentry API error: ${response.status} - ${errorText}`
        );
        sentryCircuitBreaker.recordFailure();
        return false;
      }
    } catch (fetchError) {
      clearTimeout(timeoutId);

      if (fetchError instanceof Error && fetchError.name === "AbortError") {
        console.error("⏱️ Sentry request timeout");
      } else {
        console.error("❌ Sentry fetch error:", fetchError);
      }

      sentryCircuitBreaker.recordFailure();
      return false;
    }
  } catch (error) {
    console.error("❌ Sentry send error:", error);
    sentryCircuitBreaker.recordFailure();
    return false;
  }
}

/**
 * Main handler function
 * @param req - Request object
 * @returns Response object
 */
async function handler(req: Request): Promise<Response> {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    // Validate environment variables
    const envCheck = validateEnvironment();
    if (!envCheck.valid) {
      console.error("❌ Missing environment variables:", envCheck.missing);
      return errorResponse(
        `Missing required environment variables: ${envCheck.missing?.join(", ")}`,
        500
      );
    }

    // Validate HTTP method
    if (req.method !== "POST") {
      return errorResponse("Method not allowed", 405);
    }

    // Parse request body
    let requestData: unknown;
    try {
      requestData = await req.json();
    } catch {
      return errorResponse("Invalid JSON", 400);
    }

    // Validate payload structure
    if (!validatePayload(requestData)) {
      return errorResponse(
        "Invalid payload: requires error, userId, and context fields",
        400
      );
    }

    // Check rate limits
    const userId = requestData.userId;

    if (!minuteRateLimiter.checkLimit(userId)) {
      console.warn(`⚠️ Rate limit exceeded for user ${userId} (minute)`);
      return errorResponse(
        "Rate limit exceeded: maximum 10 errors per minute",
        429
      );
    }

    if (!hourRateLimiter.checkLimit(userId)) {
      console.warn(`⚠️ Rate limit exceeded for user ${userId} (hour)`);
      return errorResponse(
        "Rate limit exceeded: maximum 100 errors per hour",
        429
      );
    }

    // Sanitize context data
    const sanitizedContext = sanitizeData(requestData.context);

    // Generate error ID for tracking
    const errorId = crypto.randomUUID();

    // Send to Sentry
    const sentToSentry = await sendToSentry(requestData);

    // Structured logging
    console.log(
      JSON.stringify({
        event: "error_report",
        error_id: errorId,
        user_id: userId,
        sent_to_sentry: sentToSentry,
        timestamp: Date.now(),
        circuit_breaker_state: sentryCircuitBreaker.getState(),
      })
    );

    return jsonResponse({
      success: true,
      error_id: errorId,
      sent_to_sentry: sentToSentry,
      message: sentToSentry
        ? "Error report sent to Sentry"
        : "Error report received but not sent to Sentry (circuit breaker or API error)",
    });
  } catch (error) {
    // Prevent infinite loops - never call this function recursively
    console.error("🔴 Internal error in sentry-error-report:", error);
    return errorResponse(
      error instanceof Error ? error.message : "Unknown error",
      500
    );
  }
}

// Serve the function
Deno.serve(handler);

// Export for testing
export default handler;
