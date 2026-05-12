import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { UnauthorizedError } from '../utils/ApiError';
import { AuthRequest, JwtPayload } from '../types';

/**
 * JWT authentication middleware.
 * Attaches the decoded user payload to req.user on success.
 * Rejects requests with missing, malformed, or expired tokens.
 */
export const authenticate = (req: AuthRequest, _res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new UnauthorizedError('Authorization token is missing');
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as JwtPayload;
    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
    };
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new UnauthorizedError('Your session has expired. Please log in again.');
    }
    throw new UnauthorizedError('Invalid or malformed token');
  }
};

/**
 * Role-based authorization guard. Must be used after authenticate().
 */
export const authorize =
  (...roles: string[]) =>
  (req: AuthRequest, _res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role)) {
      throw new UnauthorizedError('You do not have permission to perform this action');
    }
    next();
  };
