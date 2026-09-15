import { Redis } from 'ioredis';
import { config } from '../config/env.config.js';

export const redisClient = new Redis({
  host: config.REDIS_HOST,
  port: config.REDIS_PORT,
  maxRetriesPerRequest: 3,
  lazyConnect: true,
});
