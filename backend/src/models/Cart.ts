import mongoose, { Document, Schema } from 'mongoose';

export interface ICartItem {
  _id: mongoose.Types.ObjectId;
  serviceId: mongoose.Types.ObjectId;
  slotDate: string;   // 'YYYY-MM-DD'
  slotTime: string;   // 'HH:MM'
  quantity: number;
  priceAtAdd: number; // Snapshot of price when added
}

export interface ICart extends Document {
  _id: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  items: ICartItem[];
  expiresAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const cartItemSchema = new Schema<ICartItem>(
  {
    serviceId: {
      type: Schema.Types.ObjectId,
      ref: 'Service',
      required: true,
    },
    slotDate: {
      type: String,
      required: [true, 'Slot date is required'],
      match: [/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'],
    },
    slotTime: {
      type: String,
      required: [true, 'Slot time is required'],
      match: [/^\d{2}:\d{2}$/, 'Time must be in HH:MM format'],
    },
    quantity: {
      type: Number,
      required: true,
      min: [1, 'Quantity must be at least 1'],
      default: 1,
    },
    priceAtAdd: {
      type: Number,
      required: true,
    },
  },
  { _id: true },
);

const cartSchema = new Schema<ICart>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true, // One cart per user
    },
    items: [cartItemSchema],
    expiresAt: {
      type: Date,
      required: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true, versionKey: false },
  },
);

// TTL index — MongoDB auto-deletes expired carts
cartSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
cartSchema.index({ userId: 1 });

export const Cart = mongoose.model<ICart>('Cart', cartSchema);
