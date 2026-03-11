const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_here';
const JWT_EXPIRES_IN = '7d';

function signToken(user) {
  return jwt.sign(
    { id: user._id, email: user.email, role: 'customer' },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

/**
 * POST /api/auth/register
 */
exports.register = async (req, res) => {
  try {
    const { firstName, lastName, username, email, password, phone, dob, stylePreference, country } = req.body;

    if (!firstName || !lastName || !username || !email || !password) {
      return res.status(400).json({ error: 'firstName, lastName, username, email, and password are required.' });
    }

    // Check duplicate email or username
    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      const field = existingUser.email === email ? 'email' : 'username';
      return res.status(409).json({ error: `A user with this ${field} already exists.` });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const user = await User.create({
      firstName,
      lastName,
      username,
      email: email.toLowerCase(),
      passwordHash,
      phone: phone || '',
      dob: dob ? new Date(dob) : undefined,
      stylePreference: stylePreference || 'Both',
      country: country || '',
      authProvider: 'Local',
    });

    const token = signToken(user);

    return res.status(201).json({
      message: 'Registration successful',
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        stylePreference: user.stylePreference,
        profileImage: user.profileImage,
      },
    });
  } catch (error) {
    console.error('Register Error:', error);
    return res.status(500).json({ error: 'Registration failed.' });
  }
};

/**
 * POST /api/auth/login
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user || !user.passwordHash) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const token = signToken(user);

    return res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        stylePreference: user.stylePreference,
        profileImage: user.profileImage,
        country: user.country,
      },
    });
  } catch (error) {
    console.error('Login Error:', error);
    return res.status(500).json({ error: 'Login failed.' });
  }
};

/**
 * POST /api/auth/social
 * Handles Google, Apple, Facebook social sign-in
 */
exports.socialLogin = async (req, res) => {
  try {
    const { provider, email, firstName, lastName, socialId, profileImage } = req.body;

    if (!provider || !email) {
      return res.status(400).json({ error: 'provider and email are required.' });
    }

    let user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      // Create new user from social login
      user = await User.create({
        firstName: firstName || 'User',
        lastName: lastName || '',
        username: email.split('@')[0] + '_' + Math.floor(Math.random() * 1000),
        email: email.toLowerCase(),
        authProvider: provider, // 'Google', 'Apple', 'Facebook'
        profileImage: profileImage || '',
      });
    }

    const token = signToken(user);

    return res.status(200).json({
      message: 'Social login successful',
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        stylePreference: user.stylePreference,
        profileImage: user.profileImage,
      },
    });
  } catch (error) {
    console.error('Social Login Error:', error);
    return res.status(500).json({ error: 'Social login failed.' });
  }
};

/**
 * GET /api/auth/me
 */
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-passwordHash');
    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }
    return res.status(200).json({ user });
  } catch (error) {
    console.error('GetMe Error:', error);
    return res.status(500).json({ error: 'Failed to get user profile.' });
  }
};
