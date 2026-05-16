/**
 * BookingStatusTransitionHelper.ts
 * 
 * Enforces valid status transitions for bookings.
 * All transitions are validated at the repository layer.
 * 
 * Allowed transitions:
 *   pending → confirmed, failed, cancelled
 *   confirmed → completed, cancelled
 *   failed → (no transitions)
 *   cancelled → (no transitions)
 *   completed → (no transitions)
 * 
 * Error codes:
 *   INVALID_STATUS_TRANSITION: Attempted an invalid transition
 * 
 * Example:
 *   const booking = await bookingRepository.updateStatus(id, 'confirmed');
 *   // Validates transition before updating and logs audit entry
 */

export const BookingStatusTransitionRules = {
  pending: ['confirmed', 'failed', 'cancelled'],
  confirmed: ['completed', 'cancelled'],
  failed: [] as const,
  cancelled: [] as const,
  completed: [] as const,
} as const;

/**
 * Check if transition is valid
 */
export function isValidTransition(from: string, to: string): boolean {
  const allowed = (BookingStatusTransitionRules as Record<string, readonly string[]>)[from] || [];
  return allowed.includes(to);
}

export default { BookingStatusTransitionRules, isValidTransition };
