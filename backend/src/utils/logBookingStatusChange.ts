import { BookingAuditLog } from '../models/BookingAuditLog';

export async function logBookingStatusChange(
  bookingId: string,
  previousStatus: string,
  newStatus: string,
  changedBy?: string,
  reason?: string,
) {
  try {
    await BookingAuditLog.create({
      bookingId,
      previousStatus,
      newStatus,
      changedBy: changedBy || 'system',
      reason,
    });
  } catch (err) {
    // Non-fatal; ensure failures don't block main flow
    // eslint-disable-next-line no-console
    console.warn('Failed to write booking audit log', err);
  }
}

export default { logBookingStatusChange };
