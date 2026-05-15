import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: {
      colorize: true,
      singleLine: false,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
    },
  },
});

export const logError = (context: string, error: any, metadata?: Record<string, any>) => {
  const errorInfo = {
    context,
    message: error?.message || String(error),
    stack: error?.stack,
    ...metadata,
  };

  logger.error(errorInfo, `[${context}] ERROR: ${error?.message || String(error)}`);
};

export const logWarning = (context: string, message: string, metadata?: Record<string, any>) => {
  logger.warn({ context, ...metadata }, `[${context}] WARN: ${message}`);
};

export const logInfo = (context: string, message: string, metadata?: Record<string, any>) => {
  logger.info({ context, ...metadata }, `[${context}] INFO: ${message}`);
};

export const logDebug = (context: string, message: string, metadata?: Record<string, any>) => {
  logger.debug({ context, ...metadata }, `[${context}] DEBUG: ${message}`);
};

export default logger;
