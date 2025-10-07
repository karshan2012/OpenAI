import dotenv from 'dotenv';

dotenv.config({ path: '../../infra/.env' });

dotenv.config();

export const NODE_ENV = process.env.NODE_ENV ?? 'development';
export const DATABASE_URL = process.env.DATABASE_URL ?? 'postgres://postgres:postgres@localhost:5432/chatgpt_analytics';
export const JWT_PUBLIC_KEY = process.env.JWT_PUBLIC_KEY ?? '';

if (!JWT_PUBLIC_KEY) {
  console.warn('Warning: JWT_PUBLIC_KEY is not set. API authentication will fail.');
}
