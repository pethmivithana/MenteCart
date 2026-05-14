import mongoose from 'mongoose';
import { Payment, IPayment, PaymentGatewayStatus } from '../models/Payment';

export class PaymentRepository {
  async create(data: Partial<IPayment>): Promise<IPayment> {
    const payment = new Payment(data);
    return payment.save();
  }

  async findById(id: string): Promise<IPayment | null> {
    return Payment.findById(id);
  }

  async findByPaymentReference(paymentReference: string): Promise<IPayment | null> {
    return Payment.findOne({ paymentReference });
  }

  async findByBookingId(bookingId: string): Promise<IPayment | null> {
    return Payment.findOne({ bookingId });
  }

  async findByBookingRef(bookingRef: string): Promise<IPayment | null> {
    return Payment.findOne({ bookingRef });
  }

  async findByTransactionId(transactionId: string): Promise<IPayment | null> {
    return Payment.findOne({ transactionId });
  }

  async updateStatus(
    id: string,
    status: PaymentGatewayStatus,
    updates?: Partial<IPayment>,
  ): Promise<IPayment | null> {
    return Payment.findByIdAndUpdate(
      id,
      { status, ...updates },
      { new: true, runValidators: true },
    );
  }

  async markWebhookProcessed(id: string, signature?: string): Promise<IPayment | null> {
    return Payment.findByIdAndUpdate(
      id,
      {
        webhookProcessed: true,
        webhookProcessedAt: new Date(),
        webhookSignature: signature,
      },
      { new: true },
    );
  }

  async findUserPayments(userId: string, page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;
    const payments = await Payment.find({ userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Payment.countDocuments({ userId });

    return {
      payments,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }
}

export const paymentRepository = new PaymentRepository();
