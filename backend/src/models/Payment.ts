import mongoose, { Document, Schema } from 'mongoose';

export type PaymentMethod = 'payhere' | 'cash';
export type PaymentGatewayStatus = 'pending' | 'completed' | 'failed' | 'cancelled';

export interface IPayment extends Document {
  _id: mongoose.Types.ObjectId;
  bookingId: mongoose.Types.ObjectId;
  bookingRef: string;
  userId: mongoose.Types.ObjectId;
  amount: number;
  currency: string;
  method: PaymentMethod;
  status: PaymentGatewayStatus;
  paymentReference?: string; // External payment ID from PayHere
  transactionId?: string;
  webhookRawBody?: string;
  webhookSignature?: string;
  webhookProcessed?: boolean;
  webhookProcessedAt?: Date;
  metadata?: Record<string, any>;
  failureReason?: string;
  createdAt: Date;
  updatedAt: Date;
}

const paymentSchema = new Schema<IPayment>(
  {
    bookingId: {
      type: Schema.Types.ObjectId,
      ref: 'Booking',
      required: true,
    },
    bookingRef: {
      type: String,
      required: true,
      index: true,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
    currency: {
      type: String,
      default: 'LKR',
      required: true,
    },
    method: {
      type: String,
      enum: ['payhere', 'cash'],
      default: 'payhere',
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'cancelled'],
      default: 'pending',
      index: true,
    },
    paymentReference: {
      type: String,
      index: true,
    },
    transactionId: {
      type: String,
      index: true,
    },
    webhookRawBody: { type: String },
    webhookSignature: { type: String },
    webhookProcessed: { type: Boolean, default: false },
    webhookProcessedAt: { type: Date },
    metadata: { type: Schema.Types.Mixed },
    failureReason: { type: String },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true, versionKey: false },
  },
);

// Indexes for efficient queries
paymentSchema.index({ bookingId: 1 });
paymentSchema.index({ bookingRef: 1 });
paymentSchema.index({ userId: 1, createdAt: -1 });
paymentSchema.index({ status: 1 });
paymentSchema.index({ paymentReference: 1 });

export const Payment = mongoose.model<IPayment>('Payment', paymentSchema);
