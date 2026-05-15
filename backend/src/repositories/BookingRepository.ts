import mongoose from 'mongoose';
import { Booking, BookingStatus, IBooking, PaymentStatus } from '../models/Booking';

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

  async updateStatus(
    id: string,
    status: BookingStatus,
    extras?: { cancelledAt?: Date; cancellationReason?: string },
  ): Promise<IBooking | null> {
    return Booking.findByIdAndUpdate(
      id,
      { $set: { status, ...extras } },
      { new: true },
    ).exec();
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

  async confirmBookingAfterPayment(id: string): Promise<IBooking | null> {
    return Booking.findByIdAndUpdate(
      id,
      { $set: { status: 'confirmed', paymentStatus: 'completed' } },
      { new: true },
    ).exec();
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
