import { Request, Response } from 'express';
import { serviceService } from '../services/ServiceService';
import { asyncHandler } from '../utils/asyncHandler';
import { ApiResponse } from '../utils/ApiResponse';

/**
 * GET /api/services
 * Supports: ?page, ?limit, ?category, ?search, ?minPrice, ?maxPrice
 */
export const listServices = asyncHandler(async (req: Request, res: Response) => {
  const { page, limit, category, search, minPrice, maxPrice } = req.query as Record<string, string>;

  const result = await serviceService.listServices({
    page: page ? parseInt(page) : 1,
    limit: limit ? parseInt(limit) : 10,
    category,
    search,
    minPrice: minPrice ? parseFloat(minPrice) : undefined,
    maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
  });

  ApiResponse.paginated(
    res,
    result.services,
    {
      total: result.total,
      page: result.page,
      limit: result.limit,
      totalPages: result.totalPages,
    },
    'Services fetched successfully',
  );
});

/**
 * GET /api/services/:id
 */
export const getServiceById = asyncHandler(async (req: Request, res: Response) => {
  const service = await serviceService.getServiceById(req.params.id);
  ApiResponse.success(res, { service }, 'Service fetched successfully');
});
