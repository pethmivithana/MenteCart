import mongoose from 'mongoose';
import { Booking, BookingStatus, IBooking, PaymentStatus } from '../models/Booking';
import { ConflictError } from '../utils/ApiError';

export interface BookingFilters {
  userId: string;
  status?: BookingStatus;
  page: number;
  limit: number;
}

/**
 * Data access layer for Booking collection.
 */
export class BookingRepository {
  async create(data: Partial<IBooking>): Promise<IBooking> {
    return Booking.create(data);
  }

  async findMany(filters: BookingFilters): Promise<{
    bookings: IBooking[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const { userId, status, page, limit } = filters;
    const query: mongoose.FilterQuery<IBooking> = { userId };
    if (status) query.status = status;

    const skip = (page - 1) * limit;
    const [bookings, total] = await Promise.all([
      Booking.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit).exec(),
      Booking.countDocuments(query),
    ]);

    return { bookings, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findById(id: string): Promise<IBooking | null> {
    if (!mongoose.Types.ObjectId.isValid(id)) return null;
    return Booking.findById(id).exec();
  }

  async findByIdAndUserId(id: string, userId: string): Promise<IBooking | null> {
    if (!mongoose.Types.ObjectId.isValid(id)) return null;
    return Booking.findOne({ _id: id, userId }).exec();
  }

  async findByRefAndUserId(bookingRef: string, userId: string): Promise<IBooking | null> {
    return Booking.findOne({ bookingRef, userId }).exec();
  }

  async updateStatus(
    id: string,
    status: BookingStatus,
    extras?: { cancelledAt?: Date; cancellationReason?: string },
    changedBy?: string,
  ): Promise<IBooking | null> {
    // Validate allowed transitions
    const allowed: Record<string, string[]> = {
      pending: ['confirmed', 'failed', 'cancelled'],
      confirmed: ['completed', 'cancelled'],
      failed: [],
      cancelled: [],
      completed: [],
    };

    const booking = await Booking.findById(id).exec();
    if (!booking) return null;
    const prev = booking.status;
    if (prev === status) return booking;
    const allowedNext = allowed[prev] || [];
    if (!allowedNext.includes(status)) {
      throw new ConflictError(`Invalid status transition from ${prev} to ${status}`, 'INVALID_STATUS_TRANSITION');
    }

    const updated = await Booking.findByIdAndUpdate(
      id,
      { $set: { status, ...extras } },
      { new: true },
    ).exec();

    // Write audit log via helper (non-fatal)
    try {
      const { logBookingStatusChange } = await import('../utils/logBookingStatusChange');
      await logBookingStatusChange(booking._id.toString(), prev, status, changedBy, extras?.cancellationReason);
    } catch (err) {
      // Non-fatal - continue
      // eslint-disable-next-line no-console
      console.warn('Failed to invoke audit log helper', err);
    }

    return updated;
  }

  async updatePaymentStatus(
    id: string,
    paymentStatus: PaymentStatus,
    paymentId?: string,
  ): Promise<IBooking | null> {
    const updates: Record<string, any> = { paymentStatus };
    if (paymentId) updates.paymentId = paymentId;
    return Booking.findByIdAndUpdate(id, { $set: updates }, { new: true }).exec();
  }

  async confirmBookingAfterPayment(id: string, changedBy?: string): Promise<IBooking | null> {
    // Reuse updateStatus to ensure transitions and audit logging
    const updated = await this.updateStatus(id, 'confirmed', undefined, changedBy);
    if (!updated) return null;
    // Also mark paymentStatus
    return Booking.findByIdAndUpdate(id, { $set: { paymentStatus: 'completed' } }, { new: true }).exec();
  }

  /**
   * Count bookings created by the user on a specific date (booking limit enforcement).
   */
  async countBookingsOnDate(userId: string, date: string): Promise<number> {
    const startOfDay = new Date(`${date}T00:00:00.000Z`);
    const endOfDay = new Date(`${date}T23:59:59.999Z`);
    return Booking.countDocuments({
      userId,
      status: { $nin: ['cancelled', 'failed'] },
      createdAt: { $gte: startOfDay, $lte: endOfDay },
    });
  }

  async generateBookingRef(): Promise<string> {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `MC-${timestamp}-${random}`;
  }
}

export const bookingRepository = new BookingRepository();
