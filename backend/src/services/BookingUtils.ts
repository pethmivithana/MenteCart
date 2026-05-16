import { bookingRepository } from '../repositories/BookingRepository';

/**
 * Helper to check whether a user can create more bookings on a given date.
 * Returns true if user may book, false if limit reached.
 */
export async function canUserBookMore(userId: string, date: string, limit: number): Promise<boolean> {
  const count = await bookingRepository.countBookingsOnDate(userId, date);
  return count < limit;
}

export default { canUserBookMore };
