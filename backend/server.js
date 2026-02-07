const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
require('dotenv').config();

// DB
const pool = require('./config/db');

const app = express();

/* =========================
   TRUST PROXY (K8s / NGINX)
========================= */
app.set('trust proxy', true);


/* =========================
   CORS CONFIG (FINAL FIX)
========================= */

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(o => o.trim())
  : [];

app.use(cors({
  origin: (origin, cb) => {
    // Allow non-browser requests (curl, health checks)
    if (!origin) return cb(null, true);

    // Allow everything outside prod
    if (process.env.NODE_ENV !== 'production') {
      return cb(null, true);
    }

    // Normalize origin (remove trailing slash)
    const normalizedOrigin = origin.replace(/\/$/, '');

    const isAllowed = allowedOrigins.some(o =>
      normalizedOrigin === o.replace(/\/$/, '')
    );

    if (isAllowed) {
      return cb(null, true);
    }

    console.warn('❌ CORS blocked:', origin);

    // ✅ IMPORTANT: deny WITHOUT throwing
    return cb(null, false);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Explicit OPTIONS handling (no errors)
app.options('*', (req, res) => {
  res.sendStatus(204);
});


/* =========================
   BODY PARSERS
========================= */
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/* =========================
   REQUEST LOGGER
========================= */
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

/* =========================
   HEALTH CHECKS
========================= */
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.get('/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

app.get('/health/db', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'db_ok' });
  } catch (err) {
    console.error('DB health failed:', err);
    res.status(500).json({ status: 'db_error' });
  }
});

/* =========================
   STATIC FILES
========================= */
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

/* =========================
   HTTP SERVER + SOCKET.IO
========================= */
const server = http.createServer(app);

const io = new Server(server, {
  path: '/socket.io',
  cors: {
    origin: (origin, cb) => cb(null, true),
    credentials: true
  },
  transports: ['websocket', 'polling'],
  pingTimeout: 60000,
  pingInterval: 25000
});

/* =========================
   ATTACH IO TO REQUEST
========================= */
app.use((req, res, next) => {
  req.io = io;
  next();
});

/* =========================
   SOCKET CONNECTIONS
========================= */
io.on('connection', (socket) => {
  console.log('🔌 Socket connected:', socket.id);

  socket.on('disconnect', () => {
    console.log('❌ Socket disconnected:', socket.id);
  });
});

/* =========================
   API ROUTES
========================= */
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/complaints', require('./routes/complaintRoutes'));
app.use('/api/tips', require('./routes/tipRoutes'));
app.use('/api/analytics', require('./routes/analyticsRoutes'));

/* =========================
   404 HANDLER (API ONLY)
========================= */
app.use('/api', (req, res) => {
  res.status(404).json({ message: 'API route not found' });
});

/* =========================
   ERROR HANDLER (NO 500 FOR CORS)
========================= */
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);

  if (err.message?.includes('CORS')) {
    return res.status(403).json({ message: 'CORS forbidden' });
  }

  res.status(500).json({ error: 'Internal Server Error' });
});

/* =========================
   START SERVER
========================= */
const PORT = process.env.PORT || 5000;

server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Backend running on port ${PORT}`);
  console.log(`✅ Socket.IO enabled`);
});

/* =========================
   GRACEFUL SHUTDOWN
========================= */
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down...');
  server.close(() => process.exit(0));
  io.close();
});
