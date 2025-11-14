// Rate limiting utilities for Edge Functions

/**
 * In-memory rate limiter using sliding window algorithm
 * Tracks request timestamps per user and enforces limits
 */
export class RateLimiter {
  private requests: Map<string, number[]> = new Map();

  /**
   * Creates a new rate limiter
   * @param maxRequests - Maximum number of requests allowed in the time window
   * @param windowMs - Time window in milliseconds
   */
  constructor(
    private maxRequests: number,
    private windowMs: number,
  ) {}

  /**
   * Checks if a user is within their rate limit
   * @param userId - Unique identifier for the user
   * @returns true if request is allowed, false if rate limit exceeded
   */
  checkLimit(userId: string): boolean {
    const now = Date.now();
    const userRequests = this.requests.get(userId) || [];

    // Remove requests outside the current time window
    const validRequests = userRequests.filter(
      (timestamp) => now - timestamp < this.windowMs,
    );

    // Check if user has exceeded the limit
    if (validRequests.length >= this.maxRequests) {
      // Update the map even though we're rejecting (cleanup old entries)
      this.requests.set(userId, validRequests);
      return false;
    }

    // Add current request timestamp
    validRequests.push(now);
    this.requests.set(userId, validRequests);

    // Periodic cleanup of users with no recent requests
    this.cleanup(now);

    return true;
  }

  /**
   * Gets the number of users currently being tracked
   * Useful for testing and monitoring
   */
  getUserCount(): number {
    return this.requests.size;
  }

  /**
   * Cleans up users with no requests in the current window
   * This prevents memory leaks in long-running Edge Functions
   */
  private cleanup(now: number): void {
    // Only run cleanup occasionally (every 100th call to avoid overhead)
    if (Math.random() > 0.01) return;

    for (const [userId, timestamps] of this.requests.entries()) {
      // Remove users with no timestamps or all timestamps outside window
      const validTimestamps = timestamps.filter(
        (ts) => now - ts < this.windowMs,
      );

      if (validTimestamps.length === 0) {
        this.requests.delete(userId);
      }
    }
  }

  /**
   * Resets all rate limit data
   * Useful for testing
   */
  reset(): void {
    this.requests.clear();
  }

  /**
   * Gets remaining requests for a user (for informational purposes)
   * @param userId - User identifier
   * @returns Number of requests remaining in current window
   */
  getRemainingRequests(userId: string): number {
    const now = Date.now();
    const userRequests = this.requests.get(userId) || [];

    const validRequests = userRequests.filter(
      (timestamp) => now - timestamp < this.windowMs,
    );

    return Math.max(0, this.maxRequests - validRequests.length);
  }
}
