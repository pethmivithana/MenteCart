import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';
import { ApiError } from '../utils/ApiError';

/**
 * Zod validation middleware factory.
 * Validates req.body, req.params, and req.query against the provided schema.
 * Returns structured 422 errors on failure.
 */
export const validate =
  (schema: AnyZodObject) =>
  async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.map((e) => ({
          field: e.path.slice(1).join('.'), // Remove 'body'/'query'/'params' prefix
          message: e.message,
        }));
        res.status(422).json({
          success: false,
          message: 'Validation failed',
          errorCode: 'VALIDATION_ERROR',
          errors,
        });
        return;
      }
      next(error);
    }
  };
