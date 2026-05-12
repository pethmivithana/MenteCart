import { z } from 'zod';

export const bookingIdSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Booking ID is required'),
  }),
});

export const listBookingsSchema = z.object({
  query: z.object({
    page: z.string().optional(),
    limit: z.string().optional(),
    status: z
      .enum(['pending', 'confirmed', 'completed', 'cancelled', 'failed'])
      .optional(),
  }),
});

export const cancelBookingSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Booking ID is required'),
  }),
  body: z.object({
    reason: z.string().max(500).optional(),
  }),
});

export type ListBookingsInput = z.infer<typeof listBookingsSchema>['query'];
