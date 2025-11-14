// Supabase Edge Function: sync-user-data
// Bidirectional data synchronization with conflict resolution

import { createClient } from "supabase";
import { validateJWT } from "../_shared/auth.ts";
import { RateLimiter } from "../_shared/rateLimit.ts";
import { handleCORS } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/responses.ts";
import { resolveConflict } from "../_shared/conflictResolver.ts";
import type {
  Conflict,
  LocalChange,
  ServerChanges,
  SyncError,
  SyncRequest,
  SyncResult,
  SyncTable,
} from "../_shared/syncTypes.ts";

// Rate limiter: 100 requests per minute (60,000ms) per user
const rateLimiter = new RateLimiter(100, 60000);

/**
 * Main handler for sync-user-data Edge Function
 * Handles bidirectional data synchronization with conflict resolution
 */
export async function handler(req: Request): Promise<Response> {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return handleCORS();
  }

  // Validate HTTP method
  if (req.method !== "POST") {
    return errorResponse("Method not allowed. Use POST.", 405);
  }

  try {
    // 1. Validate JWT and extract user ID
    const authResult = await validateJWT(req);
    if (!authResult.success) {
      return errorResponse(authResult.error!, 401);
    }

    const userId = authResult.userId!;

    // 2. Check rate limit
    if (!rateLimiter.checkLimit(userId)) {
      const remaining = rateLimiter.getRemainingRequests(userId);
      return errorResponse(
        `Rate limit exceeded. ${remaining} requests remaining. Try again later.`,
        429,
      );
    }

    // 3. Parse and validate request body
    let body: SyncRequest;
    try {
      body = await req.json();
    } catch (_error) {
      return errorResponse("Invalid JSON in request body", 400);
    }

    // Validate changes array exists and is an array
    if (!body.changes) {
      return errorResponse("Missing required field: changes", 400);
    }

    if (!Array.isArray(body.changes)) {
      return errorResponse("Field 'changes' must be an array", 400);
    }

    // 4. Validate batch size
    if (body.changes.length > 100) {
      return errorResponse(
        `Batch size exceeds maximum of 100 records. Received: ${body.changes.length}`,
        400,
      );
    }

    // 5. Process sync request
    const syncResult = await processSyncRequest(
      body.changes,
      body.lastSyncTimestamp,
      userId,
    );

    return jsonResponse(syncResult);
  } catch (error) {
    console.error("[sync-user-data] Unexpected error:", error);
    return errorResponse(
      error instanceof Error ? error.message : "Internal server error",
      500,
    );
  }
}

/**
 * Processes sync request with batch processing and conflict resolution
 */
async function processSyncRequest(
  changes: LocalChange[],
  lastSyncTimestamp: string | undefined,
  userId: string,
): Promise<SyncResult> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseServiceKey) {
    console.error("[sync-user-data] Missing Supabase environment variables");
    throw new Error("Server configuration error");
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  const conflicts: Conflict[] = [];
  const errors: SyncError[] = [];

  // Process each change in the batch
  for (const change of changes) {
    try {
      // Validate user owns this data
      if (change.data.user_id && change.data.user_id !== userId) {
        errors.push({
          table: change.table,
          action: change.action,
          error: "User ID mismatch - unauthorized access",
          data: change.data,
        });
        continue;
      }

      // Ensure user_id is set if not present
      if (!change.data.user_id) {
        change.data.user_id = userId;
      }

      // Process the change
      await processChange(change, userId, supabase, conflicts, errors);
    } catch (error) {
      console.error(`[sync-user-data] Error processing change:`, error);
      errors.push({
        table: change.table,
        action: change.action,
        error: error instanceof Error ? error.message : "Unknown error",
        data: change.data,
      });
    }
  }

  // Fetch server changes since last sync
  const serverChanges = await getServerChanges(
    userId,
    lastSyncTimestamp || new Date(0).toISOString(),
    supabase,
  );

  return {
    success: errors.length === 0,
    conflicts,
    serverChanges,
    errors,
    serverTimestamp: new Date().toISOString(),
  };
}

/**
 * Processes a single change (insert/update/delete)
 */
async function processChange(
  change: LocalChange,
  userId: string,
  supabase: ReturnType<typeof createClient>,
  conflicts: Conflict[],
  errors: SyncError[],
): Promise<void> {
  const { table, action, data } = change;

  try {
    if (action === "insert") {
      // Insert new record
      const { error } = await supabase
        .from(table)
        .insert(data);

      if (error) {
        throw new Error(`Insert failed: ${error.message}`);
      }
    } else if (action === "update") {
      // Fetch current remote record for conflict resolution
      const { data: remoteData, error: fetchError } = await supabase
        .from(table)
        .select("*")
        .eq("id", data.id)
        .eq("user_id", userId)
        .single();

      if (fetchError && fetchError.code !== "PGRST116") {
        // PGRST116 = not found, which is okay for updates
        throw new Error(`Fetch failed: ${fetchError.message}`);
      }

      // Resolve conflict
      const resolution = resolveConflict(change, remoteData);

      if (resolution.shouldUpdate) {
        // Local wins - update remote
        const { error: updateError } = await supabase
          .from(table)
          .upsert(data, { onConflict: "id" });

        if (updateError) {
          throw new Error(`Update failed: ${updateError.message}`);
        }
      } else if (resolution.conflict) {
        // Remote wins - add to conflicts
        conflicts.push(resolution.conflict);
      }
    } else if (action === "delete") {
      // Delete record
      const { error } = await supabase
        .from(table)
        .delete()
        .eq("id", data.id)
        .eq("user_id", userId);

      if (error) {
        throw new Error(`Delete failed: ${error.message}`);
      }
    }
  } catch (error) {
    // Re-throw to be caught by caller
    throw error;
  }
}

/**
 * Fetches server changes since last sync timestamp
 */
async function getServerChanges(
  userId: string,
  lastSyncTimestamp: string,
  supabase: ReturnType<typeof createClient>,
): Promise<ServerChanges> {
  const tables: SyncTable[] = [
    "fasting_sessions",
    "hydration_logs",
    "user_metrics",
  ];
  const serverChanges: ServerChanges = {};

  // Fetch changes from each table in parallel
  const promises = tables.map(async (table) => {
    try {
      const { data, error } = await supabase
        .from(table)
        .select("*")
        .eq("user_id", userId)
        .gte("updated_at", lastSyncTimestamp)
        .order("updated_at", { ascending: false });

      if (error) {
        console.error(`[sync-user-data] Error fetching ${table}:`, error);
        return { table, data: [] };
      }

      return { table, data: data || [] };
    } catch (error) {
      console.error(`[sync-user-data] Exception fetching ${table}:`, error);
      return { table, data: [] };
    }
  });

  const results = await Promise.all(promises);

  // Populate serverChanges object
  for (const result of results) {
    serverChanges[result.table] = result.data;
  }

  return serverChanges;
}

Deno.serve(handler);
