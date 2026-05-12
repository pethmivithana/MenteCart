import mongoose from 'mongoose';
import { bookingRepository } from '../repositories/BookingRepository';
import { cartRepository } from '../repositories/CartRepository';
import { serviceRepository } from '../repositories/ServiceRepository';
import { IBooking, BookingStatus } from '../models/Booking';
import {
  BadRequestError,
  NotFoundError,
  ForbiddenError,
  ConflictError,
} from '../utils/ApiError';
import { env } from '../config/env';
import { logger } from '../utils/logger';

export interface BookingFilters {
  status?: BookingStatus;
  page?: number;
  limit?: number;
}

/**
 * Core booking business logic.
 * Uses atomic MongoDB operations to prevent overbooking under concurrent load.
 */
export class BookingService {
  /**
   * Convert the user's cart into confirmed bookings.
   * Steps:
   *  1. Validate cart is not empty
   *  2. Enforce per-day booking limits
   *  3. Atomically reserve each slot (fails if capacity exceeded)
   *  4. Create booking record
   *  5. Clear the cart
   *
   * If slot reservation fails partway through, already-reserved slots are released.
   */
  async checkout(userId: string): Promise<IBooking> {
    const cart = await cartRepository.findByUserId(userId);

    if (!cart || cart.items.length === 0) {
      throw new BadRequestError('Your cart is empty', 'CART_EMPTY');
    }

    // Check cart expiry
    if (cart.expiresAt < new Date()) {
      throw new BadRequestError('Your cart has expired. Please add items again.', 'CART_EXPIRED');
    }

    // Enforce booking limit per day
    const today = new Date().toISOString().split('T')[0];
    const todayCount = await bookingRepository.countBookingsOnDate(userId, today);
    if (todayCount >= env.MAX_BOOKINGS_PER_DAY) {
      throw new ConflictError(
        `You have reached the maximum of ${env.MAX_BOOKINGS_PER_DAY} bookings for today`,
        'BOOKING_LIMIT_REACHED',
      );
    }

    // Build booking items and reserve slots atomically
    const reservedSlots: Array<{ serviceId: string; date: string; time: string; qty: number }> = [];

    try {
      const bookingItems = [];
      let totalAmount = 0;

      for (const item of cart.items) {
        const service = await serviceRepository.findByIdRaw(item.serviceId.toString());
        if (!service || !service.isActive) {
          throw new BadRequestError(
            `Service "${item.serviceId}" is no longer available`,
            'SERVICE_UNAVAILABLE',
          );
        }

        // Verify the slot still has capacity
        const slot = service.availableSlots.find(
          (s) => s.date === item.slotDate && s.time === item.slotTime,
        );
        if (!slot) {
          throw new BadRequestError(
            `Slot ${item.slotDate} ${item.slotTime} for "${service.title}" no longer exists`,
            'SLOT_NOT_FOUND',
          );
        }

        const remaining = slot.capacity - slot.bookedCount;
        if (item.quantity > remaining) {
          throw new ConflictError(
            `Only ${remaining} spot(s) left for "${service.title}" on ${item.slotDate} at ${item.slotTime}`,
            'SLOT_CAPACITY_EXCEEDED',
          );
        }

        // Atomically reserve the slot
        const updated = await serviceRepository.incrementSlotBookedCount(
          item.serviceId.toString(),
          item.slotDate,
          item.slotTime,
          item.quantity,
        );

        if (!updated) {
          throw new ConflictError(
            `Failed to reserve slot for "${service.title}" — it may have just filled up`,
            'SLOT_RESERVATION_FAILED',
          );
        }

        reservedSlots.push({
          serviceId: item.serviceId.toString(),
          date: item.slotDate,
          time: item.slotTime,
          qty: item.quantity,
        });

        const subtotal = item.priceAtAdd * item.quantity;
        totalAmount += subtotal;

        bookingItems.push({
          serviceId: item.serviceId,
          serviceTitle: service.title,
          serviceImage: service.image,
          slotDate: item.slotDate,
          slotTime: item.slotTime,
          quantity: item.quantity,
          pricePerUnit: item.priceAtAdd,
          subtotal,
        });
      }

      const bookingRef = await bookingRepository.generateBookingRef();

      const booking = await bookingRepository.create({
        bookingRef,
        userId: new mongoose.Types.ObjectId(userId),
        items: bookingItems,
        totalAmount,
        status: 'confirmed',
      });

      // Clear the cart after successful booking
      await cartRepository.clearCart(userId);

      return booking;
    } catch (error) {
      // Release all already-reserved slots to prevent phantom bookings
      logger.warn({ reservedSlots }, 'Checkout failed — releasing reserved slots');
      await Promise.all(
        reservedSlots.map((s) =>
          serviceRepository.decrementSlotBookedCount(s.serviceId, s.date, s.time, s.qty),
        ),
      );
      throw error;
    }
  }

  async listBookings(
    userId: string,
    filters: BookingFilters,
  ): Promise<ReturnType<typeof bookingRepository.findMany>> {
    const page = Math.max(1, filters.page ?? 1);
    const limit = Math.min(50, Math.max(1, filters.limit ?? 10));
    return bookingRepository.findMany({ userId, status: filters.status, page, limit });
  }

  async getBookingById(userId: string, bookingId: string): Promise<IBooking> {
    const booking = await bookingRepository.findByIdAndUserId(bookingId, userId);
    if (!booking) throw new NotFoundError('Booking not found');
    return booking;
  }

  async cancelBooking(userId: string, bookingId: string, reason?: string): Promise<IBooking> {
    const booking = await bookingRepository.findByIdAndUserId(bookingId, userId);
    if (!booking) throw new NotFoundError('Booking not found');

    if (!['pending', 'confirmed'].includes(booking.status)) {
      throw new ForbiddenError(`Cannot cancel a booking that is "${booking.status}"`);
    }

    // Release slot capacity back
    await Promise.all(
      booking.items.map((item) =>
        serviceRepository.decrementSlotBookedCount(
          item.serviceId.toString(),
          item.slotDate,
          item.slotTime,
          item.quantity,
        ),
      ),
    );

    const updated = await bookingRepository.updateStatus(bookingId, 'cancelled', {
      cancelledAt: new Date(),
      cancellationReason: reason ?? 'Cancelled by user',
    });

    return updated!;
  }
}

export const bookingService = new BookingService();
