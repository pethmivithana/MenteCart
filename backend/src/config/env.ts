import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

/**
 * Validates and exports environment variables using Zod.
 * Throws at startup if any required variable is missing.
 */
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('5000'),
  MONGODB_URI: z.string().min(1, 'MONGODB_URI is required'),
  JWT_SECRET: z.string().min(1, 'JWT_SECRET is required'),
  JWT_EXPIRES_IN: z.string().default('1d'),
  BCRYPT_SALT_ROUNDS: z.string().default('10'),
  CART_EXPIRY_HOURS: z.string().default('24'),
  MAX_BOOKINGS_PER_DAY: z.string().default('5'),
  CORS_ORIGIN: z.string().default('*'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.format());
  process.exit(1);
}

export const env = {
  ...parsed.data,
  PORT: parseInt(parsed.data.PORT, 10),
  BCRYPT_SALT_ROUNDS: parseInt(parsed.data.BCRYPT_SALT_ROUNDS, 10),
  CART_EXPIRY_HOURS: parseInt(parsed.data.CART_EXPIRY_HOURS, 10),
  MAX_BOOKINGS_PER_DAY: parseInt(parsed.data.MAX_BOOKINGS_PER_DAY, 10),
};
