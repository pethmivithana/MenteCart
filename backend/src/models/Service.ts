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
  startTime: string; // e.g. '09:00'
  endTime?: string; // optional end time '10:00'
  capacity: number;
  remainingCapacity: number;
  // kept for backward compatibility
  bookedCount?: number;
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
    startTime: { type: String, required: true },
    endTime: { type: String },
    capacity: { type: Number, required: true, min: 1 },
    remainingCapacity: { type: Number, required: true, min: 0 },
    bookedCount: { type: Number, default: 0, min: 0 },
  },
  { _id: true },
);

// Virtual to keep older `time` serialization for backward compatibility
availableSlotSchema.virtual('time').get(function (this: any) {
  return this.startTime;
});

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
// Index slots for quick availability lookup
serviceSchema.index({ 'availableSlots.date': 1, 'availableSlots.startTime': 1 });

export const Service = mongoose.model<IService>('Service', serviceSchema);
