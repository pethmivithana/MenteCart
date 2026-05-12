import { z } from 'zod';

export const listServicesSchema = z.object({
  query: z.object({
    page: z.string().optional(),
    limit: z.string().optional(),
    category: z
      .enum(['cleaning', 'plumbing', 'electrical', 'tutoring', 'beauty', 'fitness', 'repair', 'other'])
      .optional(),
    search: z.string().max(100).optional(),
    minPrice: z.string().optional(),
    maxPrice: z.string().optional(),
  }),
});

export const serviceIdSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Service ID is required'),
  }),
});

export type ListServicesInput = z.infer<typeof listServicesSchema>['query'];
