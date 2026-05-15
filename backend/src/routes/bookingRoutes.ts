import { Router } from 'express';
import {
  checkout,
  listBookings,
  getBookingById,
  cancelBooking,
  payherWebhook,
} from '../controllers/bookingController';
import { authenticate } from '../middlewares/authenticate';
import { validate } from '../middlewares/validate';
import {
  checkoutSchema,
  listBookingsSchema,
  bookingIdSchema,
  cancelBookingSchema,
} from '../validators/bookingValidators';

const router = Router();

/**
 * @route   POST /api/bookings/webhook/payhere
 * @access  Public (signature verification required)
 */
router.post('/webhook/payhere', payherWebhook);

// All booking routes below require authentication
router.use(authenticate);

/**
 * @route   POST /api/bookings/checkout
 * @access  Private
 */
router.post('/checkout', validate(checkoutSchema), checkout);

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
