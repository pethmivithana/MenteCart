import { Router } from 'express';
import {
  checkout,
  listBookings,
  getBookingById,
  cancelBooking,
} from '../controllers/bookingController';
import { authenticate } from '../middlewares/authenticate';
import { validate } from '../middlewares/validate';
import {
  listBookingsSchema,
  bookingIdSchema,
  cancelBookingSchema,
} from '../validators/bookingValidators';

const router = Router();

// All booking routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/bookings/checkout
 * @access  Private
 */
router.post('/checkout', checkout);

/**
 * @route   GET /api/bookings
 * @access  Private
 */
router.get('/', validate(listBookingsSchema), listBookings);

/**
 * @route   GET /api/bookings/:id
 * @access  Private
 */
router.get('/:id', validate(bookingIdSchema), getBookingById);

/**
 * @route   POST /api/bookings/:id/cancel
 * @access  Private
 */
router.post('/:id/cancel', validate(cancelBookingSchema), cancelBooking);

export default router;
