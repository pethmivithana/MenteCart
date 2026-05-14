import mongoose from 'mongoose';
import { env } from '../config/env';
import { BookingStatus, IBooking } from '../models/Booking';
import { bookingRepository } from '../repositories/BookingRepository';
import { cartRepository } from '../repositories/CartRepository';
import { serviceRepository } from '../repositories/ServiceRepository';
import { paymentRepository } from '../repositories/PaymentRepository';
import {
  BadRequestError,
  ConflictError,
  ForbiddenError,
  NotFoundError,
} from '../utils/ApiError';
import { logger } from '../utils/logger';
import { payHereService, PayHereInitiatePaymentRequest } from './PayHereService';

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
   * Initiates checkout with payment pending status.
   * Steps:
   *  1. Validate cart is not empty
   *  2. Enforce per-day booking limits
   *  3. Atomically reserve each slot (fails if capacity exceeded)
   *  4. Create booking record with status='pending', paymentStatus='pending'
   *  5. Create payment record
   *  6. Return booking with PayHere payment details
   *
   * Booking is NOT confirmed until payment webhook succeeds.
   * If slot reservation fails partway through, already-reserved slots are released.
   */
  async checkout(
    userId: string,
    returnUrl: string,
    notifyUrl: string,
  ): Promise<{
    booking: IBooking;
    paymentDetails: Record<string, any>;
  }> {
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
          _id: new mongoose.Types.ObjectId(),
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

      // Create booking with PENDING status (not confirmed yet)
      const booking = await bookingRepository.create({
        bookingRef,
        userId: new mongoose.Types.ObjectId(userId),
        items: bookingItems,
        totalAmount,
        status: 'pending',
        paymentStatus: 'pending',
      });

      // Create payment record
      const payment = await paymentRepository.create({
        bookingId: booking._id,
        bookingRef: booking.bookingRef,
        userId: new mongoose.Types.ObjectId(userId),
        amount: totalAmount,
        currency: 'LKR',
        method: 'payhere',
        status: 'pending',
      });

      // Get user details for PayHere
      const user = await mongoose.connection.collection('users').findOne({
        _id: new mongoose.Types.ObjectId(userId),
      });

      if (!user) {
        throw new NotFoundError('User not found');
      }

      // Initiate PayHere payment
      const paymentInitReq: PayHereInitiatePaymentRequest = {
        bookingRef: booking.bookingRef,
        amount: totalAmount,
        currency: 'LKR',
        customerEmail: user.email || 'customer@mentecart.local',
        customerPhone: user.phone || '0000000000',
        customerName: user.name || 'Customer',
        notifyUrl,
      };

      const paymentDetails = payHereService.initiatePayment(paymentInitReq, returnUrl);

      // DO NOT clear cart yet - only clear after successful payment webhook
      // await cartRepository.clearCart(userId);

      return {
        booking,
        paymentDetails,
      };
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

  /**
   * Confirms booking after successful payment webhook.
   * Steps:
   *  1. Find payment record
   *  2. Update payment status to 'completed'
   *  3. Confirm booking (pending → confirmed)
   *  4. Clear the cart
   * Idempotent: Webhook may be retried, so check if already processed.
   */
  async confirmBookingAfterPayment(paymentId: string): Promise<IBooking> {
    const payment = await paymentRepository.findById(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');

    // Mark webhook as processed (prevent duplicate processing)
    await paymentRepository.markWebhookProcessed(paymentId);

    // Update payment status
    await paymentRepository.updateStatus(paymentId, 'completed');

    // Confirm the booking
    const booking = await bookingRepository.confirmBookingAfterPayment(
      payment.bookingId.toString(),
    );
    if (!booking) throw new NotFoundError('Booking not found');

    // Clear the cart after successful payment
    await cartRepository.clearCart(payment.userId.toString());

    logger.info(
      { bookingId: booking._id, bookingRef: booking.bookingRef },
      'Booking confirmed after successful payment',
    );

    return booking;
  }

  /**
   * Handles payment failure.
   * Steps:
   *  1. Update payment status to 'failed'
   *  2. Update booking status to 'failed'
   *  3. Release reserved slots
   */
  async handlePaymentFailure(paymentId: string, reason?: string): Promise<IBooking> {
    const payment = await paymentRepository.findById(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');

    // Mark webhook as processed
    await paymentRepository.markWebhookProcessed(paymentId);

    // Update payment status
    await paymentRepository.updateStatus(paymentId, 'failed', {
      failureReason: reason,
    });

    // Get the booking
    const booking = await bookingRepository.findById(payment.bookingId.toString());
    if (!booking) throw new NotFoundError('Booking not found');

    // Release all reserved slots
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

    // Update booking status to failed
    const updated = await bookingRepository.updateStatus(booking._id.toString(), 'failed', {
      cancellationReason: `Payment failed: ${reason || 'Unknown reason'}`,
    });

    logger.warn(
      { bookingId: booking._id, reason },
      'Payment failed - booking cancelled and slots released',
    );

    return updated!;
  }
}

export const bookingService = new BookingService();
