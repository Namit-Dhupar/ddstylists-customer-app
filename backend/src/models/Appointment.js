const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
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
  date: { type: Date, required: true },
  time: { type: String, required: true },
  status: { 
    type: String, 
    enum: ['Upcoming', 'Completed', 'Cancelled'],
    default: 'Upcoming'
  },
  packageType: { type: String, enum: ['Custom', 'Signature'] },
  paymentStatus: { 
    type: String, 
    enum: ['Pending', 'Completed', 'Refunded'],
    default: 'Pending'
  },
  transactionId: { type: String },
  meetingLink: { type: String },
  wardrobeAccess: { 
    type: String, 
    enum: ['Full', 'Limited', 'None'],
    default: 'None'
  }
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);
