import { Response } from 'express';
import { bookingService } from '../services/BookingService';
import { paymentRepository } from '../repositories/PaymentRepository';
import { payHereService } from '../services/PayHereService';
import { asyncHandler } from '../utils/asyncHandler';
import { ApiResponse } from '../utils/ApiResponse';
import { BadRequestError, UnauthorizedError } from '../utils/ApiError';
import { AuthRequest } from '../types';
import { BookingStatus } from '../models/Booking';

/**
 * POST /api/bookings/checkout  [protected]
 * Initiates booking with payment pending status.
 * Returns booking and PayHere payment details for frontend.
 */
export const checkout: any = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { returnUrl, notifyUrl } = req.body;
  
  if (!returnUrl || !notifyUrl) {
    throw new BadRequestError('returnUrl and notifyUrl are required');
  }

  const { booking, paymentDetails } = await bookingService.checkout(
    req.user!.userId,
    returnUrl,
    notifyUrl,
  );

  ApiResponse.created(
    res,
    { booking, paymentDetails },
    'Booking initiated - proceed to payment',
  );
});

/**
 * GET /api/bookings  [protected]
 * Supports: ?page, ?limit, ?status
 */
export const listBookings = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { page, limit, status } = req.query as Record<string, string>;

  const result = await bookingService.listBookings(req.user!.userId, {
    page: page ? parseInt(page) : 1,
    limit: limit ? parseInt(limit) : 10,
    status: status as BookingStatus | undefined,
  });

  ApiResponse.paginated(
    res,
    result.bookings,
    {
      total: result.total,
      page: result.page,
      limit: result.limit,
      totalPages: result.totalPages,
    },
    'Bookings fetched successfully',
  );
});

/**
 * GET /api/bookings/:id  [protected]
 */
export const getBookingById = asyncHandler(async (req: AuthRequest, res: Response) => {
  const booking = await bookingService.getBookingById(req.user!.userId, req.params.id);
  ApiResponse.success(res, { booking }, 'Booking fetched successfully');
});

/**
 * POST /api/bookings/:id/cancel  [protected]
 */
export const cancelBooking = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { reason } = req.body as { reason?: string };
  const booking = await bookingService.cancelBooking(req.user!.userId, req.params.id, reason);
  ApiResponse.success(res, { booking }, 'Booking cancelled successfully');
});

/**
 * POST /api/bookings/webhook/payhere  [public]
 * Handles PayHere payment notifications.
 * Signature verification prevents unauthorized updates.
 */
export const payherWebhook: any = asyncHandler(async (req: AuthRequest, res: Response) => {
  const authHeader = req.headers.authorization as string;
  const body = req.body as Record<string, any>;
  
  // Verify webhook signature
  const isValid = payHereService.verifyWebhookSignature(
    JSON.stringify(body),
    authHeader,
  );

  if (!isValid) {
    throw new UnauthorizedError('Invalid webhook signature');
  }

  // Parse webhook payload
  const payload = payHereService.parseWebhookPayload(body);

  // Find payment by order ID (bookingRef)
  const payment = await paymentRepository.findByBookingRef(payload.orderId);
  if (!payment) {
    throw new BadRequestError('Payment not found');
  }

  // Idempotent processing - check if already handled
  if (payment.webhookProcessed) {
    return ApiResponse.success(res, {}, 'Webhook already processed');
  }

  // Handle success vs failure
  if (payHereService.isPaymentSuccessful(payload.paymentStatus)) {
    const booking = await bookingService.confirmBookingAfterPayment(payment._id.toString());
    ApiResponse.success(res, { booking }, 'Payment successful - booking confirmed');
  } else {
    const booking = await bookingService.handlePaymentFailure(
      payment._id.toString(),
      payload.statusMessage || 'Payment declined',
    );
    ApiResponse.success(res, { booking }, 'Payment failed - booking cancelled');
  }
});
