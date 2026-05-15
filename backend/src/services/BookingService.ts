import mongoose from 'mongoose';
import { env } from '../config/env';
import { BookingStatus, IBooking } from '../models/Booking';
import { bookingRepository } from '../repositories/BookingRepository';
import { cartRepository } from '../repositories/CartRepository';
import { paymentRepository } from '../repositories/PaymentRepository';
import { serviceRepository } from '../repositories/ServiceRepository';
import {
    BadRequestError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
} from '../utils/ApiError';
import { logDebug, logError, logWarning } from '../utils/errorLogger';
import { logger } from '../utils/logger';
import { PayHereInitiatePaymentRequest, payHereService } from './PayHereService';

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
   * Uses findByUserIdRaw (no populate) so item.serviceId stays as a plain ObjectId.
   */
  async checkout(
    userId: string,
    returnUrl: string,
    notifyUrl: string,
  ): Promise<{
    booking: IBooking;
    paymentDetails: Record<string, any>;
  }> {
    // Use raw (unpopulated) cart so item.serviceId is a plain ObjectId string,
    // not a full Mongoose Service document.
    const cart = await cartRepository.findByUserIdRaw(userId);

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
      logDebug('BookingService.checkout', `Processing checkout for user ${userId}`, {
        cartItemsCount: cart.items.length,
      });

      const bookingItems = [];
      let totalAmount = 0;

      for (const item of cart.items) {
        // Validate serviceId exists and is valid
        if (!item.serviceId) {
          logError('BookingService.checkout', 'Service ID is null', {
            itemId: item._id,
            userId,
          });
          throw new BadRequestError(
            `Invalid cart item — service reference missing`,
            'INVALID_CART_ITEM',
          );
        }

        // Extract ID - serviceId is an ObjectId
        const serviceIdStr = String(item.serviceId);
        logDebug('BookingService.checkout', `Processing item with service ${serviceIdStr}`);

        // Fetch service details
        const service = await serviceRepository.findByIdRaw(serviceIdStr);
        
        if (!service) {
          logError('BookingService.checkout', `Service not found`, {
            serviceId: serviceIdStr,
            userId,
          });
          throw new BadRequestError(
            `Service not found or has been removed`,
            'SERVICE_NOT_FOUND',
          );
        }

        if (!service.isActive) {
          logWarning('BookingService.checkout', `Service is inactive`, {
            serviceId: serviceIdStr,
            serviceTitle: service.title,
            userId,
          });
          throw new BadRequestError(
            `"${service.title}" is no longer available for booking`,
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
          serviceIdStr,
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
          serviceId: serviceIdStr,
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
        customerEmail: (user.email as string) || 'customer@mentecart.local',
        customerPhone: (user.phone as string) || '0000000000',
        customerName: (user.name as string) || 'Customer',
        notifyUrl,
      };

      const paymentDetails = payHereService.initiatePayment(paymentInitReq, returnUrl);

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
    // Try to find by MongoDB _id first (for internal requests)
    let booking = await bookingRepository.findByIdAndUserId(bookingId, userId);
    
    // If not found and looks like a booking reference, try by bookingRef
    if (!booking && !mongoose.Types.ObjectId.isValid(bookingId)) {
      booking = await bookingRepository.findByRefAndUserId(bookingId, userId);
    }
    
    if (!booking) throw new NotFoundError('Booking not found');

    // In sandbox mode (PAYHERE_API_URL contains sandbox), auto-confirm pending payments
    if (
      booking.status === 'pending' &&
      booking.paymentStatus === 'pending' &&
      env.PAYHERE_API_URL.includes('sandbox')
    ) {
      logDebug('BookingService.getBookingById', 'Auto-confirming sandbox payment', {
        bookingRef: booking.bookingRef,
      });
      
      // Find the payment record
      const payment = await paymentRepository.findByBookingId(booking._id.toString());
      if (payment) {
        // Mark payment as processed and update status
        await paymentRepository.markWebhookProcessed(payment._id.toString());
        await paymentRepository.updateStatus(payment._id.toString(), 'completed');
      }

      // Confirm the booking (update status to 'confirmed' and paymentStatus to 'completed')
      booking = await bookingRepository.confirmBookingAfterPayment(booking._id.toString());
      if (!booking) throw new NotFoundError('Failed to confirm booking');

      // Clear user's cart after successful payment
      await cartRepository.clearCart(userId);

      logger.info(
        { bookingId: booking._id, bookingRef: booking.bookingRef },
        'Booking auto-confirmed in sandbox mode',
      );
    }

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
   */
  async confirmBookingAfterPayment(paymentId: string): Promise<IBooking> {
    const payment = await paymentRepository.findById(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');

    await paymentRepository.markWebhookProcessed(paymentId);
    await paymentRepository.updateStatus(paymentId, 'completed');

    const booking = await bookingRepository.confirmBookingAfterPayment(
      payment.bookingId.toString(),
    );
    if (!booking) throw new NotFoundError('Booking not found');

    await cartRepository.clearCart(payment.userId.toString());

    logger.info(
      { bookingId: booking._id, bookingRef: booking.bookingRef },
      'Booking confirmed after successful payment',
    );

    return booking;
  }

  /**
   * Handles payment failure.
   */
  async handlePaymentFailure(paymentId: string, reason?: string): Promise<IBooking> {
    const payment = await paymentRepository.findById(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');

    await paymentRepository.markWebhookProcessed(paymentId);
    await paymentRepository.updateStatus(paymentId, 'failed', {
      failureReason: reason,
    });

    const booking = await bookingRepository.findById(payment.bookingId.toString());
    if (!booking) throw new NotFoundError('Booking not found');

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
