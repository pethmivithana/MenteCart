import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/ApiError';
import { env } from '../config/env';
import { logger } from '../utils/logger';

/**
 * Centralized Express error handler.
 * All errors — operational (ApiError) and unexpected — flow through here.
 * Returns a consistent error envelope: { statusCode, message, errorCode }.
 */
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction,
): void => {
  // Log all errors with request context
  logger.error(
    {
      err: {
        name: err.name,
        message: err.message,
        stack: err.stack,
      },
      req: {
        method: req.method,
        url: req.originalUrl,
        ip: req.ip,
      },
    },
    'Request error',
  );

  // Known operational errors (ApiError subclasses)
  if (err instanceof ApiError) {
    res.status(err.statusCode).json({
      success: false,
      statusCode: err.statusCode,
      message: err.message,
      errorCode: err.errorCode,
      ...(env.NODE_ENV === 'development' && { stack: err.stack }),
    });
    return;
  }

  // Mongoose duplicate key error
  if ((err as NodeJS.ErrnoException).name === 'MongoServerError') {
    const mongoErr = err as NodeJS.ErrnoException & { code?: number; keyValue?: Record<string, unknown> };
    if (mongoErr.code === 11000) {
      const field = Object.keys(mongoErr.keyValue ?? {})[0] ?? 'field';
      res.status(409).json({
        success: false,
        statusCode: 409,
        message: `${field} already exists`,
        errorCode: 'DUPLICATE_KEY',
      });
      return;
    }
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    res.status(400).json({
      success: false,
      statusCode: 400,
      message: err.message,
      errorCode: 'MONGOOSE_VALIDATION_ERROR',
    });
    return;
  }

  // Mongoose CastError (invalid ObjectId)
  if (err.name === 'CastError') {
    res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Invalid ID format',
      errorCode: 'INVALID_ID',
    });
    return;
  }

  // Unknown / unexpected errors
  const statusCode = 500;
  res.status(statusCode).json({
    success: false,
    statusCode,
    message: env.NODE_ENV === 'production' ? 'Something went wrong' : err.message,
    errorCode: 'INTERNAL_SERVER_ERROR',
    ...(env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

/**
 * 404 handler — must be registered after all routes.
 */
export const notFoundHandler = (req: Request, res: Response): void => {
  res.status(404).json({
    success: false,
    statusCode: 404,
    message: `Route ${req.method} ${req.originalUrl} not found`,
    errorCode: 'ROUTE_NOT_FOUND',
  });
};
