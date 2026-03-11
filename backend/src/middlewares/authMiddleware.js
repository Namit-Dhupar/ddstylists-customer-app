const jwt = require('jsonwebtoken');

/**
 * Middleware to protect routes and mitigate BOLA (Broken Object Level Authorization).
 * Ensures the user making the request is authenticated and sets req.user.
 */
const requireAuth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authentication required. Missing or invalid Bearer token.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'super_secret_jwt_key_here');
    
    // Attach user payload (e.g., { id, role }) to request
    req.user = decoded;
    next();
  } catch (error) {
    console.error('Auth Error:', error.message);
    return res.status(401).json({ error: 'Invalid or expired token.' });
  }
};

/**
 * Middleware to enforce strict BOLA checks.
 * Use after requireAuth when user ID must precisely match the targeted resource ID.
 */
const enforceUserOwnership = (req, res, next) => {
  requireAuth(req, res, () => {
    // Look for target user ID in body, params, or query
    const targetUserId = req.body.userId || req.params.userId || req.query.userId;
    
    if (targetUserId && targetUserId !== req.user.id) {
      return res.status(403).json({ error: 'Forbidden. You do not have permission to access or modify this resource (BOLA protection).' });
    }
    next();
  });
};

module.exports = { requireAuth, enforceUserOwnership };
