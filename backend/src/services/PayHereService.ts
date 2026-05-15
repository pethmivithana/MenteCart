import crypto from 'crypto';
import { env } from '../config/env';
import { BadRequestError } from '../utils/ApiError';
import { logger } from '../utils/logger';

export interface PayHereInitiatePaymentRequest {
  bookingRef: string;
  amount: number;
  currency: string;
  customerEmail: string;
  customerPhone: string;
  customerName: string;
  notifyUrl: string;
}

export interface PayHerePaymentResponse {
  merchant_id: string;
  return_web: string;
  cancel_url: string;
  notify_url: string;
  order_id: string;
  items: string;
  amount: string;
  currency: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  address: string;
  city: string;
  country: string;
  merchant_key: string;
}

export class PayHereService {
  /**
   * Initiates a PayHere payment.
   * Returns payment initialization data to send to PayHere.
   */
  initiatePayment(
    req: PayHereInitiatePaymentRequest,
    returnUrl: string,
  ): PayHerePaymentResponse {
    // Validate required environment variables
    const merchantId = (env as any).PAYHERE_MERCHANT_ID;
    if (!merchantId) {
      logger.error('Missing PAYHERE_MERCHANT_ID in environment');
      throw new BadRequestError('Payment gateway not configured', 'PAYMENT_GATEWAY_ERROR');
    }

    if (!returnUrl) {
      throw new BadRequestError('Return URL is required for payment', 'INVALID_RETURN_URL');
    }

    const merchantKey = this.generateMerchantKey(merchantId, req.bookingRef, req.amount);

    const response: PayHerePaymentResponse = {
      merchant_id: merchantId,
      return_web: returnUrl,
      cancel_url: returnUrl,
      notify_url: req.notifyUrl,
      order_id: req.bookingRef,
      items: 'Service Booking',
      amount: req.amount.toString(),
      currency: req.currency,
      first_name: req.customerName.split(' ')[0] || req.customerName,
      last_name: req.customerName.split(' ').slice(1).join(' ') || '',
      email: req.customerEmail,
      phone: req.customerPhone,
      address: 'N/A',
      city: 'N/A',
      country: 'Sri Lanka',
      merchant_key: merchantKey,
    };

    logger.info(
      { bookingRef: req.bookingRef, amount: req.amount, merchantId },
      'PayHere payment initiated successfully',
    );

    return response;
  }

  /**
   * Generates merchant key for PayHere (SHA1 hash).
   * Format: SHA1("{merchant_id}{order_id}{amount}{merchant_secret}")
   */
  private generateMerchantKey(merchantId: string, orderId: string, amount: number): string {
    const hashString = `${merchantId}${orderId}${amount}${(env as any).PAYHERE_SECRET}`;
    return crypto.createHash('sha1').update(hashString).digest('hex');
  }

  /**
   * Verifies webhook signature from PayHere.
   * Expected header format: merchant_id;order_id;payment_status;MD5(merchant_secret + order_id + payment_status)
   */
  verifyWebhookSignature(rawBody: string, authHeader?: string): boolean {
    if (!authHeader) {
      logger.warn('Missing Authorization header in PayHere webhook');
      return false;
    }

    try {
      const parts = authHeader.split(';');
      if (parts.length !== 4) {
        logger.warn({ authHeader }, 'Invalid webhook authorization header format');
        return false;
      }

      const [merchantId, orderId, paymentStatus, signature] = parts;

      if (merchantId !== (env as any).PAYHERE_MERCHANT_ID) {
        logger.warn({ merchantId }, 'Merchant ID mismatch in webhook');
        return false;
      }

      // Reconstruct the hash: MD5(merchant_secret + order_id + payment_status)
      const expectedHash = crypto
        .createHash('md5')
        .update(`${(env as any).PAYHERE_SECRET}${orderId}${paymentStatus}`)
        .digest('hex');

      const isValid = signature === expectedHash;

      if (!isValid) {
        logger.warn(
          { expected: expectedHash, received: signature, orderId },
          'Webhook signature verification failed',
        );
      }

      return isValid;
    } catch (error) {
      logger.error({ error, authHeader }, 'Error verifying webhook signature');
      return false;
    }
  }

  /**
   * Parses PayHere webhook payload.
   */
  parseWebhookPayload(body: Record<string, any>) {
    return {
      merchantId: body.merchant_id,
      orderId: body.order_id,
      paymentId: body.payment_id,
      paymentStatus: body.payment_status, // 2 = success, other values = failure
      amount: parseFloat(body.amount) || 0,
      currency: body.currency,
      transactionId: body.custom_1, // Can store custom data
      statusMessage: body.status_message,
      riskLevel: body.risk_level,
      respCode: body.resp_code,
    };
  }

  /**
   * Checks if payment status code indicates success.
   */
  isPaymentSuccessful(paymentStatus: string | number): boolean {
    return paymentStatus === 2 || paymentStatus === '2';
  }
}

export const payHereService = new PayHereService();
