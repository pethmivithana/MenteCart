 /**
 * SlotCapacityHelper.ts
 *
 * Utilities for slot capacity validation and management.
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

/**
 * Optional helper: check if slot can accept booking
 */
export function canBookSlot(slot: SlotWithCapacity, qty: number = 1): boolean {
  return getRemainingCapacity(slot) >= qty;
}

/**
 * Optional helper: throw-safe validation
 */
export function assertSlotAvailable(slot: SlotWithCapacity, qty: number = 1): void {
  if (!canBookSlot(slot, qty)) {
    throw new Error('SLOT_CAPACITY_EXCEEDED');
  }
}