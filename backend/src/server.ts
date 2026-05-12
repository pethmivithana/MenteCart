import { createApp } from './app';
import { connectDatabase } from './config/database';
import { env } from './config/env';
import { logger } from './utils/logger';

/**
 * Application entry point.
 * Connects to DB before starting the HTTP server to fail fast on bad config.
 */
const startServer = async (): Promise<void> => {
  try {
    await connectDatabase();

    const app = createApp();

    const server = app.listen(env.PORT, () => {
      logger.info(`🚀 MenteCart API running on http://localhost:${env.PORT}`);
      logger.info(`   Environment : ${env.NODE_ENV}`);
      logger.info(`   Health check: http://localhost:${env.PORT}/health`);
    });

    // ─── Graceful Shutdown ─────────────────────────────────────────────────
    const shutdown = (signal: string) => {
      logger.info(`Received ${signal}. Shutting down gracefully...`);
      server.close(() => {
        logger.info('HTTP server closed.');
        process.exit(0);
      });

      // Force kill if graceful shutdown takes too long
      setTimeout(() => {
        logger.error('Forcefully shutting down after timeout');
        process.exit(1);
      }, 10_000);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

    process.on('unhandledRejection', (reason) => {
      logger.error({ reason }, 'Unhandled Promise Rejection');
      shutdown('unhandledRejection');
    });
  } catch (error) {
    logger.error({ error }, 'Failed to start server');
    process.exit(1);
  }
};

startServer();
