import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import { config } from './infrastructure/config/env.config.js';
import { postgresPool } from './infrastructure/database/postgres/postgres.helper.js';
import { redisClient } from './infrastructure/redis/redis.helper.js';

const app = Fastify({
  logger: {
    level: config.NODE_ENV === 'production' ? 'info' : 'debug',
    transport: config.NODE_ENV !== 'production' ? { target: 'pino-pretty' } : undefined,
  },
});

await app.register(cors, { origin: config.CORS_ORIGIN.split(',') });
await app.register(helmet);

app.get('/health', async () => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

const start = async () => {
  try {
    await postgresPool.query('SELECT 1');
    app.log.info('PostgreSQL connected');

    await redisClient.ping();
    app.log.info('Redis connected');

    await app.listen({ port: config.PORT, host: '0.0.0.0' });
    app.log.info(`Server running on http://localhost:${config.PORT}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

start();