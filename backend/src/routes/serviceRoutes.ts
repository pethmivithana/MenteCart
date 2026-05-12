import { Router } from 'express';
import { listServices, getServiceById } from '../controllers/serviceController';
import { validate } from '../middlewares/validate';
import { listServicesSchema, serviceIdSchema } from '../validators/serviceValidators';

const router = Router();

/**
 * @route   GET /api/services
 * @access  Public
 */
router.get('/', validate(listServicesSchema), listServices);

/**
 * @route   GET /api/services/:id
 * @access  Public
 */
router.get('/:id', validate(serviceIdSchema), getServiceById);

export default router;
