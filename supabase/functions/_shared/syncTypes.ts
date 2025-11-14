// Type definitions for sync operations

export type SyncAction = "insert" | "update" | "delete";

export type SyncTable = "fasting_sessions" | "hydration_logs" | "user_metrics";

export interface LocalChange {
  table: SyncTable;
  action: SyncAction;
  data: Record<string, any>;
  localTimestamp: string;
}

export interface Conflict {
  table: SyncTable;
  localData: Record<string, any>;
  remoteData: Record<string, any>;
  resolvedData?: Record<string, any>;
}

export interface SyncError {
  table: SyncTable;
  action: SyncAction;
  error: string;
  data?: Record<string, any>;
}

export interface SyncResult {
  success: boolean;
  conflicts: Conflict[];
  serverChanges: ServerChanges;
  errors: SyncError[];
  serverTimestamp: string;
}

export interface ServerChanges {
  fasting_sessions?: any[];
  hydration_logs?: any[];
  user_metrics?: any[];
}

export interface SyncRequest {
  changes: LocalChange[];
  lastSyncTimestamp?: string;
}

export interface ConflictResolution {
  winner: "local" | "remote";
  shouldUpdate: boolean;
  finalData?: Record<string, any>;
  conflict?: Conflict;
}

export interface AuthResult {
  success: boolean;
  userId?: string;
  error?: string;
}
