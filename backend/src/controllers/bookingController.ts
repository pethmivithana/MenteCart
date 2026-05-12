import { Response } from 'express';
import { bookingService } from '../services/BookingService';
import { asyncHandler } from '../utils/asyncHandler';
import { ApiResponse } from '../utils/ApiResponse';
import { AuthRequest } from '../types';
import { BookingStatus } from '../models/Booking';

/**
 * POST /api/bookings/checkout  [protected]
 * Converts the authenticated user's cart into a confirmed booking.
 */
export const checkout = asyncHandler(async (req: AuthRequest, res: Response) => {
  const booking = await bookingService.checkout(req.user!.userId);
  ApiResponse.created(res, { booking }, 'Booking confirmed successfully');
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
