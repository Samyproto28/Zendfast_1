/**
 * TypeScript type definitions for Supabase database tables
 * Matches the schema defined in migrations
 */

export interface FastingSession {
  id: number;
  user_id: string;
  start_time: string; // ISO 8601 timestamp
  end_time: string | null;
  duration_minutes: number | null;
  completed: boolean;
  interrupted: boolean;
  plan_type: string;
  interruption_reason: string | null;
  created_at: string;
  updated_at: string;
  sync_version: number | null;
}

export interface HydrationLog {
  id: number;
  user_id: string;
  amount_ml: number;
  timestamp: string; // ISO 8601 timestamp
  created_at: string;
}

export interface UserMetrics {
  id: string; // UUID
  user_id: string;
  total_fasts: number;
  total_duration_hours: number;
  streak_days: number;
  longest_streak: number;
  last_fast_date: string | null;
  created_at: string;
  updated_at: string;
  sync_version: number;
}

export interface AnalyticsEvent {
  event_id: string; // UUID
  user_id: string;
  event_type: string;
  event_data: Record<string, unknown>;
  timestamp: string; // ISO 8601 timestamp
  session_id: string | null;
  updated_at: string;
}

export interface PanicMetrics {
  completionRateAfterPanic: number | null;
  usageFrequency: number;
  averagePanicsPerSession: number | null;
  averageElapsedMinutesAtPanic: number | null;
  averageProgressPercentageAtPanic: number | null;
  totalPanicEvents: number;
}

export interface CalculateUserMetricsRequest {
  userId: string;
}

export interface CalculateUserMetricsResponse {
  user_id: string;
  total_fasts: number;
  total_duration_hours: number;
  streak_days: number;
  success_rate: number;
  panic_metrics: PanicMetrics;
  calculated_at: string;
}

export interface ErrorResponse {
  error: string;
  details?: string;
}
