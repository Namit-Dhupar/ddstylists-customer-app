const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const paymentRoutes = require('./routes/paymentRoutes');
const agoraRoutes = require('./routes/agoraRoutes');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Security Middleware (XSS, Clickjacking mitigation)
app.use(helmet());

// Rate Limiting (Brute-force/DDoS mitigation)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: true, // Return rate limit info in the `X-RateLimit-*` headers
  message: { error: 'Too many requests from this IP, please try again later.' }
});
app.use('/api', limiter);

// Basic route for health check
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'D&D Stylists API is running' });
});

app.use('/api/checkout', paymentRoutes);
app.use('/api/agora', agoraRoutes);

// Avoid 404s for undefined routes
app.use((req, res, next) => {
  res.status(404).json({ error: 'Not Found' });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

module.exports = app;
