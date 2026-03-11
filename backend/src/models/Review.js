const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  customerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true
  },
  stylistId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Stylist',
    required: true
  },
  rating: { type: Number, required: true, min: 1, max: 5 },
  reviewText: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Review', reviewSchema);
