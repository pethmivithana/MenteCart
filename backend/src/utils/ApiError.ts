/**
 * Custom API error class that carries HTTP status code and a machine-readable errorCode.
 * Extend this for domain-specific errors.
 */
export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly errorCode: string;
  public readonly isOperational: boolean;

  constructor(statusCode: number, message: string, errorCode: string, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.isOperational = isOperational;
    Error.captureStackTrace(this, this.constructor);
  }
}

// ─── Common Error Factories ───────────────────────────────────────────────────

export class NotFoundError extends ApiError {
  constructor(message = 'Resource not found') {
    super(404, message, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends ApiError {
  constructor(message = 'Unauthorized') {
    super(401, message, 'UNAUTHORIZED');
  }
}

export class ForbiddenError extends ApiError {
  constructor(message = 'Forbidden') {
    super(403, message, 'FORBIDDEN');
  }
}

export class BadRequestError extends ApiError {
  constructor(message = 'Bad request', errorCode = 'BAD_REQUEST') {
    super(400, message, errorCode);
  }
}

export class ConflictError extends ApiError {
  constructor(message = 'Conflict', errorCode = 'CONFLICT') {
    super(409, message, errorCode);
  }
}

export class InternalServerError extends ApiError {
  constructor(message = 'Internal server error') {
    super(500, message, 'INTERNAL_SERVER_ERROR', false);
  }
}
