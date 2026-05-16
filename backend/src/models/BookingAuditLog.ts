import mongoose, { Document, Schema } from 'mongoose';

export interface IBookingAuditLog extends Document {
  bookingId: mongoose.Types.ObjectId;
  previousStatus: string;
  newStatus: string;
  changedBy?: string; // userId or 'system'
  reason?: string;
  createdAt: Date;
}

const bookingAuditSchema = new Schema<IBookingAuditLog>(
  {
    bookingId: { type: Schema.Types.ObjectId, ref: 'Booking', required: true },
    previousStatus: { type: String, required: true },
    newStatus: { type: String, required: true },
    changedBy: { type: String },
    reason: { type: String },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
    toJSON: { versionKey: false },
  },
);

bookingAuditSchema.index({ bookingId: 1, createdAt: -1 });

export const BookingAuditLog = mongoose.model<IBookingAuditLog>('BookingAuditLog', bookingAuditSchema);
