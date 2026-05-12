import { Router } from 'express';
import {
  getCart,
  addCartItem,
  updateCartItem,
  removeCartItem,
} from '../controllers/cartController';
import { authenticate } from '../middlewares/authenticate';
import { validate } from '../middlewares/validate';
import {
  addCartItemSchema,
  updateCartItemSchema,
  cartItemIdSchema,
} from '../validators/cartValidators';

const router = Router();

// All cart routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/cart
 * @access  Private
 */
router.get('/', getCart);

/**
 * @route   POST /api/cart/items
 * @access  Private
 */
router.post('/items', validate(addCartItemSchema), addCartItem);

/**
 * @route   PATCH /api/cart/items/:itemId
 * @access  Private
 */
router.patch('/items/:itemId', validate(updateCartItemSchema), updateCartItem);

/**
 * @route   DELETE /api/cart/items/:itemId
 * @access  Private
 */
router.delete('/items/:itemId', validate(cartItemIdSchema), removeCartItem);

export default router;
