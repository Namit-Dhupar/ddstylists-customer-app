const mongoose = require('mongoose');

const stylistSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String },
  speciality: [{ type: String }],
  experienceYears: { type: Number, default: 0 },
  location: { type: String },
  bio: { type: String },
  profileImage: { type: String },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  sessionCount: { type: Number, default: 0 },
  services: [{
    name: { type: String },
    price: { type: Number },
    packageType: { type: String, enum: ['Custom', 'Signature'] }
  }],
  availability: [{
    dayOfWeek: { type: String, enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'] },
    startTime: { type: String },
    endTime: { type: String }
  }],
  isApproved: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Stylist', stylistSchema);
