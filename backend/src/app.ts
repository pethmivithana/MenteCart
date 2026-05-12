import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { env } from './config/env';
import { errorHandler, notFoundHandler } from './middlewares/errorHandler';

// Route imports
import authRoutes from './routes/authRoutes';
import serviceRoutes from './routes/serviceRoutes';
import cartRoutes from './routes/cartRoutes';
import bookingRoutes from './routes/bookingRoutes';

/**
 * Creates and configures the Express application.
 * Separation from server.ts allows easy testing without binding a port.
 */
export const createApp = (): Application => {
  const app = express();

  // ─── Security & CORS ─────────────────────────────────────────────────────
  app.use(
    cors({
      origin: env.CORS_ORIGIN,
      credentials: true,
      methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    }),
  );

  // ─── Body Parsing ─────────────────────────────────────────────────────────
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));

  // ─── Request Logging ──────────────────────────────────────────────────────
  if (env.NODE_ENV !== 'test') {
    app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));
  }

  // ─── Health Check ─────────────────────────────────────────────────────────
  app.get('/health', (_req: Request, res: Response) => {
    res.status(200).json({
      status: 'ok',
      environment: env.NODE_ENV,
      timestamp: new Date().toISOString(),
    });
  });

  // ─── API Routes ───────────────────────────────────────────────────────────
  app.use('/api/auth', authRoutes);
  app.use('/api/services', serviceRoutes);
  app.use('/api/cart', cartRoutes);
  app.use('/api/bookings', bookingRoutes);

  // ─── Error Handling ───────────────────────────────────────────────────────
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
