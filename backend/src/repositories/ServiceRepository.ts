import mongoose from 'mongoose';
import { IService, Service } from '../models/Service';

export interface ServiceFilters {
  category?: string;
  search?: string;
  minPrice?: number;
  maxPrice?: number;
  page: number;
  limit: number;
}

export interface PaginatedServices {
  services: IService[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/**
 * Data access layer for Service collection.
 * Supports paginated listing with category/search/price filters.
 */
function escapeRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export class ServiceRepository {
  async findMany(filters: ServiceFilters): Promise<PaginatedServices> {
    const { category, search, minPrice, maxPrice, page, limit } = filters;

    const query: mongoose.FilterQuery<IService> = { isActive: true };

    if (category) query.category = category;
    if (search && search.trim()) {
      const rx = new RegExp(escapeRegex(search.trim()), 'i');
      query.$or = [{ title: rx }, { description: rx }];
    }
    if (minPrice !== undefined || maxPrice !== undefined) {
      query.price = {};
      if (minPrice !== undefined) query.price.$gte = minPrice;
      if (maxPrice !== undefined) query.price.$lte = maxPrice;
    }

    const skip = (page - 1) * limit;
    const [services, total] = await Promise.all([
      Service.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit).exec(),
      Service.countDocuments(query),
    ]);

    return {
      services,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findById(id: string): Promise<IService | null> {
    if (!mongoose.Types.ObjectId.isValid(id)) return null;
    return Service.findOne({ _id: id, isActive: true }).exec();
  }

  async findByIdRaw(id: string): Promise<IService | null> {
    if (!mongoose.Types.ObjectId.isValid(id)) return null;
    return Service.findById(id).exec();
  }

  async create(data: Partial<IService>): Promise<IService> {
    return Service.create(data);
  }

  /**
   * Atomically increment the bookedCount on a specific slot.
   * Returns the updated service only if the slot has available capacity.
   */
  async incrementSlotBookedCount(
    serviceId: string,
    slotDate: string,
    slotTime: string,
    increment: number,
  ): Promise<IService | null> {
    // First, fetch the service to check current capacity
    const service = await Service.findById(serviceId).exec();
    if (!service) return null;

    const slot = service.availableSlots.find(
      (s) => s.date === slotDate && s.time === slotTime,
    );
    if (!slot) return null;

    // Check if incrementing would exceed capacity
    if (slot.bookedCount + increment > slot.capacity) {
      return null; // Capacity exceeded - return null to indicate failure
    }

    // Capacity is available, atomically increment
    return Service.findOneAndUpdate(
      {
        _id: serviceId,
        'availableSlots.date': slotDate,
        'availableSlots.time': slotTime,
      },
      {
        $inc: { 'availableSlots.$[slot].bookedCount': increment },
      },
      {
        arrayFilters: [{ 'slot.date': slotDate, 'slot.time': slotTime }],
        new: true,
        runValidators: true,
      },
    ).exec();
  }

  /**
   * Atomically decrement bookedCount (used on cancellation).
   */
  async decrementSlotBookedCount(
    serviceId: string,
    slotDate: string,
    slotTime: string,
    decrement: number,
  ): Promise<void> {
    await Service.updateOne(
      { _id: serviceId, 'availableSlots.date': slotDate, 'availableSlots.time': slotTime },
      {
        $inc: { 'availableSlots.$[slot].bookedCount': -decrement },
      },
      {
        arrayFilters: [{ 'slot.date': slotDate, 'slot.time': slotTime }],
      },
    ).exec();
  }
}

export const serviceRepository = new ServiceRepository();
