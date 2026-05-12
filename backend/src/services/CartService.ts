import mongoose from 'mongoose';
import { cartRepository } from '../repositories/CartRepository';
import { serviceRepository } from '../repositories/ServiceRepository';
import { ICart } from '../models/Cart';
import { BadRequestError, NotFoundError } from '../utils/ApiError';

export interface AddCartItemDto {
  serviceId: string;
  slotDate: string;
  slotTime: string;
  quantity: number;
}

export interface UpdateCartItemDto {
  quantity?: number;
  slotDate?: string;
  slotTime?: string;
}

/**
 * Business logic for cart operations.
 * Validates service existence and slot availability before mutating cart.
 */
export class CartService {
  async getCart(userId: string): Promise<ICart> {
    const cart = await cartRepository.findByUserId(userId);
    if (!cart) {
      // Return an empty shell — no DB record yet
      return {
        userId: new mongoose.Types.ObjectId(userId),
        items: [],
        expiresAt: new Date(),
      } as unknown as ICart;
    }
    return cart;
  }

  async addItem(userId: string, dto: AddCartItemDto): Promise<ICart> {
    // Verify service exists and the slot is available
    const service = await serviceRepository.findById(dto.serviceId);
    if (!service) throw new NotFoundError('Service not found');

    const slot = service.availableSlots.find(
      (s) => s.date === dto.slotDate && s.time === dto.slotTime,
    );
    if (!slot) {
      throw new BadRequestError('The selected slot does not exist for this service', 'SLOT_NOT_FOUND');
    }

    const remaining = slot.capacity - slot.bookedCount;
    if (dto.quantity > remaining) {
      throw new BadRequestError(
        `Only ${remaining} spot(s) available for this slot`,
        'SLOT_INSUFFICIENT_CAPACITY',
      );
    }

    const cart = await cartRepository.addItem(userId, {
      serviceId: new mongoose.Types.ObjectId(dto.serviceId),
      slotDate: dto.slotDate,
      slotTime: dto.slotTime,
      quantity: dto.quantity,
      priceAtAdd: service.price,
    });

    if (!cart) throw new BadRequestError('Failed to add item to cart');
    return cart;
  }

  async updateItem(userId: string, itemId: string, dto: UpdateCartItemDto): Promise<ICart> {
    const exists = await cartRepository.itemExists(userId, itemId);
    if (!exists) throw new NotFoundError('Cart item not found');

    const cart = await cartRepository.updateItem(userId, itemId, dto);
    if (!cart) throw new NotFoundError('Cart not found');
    return cart;
  }

  async removeItem(userId: string, itemId: string): Promise<ICart> {
    const exists = await cartRepository.itemExists(userId, itemId);
    if (!exists) throw new NotFoundError('Cart item not found');

    const cart = await cartRepository.removeItem(userId, itemId);
    if (!cart) throw new NotFoundError('Cart not found');
    return cart;
  }
}

export const cartService = new CartService();
