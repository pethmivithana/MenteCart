import { cartRepository } from '../repositories/CartRepository';
import { logger } from '../utils/logger';

// Runs every minute and clears expired carts older than now.
export function startCartExpiryScheduler(): void {
  const intervalMs = 60 * 1000; // 1 minute

  const job = async () => {
    try {
      const now = new Date();
      // Find carts that have expired and still have items
      const expired = await (await import('../models/Cart')).Cart.find({
        expiresAt: { $lte: now },
        'items.0': { $exists: true },
      }).exec();

      if (!expired || expired.length === 0) return;

      for (const cart of expired) {
        try {
          // If in future we reserve capacity at add-to-cart time, release here.
          // Currently reservations are made during checkout only.
          await cartRepository.deleteCart(cart.userId.toString());
          logger.info({ userId: cart.userId, cartId: cart._id }, 'Expired cart cleared');
        } catch (err) {
          logger.error({ err, cartId: cart._id }, 'Failed to clear expired cart');
        }
      }
    } catch (err) {
      logger.error({ err }, 'Cart expiry job failed');
    }
  };

  // Run immediately and then schedule
  job();
  setInterval(job, intervalMs);
}
