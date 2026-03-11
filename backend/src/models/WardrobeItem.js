const mongoose = require('mongoose');

const wardrobeItemSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true
  },
  category: { 
    type: String, 
    required: true,
    enum: ['Top Wear', 'Bottom Wear', 'Outfits', 'Accessories', 'Footwear']
  },
  name: { type: String, required: true },
  imageUrl: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('WardrobeItem', wardrobeItemSchema);
