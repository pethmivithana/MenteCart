import { Router } from 'express';
import { signup, login, getMe } from '../controllers/authController';
import { authenticate } from '../middlewares/authenticate';
import { validate } from '../middlewares/validate';
import { signupSchema, loginSchema } from '../validators/authValidators';

const router = Router();

/**
 * @route   POST /api/auth/signup
 * @access  Public
 */
router.post('/signup', validate(signupSchema), signup);

/**
 * @route   POST /api/auth/login
 * @access  Public
 */
router.post('/login', validate(loginSchema), login);

/**
 * @route   GET /api/auth/me
 * @access  Private
 */
router.get('/me', authenticate, getMe);

export default router;
