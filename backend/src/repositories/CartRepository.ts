import mongoose from 'mongoose';
import { env } from '../config/env';
import { Cart, ICart } from '../models/Cart';

/**
 * Data access layer for Cart collection.
 * One cart per user — upsert pattern used throughout.
 */
export class CartRepository {
  async findByUserId(userId: string): Promise<ICart | null> {
    return Cart.findOne({ userId }).populate('items.serviceId').exec();
  }

  async findByUserIdRaw(userId: string): Promise<ICart | null> {
    return Cart.findOne({ userId }).exec();
  }

  async upsertCart(userId: string): Promise<ICart> {
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + env.CART_EXPIRY_MINUTES);

    return Cart.findOneAndUpdate(
      { userId },
      {
        $setOnInsert: { userId, items: [], expiresAt },
      },
      { upsert: true, new: true },
    ).exec() as Promise<ICart>;
  }

  async addItem(
    userId: string,
    item: {
      serviceId: mongoose.Types.ObjectId;
      slotDate: string;
      slotTime: string;
      quantity: number;
      priceAtAdd: number;
    },
  ): Promise<ICart | null> {
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + env.CART_EXPIRY_MINUTES);

    return Cart.findOneAndUpdate(
      { userId },
      {
        $push: { items: item },
        $set: { expiresAt }, // Refresh expiry on activity
        $setOnInsert: { userId },
      },
      { upsert: true, new: true },
    ).exec();
  }

  async updateItem(
    userId: string,
    itemId: string,
    update: { quantity?: number; slotDate?: string; slotTime?: string },
  ): Promise<ICart | null> {
    const setFields: Record<string, unknown> = {};
    if (update.quantity !== undefined) setFields['items.$.quantity'] = update.quantity;
    if (update.slotDate) setFields['items.$.slotDate'] = update.slotDate;
    if (update.slotTime) setFields['items.$.slotTime'] = update.slotTime;

    return Cart.findOneAndUpdate(
      { userId, 'items._id': new mongoose.Types.ObjectId(itemId) },
      { $set: setFields },
      { new: true },
    ).exec();
  }

  async removeItem(userId: string, itemId: string): Promise<ICart | null> {
    return Cart.findOneAndUpdate(
      { userId },
      { $pull: { items: { _id: new mongoose.Types.ObjectId(itemId) } } },
      { new: true },
    ).exec();
  }

  async clearCart(userId: string): Promise<void> {
    await Cart.findOneAndUpdate({ userId }, { $set: { items: [] } }).exec();
  }

  async deleteCart(userId: string): Promise<void> {
    await Cart.deleteOne({ userId }).exec();
  }

  async itemExists(userId: string, itemId: string): Promise<boolean> {
    const count = await Cart.countDocuments({
      userId,
      'items._id': new mongoose.Types.ObjectId(itemId),
    });
    return count > 0;
  }
}

export const cartRepository = new CartRepository();
