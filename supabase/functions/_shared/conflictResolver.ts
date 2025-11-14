// Conflict resolution algorithm for bidirectional sync
import type {
  Conflict,
  ConflictResolution,
  LocalChange,
} from "./syncTypes.ts";

/**
 * Resolves conflicts between local and remote data using last-write-wins strategy
 * Compares timestamps and returns which data should be used
 *
 * @param localChange - The local change from the client
 * @param remoteRecord - The current remote record (null if doesn't exist)
 * @returns ConflictResolution with winner and conflict details
 */
export function resolveConflict(
  localChange: LocalChange,
  remoteRecord: Record<string, any> | null,
): ConflictResolution {
  // If no remote record exists, local always wins (new insert)
  if (!remoteRecord) {
    return {
      winner: "local",
      shouldUpdate: true,
      finalData: localChange.data,
    };
  }

  // Delete actions always win regardless of timestamp
  if (localChange.action === "delete") {
    return {
      winner: "local",
      shouldUpdate: true,
      finalData: localChange.data,
    };
  }

  // Extract timestamps for comparison
  const localTimestamp = getTimestamp(localChange.data, localChange.localTimestamp);
  const remoteTimestamp = getTimestamp(remoteRecord);

  // Compare timestamps
  const localTime = new Date(localTimestamp).getTime();
  const remoteTime = new Date(remoteTimestamp).getTime();

  // Last-write-wins: newer timestamp wins
  if (localTime > remoteTime) {
    // Local is newer - local wins
    return {
      winner: "local",
      shouldUpdate: true,
      finalData: localChange.data,
    };
  } else if (remoteTime > localTime) {
    // Remote is newer - remote wins, report conflict
    const conflict: Conflict = {
      table: localChange.table,
      localData: localChange.data,
      remoteData: remoteRecord,
      resolvedData: remoteRecord, // Remote data is the resolved version
    };

    return {
      winner: "remote",
      shouldUpdate: false,
      conflict,
    };
  } else {
    // Same timestamp - tie-breaker: prefer local (client wins)
    return {
      winner: "local",
      shouldUpdate: true,
      finalData: localChange.data,
    };
  }
}

/**
 * Extracts the most relevant timestamp from a record
 * Prefers updated_at, falls back to created_at, then timestamp field, then fallback
 *
 * @param record - The database record
 * @param fallback - Fallback timestamp if none found in record
 * @returns ISO timestamp string
 */
function getTimestamp(
  record: Record<string, any>,
  fallback?: string,
): string {
  // Priority order: updated_at > created_at > timestamp > fallback > now
  if (record.updated_at) {
    return record.updated_at;
  }

  if (record.created_at) {
    return record.created_at;
  }

  if (record.timestamp) {
    return record.timestamp;
  }

  if (fallback) {
    return fallback;
  }

  // Last resort: use current time
  return new Date().toISOString();
}

/**
 * Batch conflict resolution for multiple changes
 * Useful for processing arrays of changes efficiently
 *
 * @param changes - Array of local changes
 * @param remoteRecords - Map of record ID to remote record
 * @returns Array of conflict resolutions
 */
export function resolveConflicts(
  changes: LocalChange[],
  remoteRecords: Map<string | number, Record<string, any>>,
): ConflictResolution[] {
  return changes.map((change) => {
    const recordId = change.data.id;
    const remoteRecord = remoteRecords.get(recordId) || null;
    return resolveConflict(change, remoteRecord);
  });
}
