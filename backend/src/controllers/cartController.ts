import { Response, NextFunction } from 'express';
import { cartService } from '../services/CartService';
import { asyncHandler } from '../utils/asyncHandler';
import { ApiResponse } from '../utils/ApiResponse';
import { AuthRequest } from '../types';

/**
 * GET /api/cart  [protected]
 */
export const getCart = asyncHandler(async (req: AuthRequest, res: Response) => {
  const cart = await cartService.getCart(req.user!.userId);
  ApiResponse.success(res, { cart }, 'Cart fetched successfully');
});

/**
 * POST /api/cart/items  [protected]
 */
export const addCartItem = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { serviceId, slotDate, slotTime, quantity } = req.body as {
    serviceId: string;
    slotDate: string;
    slotTime: string;
    quantity: number;
  };
  const cart = await cartService.addItem(req.user!.userId, {
    serviceId,
    slotDate,
    slotTime,
    quantity,
  });
  ApiResponse.created(res, { cart }, 'Item added to cart');
});

/**
 * PATCH /api/cart/items/:itemId  [protected]
 */
export const updateCartItem = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { itemId } = req.params;
  const cart = await cartService.updateItem(req.user!.userId, itemId, req.body);
  ApiResponse.success(res, { cart }, 'Cart item updated');
});

/**
 * DELETE /api/cart/items/:itemId  [protected]
 */
export const removeCartItem = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { itemId } = req.params;
  const cart = await cartService.removeItem(req.user!.userId, itemId);
  ApiResponse.success(res, { cart }, 'Item removed from cart');
});
