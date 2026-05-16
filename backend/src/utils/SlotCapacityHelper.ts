/**
 * SlotCapacityHelper.ts
 * 
 * Utilities for slot capacity validation and management.
 * 
 * Use atomic MongoDB operations to prevent race conditions:
 * - incrementSlotBookedCount: Decrements remainingCapacity with conditional check
 * - decrementSlotBookedCount: Increments remainingCapacity on release/cancellation
 * 
 * Error codes when capacity unavailable:
 *   SLOT_CAPACITY_EXCEEDED: Requested quantity > remainingCapacity
 *   SLOT_RESERVATION_FAILED: Atomic update failed (concurrent overbooking attempt)
 *   SLOT_NOT_FOUND: Slot does not exist
 * 
 * Fields used:
 *   - capacity: total capacity for the slot
 *   - remainingCapacity: available spots (capacity - bookedCount)
 *   - bookedCount: number of booked spots (kept in sync)
 *   - startTime: slot start time (formerly 'time')
 * 
 * Example:
 *   const updated = await serviceRepository.incrementSlotBookedCount(
 *     serviceId, date, startTime, qty
 *   );
 *   if (!updated) throw new ConflictError('Selected slot is fully booked');
 */

export interface SlotWithCapacity {
  date: string;
  startTime: string;
  capacity: number;
  remainingCapacity: number;
  bookedCount?: number;
}

/**
 * Calculate remaining capacity, with fallback for legacy bookedCount format
 */
export function getRemainingCapacity(slot: SlotWithCapacity): number {
  if (slot.remainingCapacity !== undefined) return slot.remainingCapacity;
  return slot.capacity - (slot.bookedCount || 0);
}

export default { SlotWithCapacity, getRemainingCapacity };
