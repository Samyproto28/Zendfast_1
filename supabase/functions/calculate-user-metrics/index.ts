/**
 * calculate-user-metrics Edge Function
 * Calculates comprehensive user metrics including fasting hours, streak, success rate, and panic button effectiveness
 */

import { handleCORS } from "../_shared/cors.ts";
import { errorResponse, isValidUUID, jsonResponse } from "../_shared/responses.ts";
import type { CalculateUserMetricsRequest } from "../_shared/types.ts";

/**
 * Main handler for calculate-user-metrics Edge Function
 *
 * @param req - HTTP Request containing JSON body with userId
 * @returns Response with calculated metrics or error
 *
 * @example
 * POST /functions/v1/calculate-user-metrics
 * Body: { "userId": "550e8400-e29b-41d4-a716-446655440000" }
 */
export async function handler(req: Request): Promise<Response> {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return handleCORS();
  }

  try {
    // Parse request body
    let body: CalculateUserMetricsRequest;
    try {
      body = await req.json();
    } catch (_error) {
      return errorResponse("Invalid JSON in request body", 400);
    }

    // Validate userId parameter
    const { userId } = body;
    if (!userId || !isValidUUID(userId)) {
      return errorResponse("Invalid or missing userId", 400);
    }

    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error("[calculate-user-metrics] Missing Supabase environment variables");
      return errorResponse("Server configuration error", 500);
    }

    const { createClient } = await import("supabase");
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch fasting sessions for the user
    const { data: sessions, error: sessionsError } = await supabase
      .from("fasting_sessions")
      .select("*")
      .eq("user_id", userId)
      .order("start_time", { ascending: false });

    if (sessionsError) {
      console.error("[calculate-user-metrics] Error fetching sessions:", sessionsError);
      return errorResponse("Failed to fetch fasting sessions", 500);
    }

    // Fetch panic button events for the user
    const { data: panicEvents, error: panicError } = await supabase
      .from("analytics_events")
      .select("*")
      .eq("user_id", userId)
      .eq("event_type", "panic_button_used");

    if (panicError) {
      console.error("[calculate-user-metrics] Error fetching panic events:", panicError);
      return errorResponse("Failed to fetch panic events", 500);
    }

    // Import metrics calculation functions
    const {
      calculateTotalHours,
      calculateCurrentStreak,
      calculateSuccessRate,
      calculatePanicUsage,
    } = await import("../_shared/metrics.ts");

    // Calculate all metrics
    const totalHours = calculateTotalHours(sessions || []);
    const streakDays = calculateCurrentStreak(sessions || []);
    const successRate = calculateSuccessRate(sessions || []);
    const panicMetrics = calculatePanicUsage(sessions || [], panicEvents || []);

    // Prepare metrics for user_metrics table
    const completedSessions = (sessions || []).filter((s) => s.completed);
    const lastFastDate = sessions && sessions.length > 0 ? sessions[0].start_time : null;

    // Upsert to user_metrics table
    const { error: upsertError } = await supabase
      .from("user_metrics")
      .upsert(
        {
          user_id: userId,
          total_fasts: completedSessions.length,
          total_duration_hours: totalHours,
          streak_days: streakDays,
          last_fast_date: lastFastDate,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "user_id" }
      );

    if (upsertError) {
      console.error("[calculate-user-metrics] Error upserting metrics:", upsertError);
      // Don't fail the request, just log the error
    }

    // Return comprehensive response
    return jsonResponse({
      user_id: userId,
      total_fasts: completedSessions.length,
      total_duration_hours: totalHours,
      streak_days: streakDays,
      success_rate: successRate,
      panic_metrics: panicMetrics,
      calculated_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error("[calculate-user-metrics] Error:", error);
    return errorResponse(
      error instanceof Error ? error.message : "Internal server error",
      500
    );
  }
}

// Deno.serve entry point
Deno.serve(handler);
