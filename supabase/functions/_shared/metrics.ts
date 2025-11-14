/**
 * Metrics calculation functions
 * Contains all business logic for calculating user metrics
 */

import type { AnalyticsEvent, FastingSession, PanicMetrics } from "./types.ts";

/**
 * Calculate total hours of completed fasting sessions
 * @param sessions - Array of fasting sessions
 * @returns Total hours (rounded to 2 decimal places)
 */
export function calculateTotalHours(sessions: FastingSession[]): number {
  const totalMinutes = sessions
    .filter((session) => session.completed)
    .reduce((sum, session) => sum + (session.duration_minutes || 0), 0);

  const totalHours = totalMinutes / 60;
  return Math.round(totalHours * 100) / 100; // Round to 2 decimal places
}

/**
 * Calculate current streak of consecutive days with completed fasts
 * @param sessions - Array of fasting sessions (should be sorted desc by start_time)
 * @returns Number of consecutive days
 */
export function calculateCurrentStreak(sessions: FastingSession[]): number {
  // Filter for completed sessions only
  const completedSessions = sessions.filter((s) => s.completed);

  if (completedSessions.length === 0) {
    return 0;
  }

  // Sort by start_time descending (most recent first)
  const sortedSessions = [...completedSessions].sort(
    (a, b) => new Date(b.start_time).getTime() - new Date(a.start_time).getTime()
  );

  // Extract unique dates (YYYY-MM-DD format)
  const uniqueDates = new Set<string>();
  for (const session of sortedSessions) {
    const date = new Date(session.start_time).toISOString().split("T")[0];
    uniqueDates.add(date);
  }

  // Convert to sorted array (most recent first)
  const dateArray = Array.from(uniqueDates).sort().reverse();

  // Count consecutive days from most recent
  let streak = 1; // Start with first day
  for (let i = 1; i < dateArray.length; i++) {
    const currentDate = new Date(dateArray[i]);
    const previousDate = new Date(dateArray[i - 1]);

    // Calculate day difference
    const diffTime = previousDate.getTime() - currentDate.getTime();
    const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

    // If exactly 1 day apart, continue streak
    if (diffDays === 1) {
      streak++;
    } else {
      // Gap detected, break streak
      break;
    }
  }

  return streak;
}

/**
 * Calculate success rate percentage
 * @param sessions - Array of fasting sessions
 * @returns Percentage (0-100)
 */
export function calculateSuccessRate(sessions: FastingSession[]): number {
  if (sessions.length === 0) {
    return 0;
  }

  const completedCount = sessions.filter((s) => s.completed).length;
  const percentage = (completedCount / sessions.length) * 100;

  return Math.round(percentage); // Round to nearest integer
}

/**
 * Calculate panic button usage metrics
 * @param sessions - Array of fasting sessions
 * @param panicEvents - Array of panic_button_used analytics events
 * @returns Multi-dimensional panic metrics
 */
export function calculatePanicUsage(
  sessions: FastingSession[],
  panicEvents: AnalyticsEvent[]
): PanicMetrics {
  const totalPanicEvents = panicEvents.length;

  // If no panic events, return null/zero metrics
  if (totalPanicEvents === 0) {
    return {
      completionRateAfterPanic: null,
      usageFrequency: 0,
      averagePanicsPerSession: null,
      averageElapsedMinutesAtPanic: null,
      averageProgressPercentageAtPanic: null,
      totalPanicEvents: 0,
    };
  }

  // Create session ID to session map for quick lookup
  const sessionMap = new Map<string, FastingSession>();
  sessions.forEach((s) => sessionMap.set(String(s.id), s));

  // Find sessions that had panic button usage
  const sessionsWithPanic = new Set<string>();
  panicEvents.forEach((e) => {
    if (e.session_id) {
      sessionsWithPanic.add(e.session_id);
    }
  });

  // Calculate completion rate after panic
  let completedAfterPanic = 0;
  let totalWithPanic = 0;
  sessionsWithPanic.forEach((sessionId) => {
    const session = sessionMap.get(sessionId);
    if (session) {
      totalWithPanic++;
      if (session.completed) {
        completedAfterPanic++;
      }
    }
  });

  const completionRateAfterPanic =
    totalWithPanic > 0
      ? Math.round((completedAfterPanic / totalWithPanic) * 100)
      : null;

  // Calculate usage frequency (panic events per session)
  const usageFrequency =
    sessions.length > 0
      ? Math.round((totalPanicEvents / sessions.length) * 100) / 100
      : 0;

  // Calculate average panics per session (for sessions that had panics)
  const averagePanicsPerSession =
    sessionsWithPanic.size > 0
      ? Math.round((totalPanicEvents / sessionsWithPanic.size) * 100) / 100
      : null;

  // Calculate average elapsed time and progress at panic
  let totalElapsedMinutes = 0;
  let totalProgressPercentage = 0;
  let countWithElapsedData = 0;

  panicEvents.forEach((event) => {
    if (event.session_id && event.event_data?.elapsed_minutes) {
      const session = sessionMap.get(event.session_id);
      if (session && session.duration_minutes) {
        const elapsedMinutes = Number(event.event_data.elapsed_minutes);
        totalElapsedMinutes += elapsedMinutes;

        const progressPercentage =
          (elapsedMinutes / session.duration_minutes) * 100;
        totalProgressPercentage += progressPercentage;

        countWithElapsedData++;
      }
    }
  });

  const averageElapsedMinutesAtPanic =
    countWithElapsedData > 0
      ? Math.round(totalElapsedMinutes / countWithElapsedData)
      : null;

  const averageProgressPercentageAtPanic =
    countWithElapsedData > 0
      ? Math.round(totalProgressPercentage / countWithElapsedData)
      : null;

  return {
    completionRateAfterPanic,
    usageFrequency,
    averagePanicsPerSession,
    averageElapsedMinutesAtPanic,
    averageProgressPercentageAtPanic,
    totalPanicEvents,
  };
}
