import mongoose, { Document, Schema } from 'mongoose';

export type BookingStatus =
  | 'pending'
  | 'confirmed'
  | 'completed'
  | 'cancelled'
  | 'failed';

export type PaymentStatus = 'pending' | 'completed' | 'failed' | 'cancelled';

export interface IBookingItem {
  _id: mongoose.Types.ObjectId;
  serviceId: mongoose.Types.ObjectId;
  serviceTitle: string;   // Snapshot at booking time
  serviceImage: string;
  slotDate: string;
  slotTime: string;
  quantity: number;
  pricePerUnit: number;
  subtotal: number;
}

export interface IBooking extends Document {
  _id: mongoose.Types.ObjectId;
  bookingRef: string;
  userId: mongoose.Types.ObjectId;
  items: IBookingItem[];
  totalAmount: number;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  paymentId?: string;
  cancelledAt?: Date;
  cancellationReason?: string;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const bookingItemSchema = new Schema<IBookingItem>(
  {
    serviceId: {
      type: Schema.Types.ObjectId,
      ref: 'Service',
      required: true,
    },
    serviceTitle: { type: String, required: true },
    serviceImage: { type: String, default: '' },
    slotDate: { type: String, required: true },
    slotTime: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    pricePerUnit: { type: Number, required: true },
    subtotal: { type: Number, required: true },
  },
  { _id: true },
);

const bookingSchema = new Schema<IBooking>(
  {
    bookingRef: {
      type: String,
      required: true,
      unique: true,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    items: {
      type: [bookingItemSchema],
      required: true,
      validate: [(arr: IBookingItem[]) => arr.length > 0, 'Booking must have at least one item'],
    },
    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'completed', 'cancelled', 'failed'],
      default: 'pending',
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'cancelled'],
      default: 'pending',
    },
    paymentId: { type: String },
    cancelledAt: { type: Date },
    cancellationReason: { type: String, maxlength: 500 },
    notes: { type: String, maxlength: 500 },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true, versionKey: false },
  },
);

bookingSchema.index({ userId: 1, createdAt: -1 });
bookingSchema.index({ bookingRef: 1 });
bookingSchema.index({ status: 1 });

export const Booking = mongoose.model<IBooking>('Booking', bookingSchema);
