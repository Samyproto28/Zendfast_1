/**
 * Backup Data Edge Function
 * Purpose: Automated daily backups of critical user data with compression, encryption, and retention
 *
 * Features:
 * - Service role authentication only
 * - Rate limiting (1 request per 5 minutes)
 * - Data extraction from PostgreSQL
 * - GZIP compression
 * - AES-256-GCM encryption
 * - Supabase Storage upload
 * - 30-day retention policy
 * - Failure notifications (Email + OneSignal)
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { gzip, gunzip } from "jsr:@deno-library/compress@0.5.5";

// CORS headers for cross-origin requests
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

/**
 * Rate Limiter Class
 * Prevents multiple simultaneous backup executions
 */
class BackupRateLimiter {
  private lastExecutionTime: number = 0;
  private readonly cooldownMs: number = 5 * 60 * 1000; // 5 minutes

  canExecute(): boolean {
    const now = Date.now();
    if (now - this.lastExecutionTime < this.cooldownMs) {
      return false;
    }
    this.lastExecutionTime = now;
    return true;
  }

  getRemainingCooldown(): number {
    const elapsed = Date.now() - this.lastExecutionTime;
    const remaining = this.cooldownMs - elapsed;
    return Math.max(0, Math.ceil(remaining / 1000)); // Return seconds
  }
}

// Global rate limiter instance
const rateLimiter = new BackupRateLimiter();

/**
 * Validate Service Role Authentication
 * This function should ONLY be called with service role key, not user JWT
 */
function validateServiceRole(authHeader: string | null): boolean {
  if (!authHeader) {
    return false;
  }

  const token = authHeader.replace("Bearer ", "");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!serviceRoleKey) {
    throw new Error("SUPABASE_SERVICE_ROLE_KEY not configured");
  }

  return token === serviceRoleKey;
}

/**
 * Validate Required Environment Variables
 */
function validateEnvironment(): { valid: boolean; missing?: string[] } {
  const required = [
    "SUPABASE_URL",
    "SUPABASE_SERVICE_ROLE_KEY",
    "BACKUP_ENCRYPTION_KEY",
  ];

  const missing = required.filter((key) => !Deno.env.get(key));

  if (missing.length > 0) {
    return { valid: false, missing };
  }

  return { valid: true };
}

/**
 * Main Handler Function
 */
async function handler(req: Request): Promise<Response> {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  try {
    // Validate environment variables
    const envCheck = validateEnvironment();
    if (!envCheck.valid) {
      return new Response(
        JSON.stringify({
          error: "Server configuration error",
          message: `Missing required environment variables: ${envCheck.missing?.join(", ")}`,
          details: "BACKUP_ENCRYPTION_KEY and Supabase credentials must be configured",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate service role authentication
    const authHeader = req.headers.get("Authorization");
    if (!validateServiceRole(authHeader)) {
      return new Response(
        JSON.stringify({
          error: "Unauthorized",
          message: "Valid service role key required. This endpoint is for automated backups only.",
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Check rate limiting
    if (!rateLimiter.canExecute()) {
      const remainingSeconds = rateLimiter.getRemainingCooldown();
      return new Response(
        JSON.stringify({
          error: "Rate limit exceeded",
          message: "Backup already running or recently executed. Please wait before retrying.",
          retry_after_seconds: remainingSeconds,
        }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate HTTP method
    if (req.method !== "GET" && req.method !== "POST") {
      return new Response(
        JSON.stringify({
          error: "Method not allowed",
          message: "Only GET and POST methods are supported",
        }),
        {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request body (if POST)
    let requestData: any = {};
    if (req.method === "POST") {
      try {
        requestData = await req.json();
      } catch {
        // Empty body is acceptable
        requestData = {};
      }
    }

    // Execute backup (placeholder for now - will implement in Subtask 65.2)
    const backupResult = await executeBackup(requestData);

    return new Response(
      JSON.stringify(backupResult),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );

  } catch (error) {
    console.error("Backup function error:", error);

    return new Response(
      JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error occurred",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
}

/**
 * ============================================================================
 * SUBTASK 65.2: DATA EXTRACTION, COMPRESSION & ENCRYPTION FUNCTIONS
 * ============================================================================
 */

/**
 * Generate backup filename with timestamp
 * Format: backup_YYYYMMDD_HHMMSS.json.gz.enc
 */
function generateBackupFilename(): string {
  const now = new Date();
  const year = now.getUTCFullYear();
  const month = String(now.getUTCMonth() + 1).padStart(2, "0");
  const day = String(now.getUTCDate()).padStart(2, "0");
  const hours = String(now.getUTCHours()).padStart(2, "0");
  const minutes = String(now.getUTCMinutes()).padStart(2, "0");
  const seconds = String(now.getUTCSeconds()).padStart(2, "0");

  return `backup_${year}${month}${day}_${hours}${minutes}${seconds}.json.gz.enc`;
}

/**
 * Extract backup data from PostgreSQL using backup_critical_data() function
 */
async function extractBackupData(hours: number = 24): Promise<any> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Supabase credentials not configured");
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Call the PostgreSQL function
  const { data, error } = await supabase.rpc("backup_critical_data", {
    p_hours: hours,
  });

  if (error) {
    throw new Error(`Failed to extract backup data: ${error.message}`);
  }

  // Check if result contains an error
  if (data && data.error) {
    throw new Error(`Backup function error: ${data.error_message}`);
  }

  return data;
}

/**
 * Compress data using GZIP
 */
function compressData(data: Uint8Array): Uint8Array {
  return gzip(data);
}

/**
 * Derive AES-256 encryption key from BACKUP_ENCRYPTION_KEY environment variable
 */
async function deriveEncryptionKey(): Promise<{ key: CryptoKey; salt: Uint8Array }> {
  const encryptionKey = Deno.env.get("BACKUP_ENCRYPTION_KEY");
  if (!encryptionKey) {
    throw new Error("BACKUP_ENCRYPTION_KEY environment variable not set");
  }

  const encoder = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    encoder.encode(encryptionKey),
    "PBKDF2",
    false,
    ["deriveBits", "deriveKey"]
  );

  const salt = crypto.getRandomValues(new Uint8Array(16));

  const key = await crypto.subtle.deriveKey(
    {
      name: "PBKDF2",
      salt: salt,
      iterations: 100000,
      hash: "SHA-256",
    },
    keyMaterial,
    { name: "AES-GCM", length: 256 },
    true,
    ["encrypt", "decrypt"]
  );

  return { key, salt };
}

/**
 * Encrypt data using AES-256-GCM
 * Returns encrypted data with IV and salt prepended for decryption
 */
async function encryptData(data: Uint8Array): Promise<Uint8Array> {
  const { key, salt } = await deriveEncryptionKey();
  const iv = crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV for GCM

  const encrypted = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv: iv },
    key,
    data
  );

  // Prepend salt (16 bytes) + IV (12 bytes) to encrypted data
  // This allows decryption without storing salt/IV separately
  const encryptedArray = new Uint8Array(encrypted);
  const result = new Uint8Array(salt.length + iv.length + encryptedArray.length);

  result.set(salt, 0);
  result.set(iv, salt.length);
  result.set(encryptedArray, salt.length + iv.length);

  return result;
}

/**
 * ============================================================================
 * SUBTASK 65.3: STORAGE UPLOAD, RETENTION & NOTIFICATIONS FUNCTIONS
 * ============================================================================
 */

/**
 * Upload encrypted backup to Supabase Storage
 */
async function uploadToStorage(
  filename: string,
  encryptedData: Uint8Array
): Promise<void> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Supabase credentials not configured for storage upload");
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data, error } = await supabase.storage
    .from("backups")
    .upload(filename, encryptedData, {
      contentType: "application/octet-stream",
      cacheControl: "3600",
      upsert: false, // Don't overwrite existing files
    });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  console.log(`✅ Uploaded to storage: ${filename} (${data?.path})`);
}

/**
 * Cleanup backups older than 30 days (retention policy)
 * Returns list of deleted filenames
 */
async function cleanupOldBackups(): Promise<string[]> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.warn("Supabase credentials not configured, skipping retention cleanup");
    return [];
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Calculate cutoff date (30 days ago)
  const cutoffDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  try {
    // Query storage.objects for files older than 30 days
    // Note: We query storage.objects directly for metadata, but delete via Storage API
    const { data: oldFiles, error: queryError } = await supabase
      .schema("storage")
      .from("objects")
      .select("name, created_at")
      .eq("bucket_id", "backups")
      .lt("created_at", cutoffDate.toISOString());

    if (queryError) {
      console.error("Error querying old backups:", queryError);
      return [];
    }

    if (!oldFiles || oldFiles.length === 0) {
      console.log("No old backups to delete");
      return [];
    }

    // Delete files using Storage API (NOT direct SQL delete)
    const filesToDelete = oldFiles.map((f) => f.name);

    const { data: deleteData, error: deleteError } = await supabase.storage
      .from("backups")
      .remove(filesToDelete);

    if (deleteError) {
      console.error("Error deleting old backups:", deleteError);
      // Continue anyway - partial cleanup is better than none
      return [];
    }

    console.log(`🗑️ Deleted ${filesToDelete.length} old backups (>30 days)`);
    return filesToDelete;

  } catch (error) {
    console.error("Retention cleanup error:", error);
    return []; // Don't crash on cleanup failure
  }
}

/**
 * Log backup event to system_logs table
 */
async function logBackupEvent(
  eventType: "backup_success" | "backup_failure" | "backup_started" | "retention_cleanup" | "notification_sent" | "notification_failed",
  eventData: any,
  backupSizeBytes?: number,
  errorMessage?: string
): Promise<void> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.warn("Supabase credentials not configured, skipping logging");
    return;
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    const { error } = await supabase.from("system_logs").insert({
      event_type: eventType,
      event_data: eventData,
      backup_size_bytes: backupSizeBytes,
      error_message: errorMessage,
    });

    if (error) {
      console.error("Failed to log event:", error);
    } else {
      console.log(`📝 Logged: ${eventType}`);
    }
  } catch (error) {
    console.error("Logging error:", error);
    // Don't throw - logging failures shouldn't crash backup
  }
}

/**
 * Send failure notifications to admins via Email (Resend) and OneSignal
 */
async function notifyAdminsOfFailure(error: Error): Promise<void> {
  const errorMessage = error.message;
  const timestamp = new Date().toISOString();

  console.log("📧 Sending failure notifications to admins...");

  // Notification results
  let oneSignalSuccess = false;
  let emailSuccess = false;

  // 1. Send OneSignal notification
  try {
    const oneSignalApiKey = Deno.env.get("ONESIGNAL_API_KEY");
    const oneSignalAppId = Deno.env.get("ONESIGNAL_APP_ID");

    if (oneSignalApiKey && oneSignalAppId) {
      const oneSignalResponse = await fetch(
        "https://onesignal.com/api/v1/notifications",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Basic ${oneSignalApiKey}`,
          },
          body: JSON.stringify({
            app_id: oneSignalAppId,
            // Target admin users (using tags filter)
            filters: [
              { field: "tag", key: "role", relation: "=", value: "admin" },
            ],
            headings: { en: "🔴 Backup Failed" },
            contents: {
              en: `Backup failed at ${timestamp}: ${errorMessage}`,
            },
            data: {
              type: "backup_failure",
              timestamp: timestamp,
              error: errorMessage,
            },
          }),
        }
      );

      oneSignalSuccess = oneSignalResponse.ok;

      if (oneSignalSuccess) {
        console.log("✅ OneSignal notification sent");
      } else {
        console.error("❌ OneSignal notification failed:", await oneSignalResponse.text());
      }
    } else {
      console.warn("⚠️ OneSignal credentials not configured");
    }
  } catch (error) {
    console.error("OneSignal error:", error);
  }

  // 2. Send Email notification via Resend
  try {
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const adminEmail = Deno.env.get("ADMIN_EMAIL") || "admin@zendfast.app";

    if (resendApiKey) {
      const emailResponse = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${resendApiKey}`,
        },
        body: JSON.stringify({
          from: "ZendFast Backups <backups@zendfast.app>",
          to: [adminEmail],
          subject: "🔴 Backup Failed - Immediate Action Required",
          html: `
            <h2>🔴 Backup Failure Alert</h2>
            <p><strong>Time:</strong> ${timestamp}</p>
            <p><strong>Error:</strong> ${errorMessage}</p>
            <p><strong>Action Required:</strong> Check backup logs and system_logs table immediately.</p>
            <hr>
            <p style="color: #666;">This is an automated notification from ZendFast backup system.</p>
          `,
        }),
      });

      emailSuccess = emailResponse.ok;

      if (emailSuccess) {
        console.log("✅ Email notification sent");
      } else {
        console.error("❌ Email notification failed:", await emailResponse.text());
      }
    } else {
      console.warn("⚠️ Resend API key not configured");
    }
  } catch (error) {
    console.error("Email error:", error);
  }

  // 3. Log notification results
  await logBackupEvent("notification_sent", {
    onesignal_success: oneSignalSuccess,
    email_success: emailSuccess,
    error_notified: errorMessage,
    timestamp: timestamp,
  });
}

/**
 * Execute Backup Process
 * Main orchestration function - UPDATED for Subtask 65.3
 */
async function executeBackup(requestData: any): Promise<any> {
  const startTime = Date.now();
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  try {
    // Log backup start
    await logBackupEvent("backup_started", {
      source: requestData.source || "manual",
      timestamp: new Date().toISOString(),
    });

    // Step 1: Extract data from PostgreSQL
    console.log("Step 1: Extracting backup data from PostgreSQL...");
    const backupData = await extractBackupData(requestData.hours || 24);

    // Convert to JSON string
    const jsonString = JSON.stringify(backupData);
    const originalSize = jsonString.length;

    // Step 2: Compress data
    console.log("Step 2: Compressing data with GZIP...");
    const encoder = new TextEncoder();
    const jsonBytes = encoder.encode(jsonString);
    const compressed = compressData(jsonBytes);
    const compressedSize = compressed.length;

    console.log(`Compression: ${originalSize} bytes -> ${compressedSize} bytes (${(((originalSize - compressedSize) / originalSize) * 100).toFixed(1)}% reduction)`);

    // Step 3: Encrypt compressed data
    console.log("Step 3: Encrypting data with AES-256-GCM...");
    const encrypted = await encryptData(compressed);
    const encryptedSize = encrypted.length;

    // Step 4: Generate filename
    const filename = generateBackupFilename();
    console.log(`Backup prepared: ${filename} (${encryptedSize} bytes)`);

    // Step 5: Upload to Supabase Storage (NEW in Subtask 65.3)
    console.log("Step 4: Uploading to Supabase Storage...");
    await uploadToStorage(filename, encrypted);

    // Step 6: Cleanup old backups (30-day retention) (NEW in Subtask 65.3)
    console.log("Step 5: Enforcing 30-day retention policy...");
    const deletedFiles = await cleanupOldBackups();

    // Step 7: Log successful backup (NEW in Subtask 65.3)
    await logBackupEvent(
      "backup_success",
      {
        filename: filename,
        storage_path: `backups/${filename}`,
        execution_time_ms: Date.now() - startTime,
        deleted_old_backups: deletedFiles.length,
        request_source: requestData.source || "manual",
        data_stats: {
          original_size_bytes: originalSize,
          compressed_size_bytes: compressedSize,
          encrypted_size_bytes: encryptedSize,
          compression_ratio: ((compressedSize / originalSize) * 100).toFixed(1) + "%",
          record_counts: backupData.counts,
        },
      },
      encryptedSize
    );

    // Step 8: Log retention cleanup if files were deleted (NEW in Subtask 65.3)
    if (deletedFiles.length > 0) {
      await logBackupEvent("retention_cleanup", {
        files_deleted: deletedFiles.length,
        file_names: deletedFiles,
        cutoff_days: 30,
      });
    }

    // Return success response
    return {
      status: "success",
      message: "Backup completed successfully - uploaded to storage and logged",
      filename: filename,
      storage_path: `backups/${filename}`,
      timestamp: new Date().toISOString(),
      request_source: requestData.source || "manual",
      execution_time_ms: Date.now() - startTime,
      data_stats: {
        original_size_bytes: originalSize,
        compressed_size_bytes: compressedSize,
        encrypted_size_bytes: encryptedSize,
        compression_ratio: ((compressedSize / originalSize) * 100).toFixed(1) + "%",
        record_counts: backupData.counts,
      },
      retention_cleanup: {
        old_backups_deleted: deletedFiles.length,
        filenames: deletedFiles,
      },
    };

  } catch (error) {
    console.error("❌ Backup execution error:", error);

    // Log failure (NEW in Subtask 65.3)
    await logBackupEvent(
      "backup_failure",
      {
        source: requestData.source || "manual",
        timestamp: new Date().toISOString(),
        execution_time_ms: Date.now() - startTime,
      },
      undefined,
      error instanceof Error ? error.message : "Unknown error"
    );

    // Notify admins of failure (NEW in Subtask 65.3)
    await notifyAdminsOfFailure(
      error instanceof Error ? error : new Error(String(error))
    );

    // Re-throw error for handler to return 500
    throw error;
  }
}

// Serve the function
Deno.serve(handler);

// Export handler for testing
export default handler;
