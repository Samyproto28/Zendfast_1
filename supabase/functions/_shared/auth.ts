// JWT authentication utilities for Edge Functions
import { createClient } from "supabase";
import type { AuthResult } from "./syncTypes.ts";

/**
 * Validates JWT token from Authorization header and extracts user ID
 * @param req - HTTP Request with Authorization header
 * @returns AuthResult with success status and userId or error
 */
export async function validateJWT(req: Request): Promise<AuthResult> {
  // Check for Authorization header
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return {
      success: false,
      error: "Missing Authorization header",
    };
  }

  // Extract Bearer token
  if (!authHeader.startsWith("Bearer ")) {
    return {
      success: false,
      error: "Invalid Authorization header format. Expected 'Bearer <token>'",
    };
  }

  const token = authHeader.replace("Bearer ", "").trim();
  if (!token) {
    return {
      success: false,
      error: "Empty JWT token",
    };
  }

  // Check environment variables
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error("[auth] Missing SUPABASE_URL or SUPABASE_ANON_KEY");
    return {
      success: false,
      error: "Server configuration error",
    };
  }

  // Create Supabase client and validate token
  try {
    const supabase = createClient(supabaseUrl, supabaseAnonKey);

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser(token);

    if (error) {
      console.error("[auth] JWT validation error:", error.message);
      return {
        success: false,
        error: `Invalid JWT: ${error.message}`,
      };
    }

    if (!user) {
      return {
        success: false,
        error: "Invalid JWT: No user found",
      };
    }

    return {
      success: true,
      userId: user.id,
    };
  } catch (error) {
    console.error("[auth] Unexpected error during JWT validation:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : "Authentication failed",
    };
  }
}
