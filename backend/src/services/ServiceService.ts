import { serviceRepository, ServiceFilters, PaginatedServices } from '../repositories/ServiceRepository';
import { NotFoundError } from '../utils/ApiError';
import { IService } from '../models/Service';

/**
 * Business logic layer for Services.
 */
export class ServiceService {
  async listServices(filters: Omit<ServiceFilters, 'page' | 'limit'> & { page?: number; limit?: number }): Promise<PaginatedServices> {
    const page = Math.max(1, filters.page ?? 1);
    const limit = Math.min(50, Math.max(1, filters.limit ?? 10));
    return serviceRepository.findMany({ ...filters, page, limit });
  }

  async getServiceById(id: string): Promise<IService> {
    const service = await serviceRepository.findById(id);
    if (!service) throw new NotFoundError('Service not found');
    return service;
  }
}

export const serviceService = new ServiceService();
