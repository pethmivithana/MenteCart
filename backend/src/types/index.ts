import { Request } from 'express';
import { IUser } from '../models/User';

/**
 * Extends Express Request to include authenticated user payload.
 */
export interface AuthRequest extends Request {
  user?: {
    userId: string;
    email: string;
    role: string;
  };
}

export interface PaginationQuery {
  page?: string;
  limit?: string;
}

export interface ServiceQuery extends PaginationQuery {
  category?: string;
  search?: string;
  minPrice?: string;
  maxPrice?: string;
}

export interface JwtPayload {
  userId: string;
  email: string;
  role: string;
  iat?: number;
  exp?: number;
}
