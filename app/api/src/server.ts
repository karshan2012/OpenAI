import express from 'express';
import cors from 'cors';
import { authenticate } from './auth.js';
import { dashboardsRouter } from './routes/dashboards.js';
import { pool } from './db.js';

const app = express();
app.use(cors());
app.use(express.json());
app.use(authenticate);
app.use('/api', dashboardsRouter);

app.get('/healthz', (_req, res) => res.json({ status: 'ok' }));

const port = process.env.PORT ? Number(process.env.PORT) : 3001;

app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});

process.on('SIGTERM', async () => {
  await pool.end();
  process.exit(0);
});
