import mongoose from 'mongoose';
import { env } from './env';
import { logger } from '../utils/logger';

/**
 * Connects to MongoDB using Mongoose.
 * Exits the process on failure to avoid silent errors.
 */
export const connectDatabase = async (): Promise<void> => {
  try {
    mongoose.set('strictQuery', true);

    const conn = await mongoose.connect(env.MONGODB_URI, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });

    logger.info(`✅ MongoDB connected: ${conn.connection.host}`);

    mongoose.connection.on('error', (err) => {
      logger.error({ err }, 'MongoDB connection error');
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected. Attempting reconnect...');
    });
  } catch (error) {
    logger.error({ error }, '❌ Failed to connect to MongoDB');
    process.exit(1);
  }
};
