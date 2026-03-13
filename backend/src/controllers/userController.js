const User = require('../models/User');

/**
 * GET /api/users/profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select('-passwordHash')
      .populate('favouriteStylists');
    if (!user) return res.status(404).json({ error: 'User not found.' });
    return res.status(200).json({ user });
  } catch (error) {
    console.error('GetProfile Error:', error);
    return res.status(500).json({ error: 'Failed to get profile.' });
  }
};

/**
 * PUT /api/users/profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const allowedFields = ['firstName', 'lastName', 'username', 'phone', 'dob', 'stylePreference', 'country'];
    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true, runValidators: true })
      .select('-passwordHash');
    return res.status(200).json({ message: 'Profile updated', user });
  } catch (error) {
    console.error('UpdateProfile Error:', error);
    return res.status(500).json({ error: 'Failed to update profile.' });
  }
};

/**
 * PUT /api/users/profile-image
 */
exports.updateProfileImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded.' });
    }
    // Store image as base64 data URI in MongoDB (persists across redeploys)
    const fs = require('fs');
    const fileBuffer = fs.readFileSync(req.file.path);
    const mimeType = req.file.mimetype || 'image/png';
    const base64 = fileBuffer.toString('base64');
    const imageUrl = `data:${mimeType};base64,${base64}`;

    // Clean up temp file
    if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);

    const user = await User.findByIdAndUpdate(req.user.id, { profileImage: imageUrl }, { new: true })
      .select('-passwordHash');
    return res.status(200).json({ message: 'Profile image updated', user });
  } catch (error) {
    console.error('UpdateProfileImage Error:', error);
    return res.status(500).json({ error: 'Failed to update profile image.' });
  }
};

/**
 * PUT /api/users/favourites/:stylistId
 */
exports.toggleFavourite = async (req, res) => {
  try {
    const { stylistId } = req.params;
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ error: 'User not found.' });

    const index = user.favouriteStylists.indexOf(stylistId);
    if (index > -1) {
      user.favouriteStylists.splice(index, 1);
    } else {
      user.favouriteStylists.push(stylistId);
    }
    await user.save();

    return res.status(200).json({
      message: index > -1 ? 'Removed from favourites' : 'Added to favourites',
      favouriteStylists: user.favouriteStylists,
    });
  } catch (error) {
    console.error('ToggleFavourite Error:', error);
    return res.status(500).json({ error: 'Failed to toggle favourite.' });
  }
};
