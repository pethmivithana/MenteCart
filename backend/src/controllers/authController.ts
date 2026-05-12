import { Response, NextFunction } from 'express';
import { authService } from '../services/AuthService';
import { asyncHandler } from '../utils/asyncHandler';
import { ApiResponse } from '../utils/ApiResponse';
import { AuthRequest } from '../types';

/**
 * POST /api/auth/signup
 */
export const signup = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { name, email, password } = req.body as { name: string; email: string; password: string };
  const { user, accessToken } = await authService.signup({ name, email, password });
  ApiResponse.created(res, { user, accessToken }, 'Account created successfully');
});

/**
 * POST /api/auth/login
 */
export const login = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { email, password } = req.body as { email: string; password: string };
  const { user, accessToken } = await authService.login({ email, password });
  ApiResponse.success(res, { user, accessToken }, 'Login successful');
});

/**
 * GET /api/auth/me  [protected]
 */
export const getMe = asyncHandler(async (req: AuthRequest, res: Response) => {
  const user = await authService.getMe(req.user!.userId);
  ApiResponse.success(res, { user }, 'Profile fetched successfully');
});
