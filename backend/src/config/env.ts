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
  // Cart expiry in minutes (default 15)
  CART_EXPIRY_MINUTES: z.string().default('15'),
  MAX_BOOKINGS_PER_DAY: z.string().default('5'),
  CORS_ORIGIN: z.string().default('*'),
  PAYHERE_MERCHANT_ID: z.string().min(1, 'PAYHERE_MERCHANT_ID is required'),
  PAYHERE_SECRET: z.string().min(1, 'PAYHERE_SECRET is required'),
  WEBHOOK_SECRET: z.string().default(''),
  PAYHERE_API_URL: z.string().default('https://sandbox.payhere.lk/pay/checkout'),
  // Cancellation cutoff in hours (default 2)
  CANCELLATION_CUTOFF_HOURS: z.string().default('2'),
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
  // minutes
  CART_EXPIRY_MINUTES: parseInt(parsed.data.CART_EXPIRY_MINUTES, 10),
  MAX_BOOKINGS_PER_DAY: parseInt(parsed.data.MAX_BOOKINGS_PER_DAY, 10),
  PAYHERE_MERCHANT_ID: parsed.data.PAYHERE_MERCHANT_ID,
  PAYHERE_SECRET: parsed.data.PAYHERE_SECRET,
  WEBHOOK_SECRET: parsed.data.WEBHOOK_SECRET,
  PAYHERE_API_URL: parsed.data.PAYHERE_API_URL,
  CANCELLATION_CUTOFF_HOURS: parseInt(parsed.data.CANCELLATION_CUTOFF_HOURS, 10),
};
