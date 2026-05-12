import mongoose, { Document, Schema } from 'mongoose';

export type ServiceCategory =
  | 'cleaning'
  | 'plumbing'
  | 'electrical'
  | 'tutoring'
  | 'beauty'
  | 'fitness'
  | 'repair'
  | 'other';

export interface IAvailableSlot {
  date: string; // ISO date string: 'YYYY-MM-DD'
  time: string; // e.g. '09:00', '14:30'
  capacity: number;
  bookedCount: number;
}

export interface IService extends Document {
  _id: mongoose.Types.ObjectId;
  title: string;
  description: string;
  price: number;
  duration: number; // minutes
  category: ServiceCategory;
  image: string;
  capacityPerSlot: number;
  availableSlots: IAvailableSlot[];
  isActive: boolean;
  rating: number;
  reviewCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const availableSlotSchema = new Schema<IAvailableSlot>(
  {
    date: { type: String, required: true },
    time: { type: String, required: true },
    capacity: { type: Number, required: true, min: 1 },
    bookedCount: { type: Number, default: 0, min: 0 },
  },
  { _id: true },
);

const serviceSchema = new Schema<IService>(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      maxlength: [1000, 'Description cannot exceed 1000 characters'],
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
    },
    duration: {
      type: Number,
      required: [true, 'Duration is required'],
      min: [15, 'Duration must be at least 15 minutes'],
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: ['cleaning', 'plumbing', 'electrical', 'tutoring', 'beauty', 'fitness', 'repair', 'other'],
    },
    image: {
      type: String,
      default: 'https://via.placeholder.com/400x300?text=Service',
    },
    capacityPerSlot: {
      type: Number,
      required: true,
      min: [1, 'Capacity must be at least 1'],
      default: 1,
    },
    availableSlots: [availableSlotSchema],
    isActive: { type: Boolean, default: true },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    reviewCount: { type: Number, default: 0 },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true, versionKey: false },
  },
);

// Index for search and filtering
serviceSchema.index({ title: 'text', description: 'text' });
serviceSchema.index({ category: 1 });
serviceSchema.index({ price: 1 });
serviceSchema.index({ isActive: 1 });

export const Service = mongoose.model<IService>('Service', serviceSchema);
