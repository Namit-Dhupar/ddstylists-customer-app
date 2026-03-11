const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String },
  passwordHash: { type: String },
  dob: { type: Date },
  stylePreference: { 
    type: String, 
    enum: ['WomenWear', 'MenWear', 'Both'],
    default: 'Both'
  },
  profileImage: { type: String },
  authProvider: { 
    type: String, 
    enum: ['Local', 'Apple', 'Google', 'Facebook'],
    default: 'Local'
  },
  favouriteStylists: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Stylist' }]
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
