const request = require('supertest');
const app = require('../src/app');
const jwt = require('jsonwebtoken');

describe('Security & Hardening Tests', () => {

  const validToken = jwt.sign({ id: 'mock_user_123', role: 'customer' }, process.env.JWT_SECRET || 'super_secret_jwt_key_here', { expiresIn: '1h' });

  describe('Helmet & XSS Mitigation Headers', () => {
    it('should include secure headers (Helmet)', async () => {
      const res = await request(app).get('/api/health');
      expect(res.statusCode).toBe(200);
      expect(res.headers['x-dns-prefetch-control']).toBeDefined();
      expect(res.headers['x-frame-options']).toMatch(/SAMEORIGIN|DENY/);
      expect(res.headers['strict-transport-security']).toBeDefined();
      expect(res.headers['x-content-type-options']).toBe('nosniff');
    });
  });

  describe('BOLA & Auth Middleware', () => {
    it('should block unauthenticated access to /api/checkout/process (401)', async () => {
      const res = await request(app)
        .post('/api/checkout/process')
        .send({ amount: 100, currency: 'USD', region: 'IN' });
      expect(res.statusCode).toBe(401);
      expect(res.body.error).toContain('Authentication required');
    });

    it('should allow authenticated access to /api/checkout/process (200)', async () => {
      const res = await request(app)
        .post('/api/checkout/process')
        .set('Authorization', `Bearer ${validToken}`)
        .send({ amount: 100, currency: 'INR', region: 'IN', appointmentId: 'test_apt_1' });
      expect(res.statusCode).toBe(200);
      expect(res.body.data.gateway).toBe('Razorpay');
    });

    it('should block unauthenticated access to /api/agora/token (401)', async () => {
      const res = await request(app)
        .post('/api/agora/token')
        .send({ channelName: 'testChannel' });
      expect(res.statusCode).toBe(401);
    });
  });

  describe('Rate Limiting', () => {
    it('should limit repeated requests to prevent DDoS/Brute-force (429)', async () => {
      const res = await request(app).get('/api/health');
      expect(res.headers['x-ratelimit-limit']).toBeDefined();
      expect(res.headers['x-ratelimit-remaining']).toBeDefined();
    });
  });

});
