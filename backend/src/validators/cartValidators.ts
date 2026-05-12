import { z } from 'zod';

const slotDateRegex = /^\d{4}-\d{2}-\d{2}$/;
const slotTimeRegex = /^\d{2}:\d{2}$/;

export const addCartItemSchema = z.object({
  body: z.object({
    serviceId: z.string().min(1, 'serviceId is required'),
    slotDate: z
      .string()
      .regex(slotDateRegex, 'slotDate must be in YYYY-MM-DD format')
      .refine((d) => new Date(d) >= new Date(new Date().toDateString()), {
        message: 'slotDate cannot be in the past',
      }),
    slotTime: z.string().regex(slotTimeRegex, 'slotTime must be in HH:MM format'),
    quantity: z.number().int().min(1, 'Quantity must be at least 1').max(10),
  }),
});

export const updateCartItemSchema = z.object({
  params: z.object({
    itemId: z.string().min(1, 'Item ID is required'),
  }),
  body: z
    .object({
      quantity: z.number().int().min(1).max(10).optional(),
      slotDate: z.string().regex(slotDateRegex).optional(),
      slotTime: z.string().regex(slotTimeRegex).optional(),
    })
    .refine((data) => Object.keys(data).length > 0, {
      message: 'At least one field must be provided',
    }),
});

export const cartItemIdSchema = z.object({
  params: z.object({
    itemId: z.string().min(1, 'Item ID is required'),
  }),
});

export type AddCartItemInput = z.infer<typeof addCartItemSchema>['body'];
export type UpdateCartItemInput = z.infer<typeof updateCartItemSchema>['body'];
