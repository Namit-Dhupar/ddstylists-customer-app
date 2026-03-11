const Appointment = require('../models/Appointment');
const Stylist = require('../models/Stylist');

/**
 * POST /api/appointments
 */
exports.createAppointment = async (req, res) => {
  try {
    const { stylistId, date, time, packageType, wardrobeAccess } = req.body;

    if (!stylistId || !date || !time) {
      return res.status(400).json({ error: 'stylistId, date, and time are required.' });
    }

    const stylist = await Stylist.findById(stylistId);
    if (!stylist) return res.status(404).json({ error: 'Stylist not found.' });

    const appointment = await Appointment.create({
      customerId: req.user.id,
      stylistId,
      date: new Date(date),
      time,
      status: 'Upcoming',
      packageType: packageType || 'Custom',
      wardrobeAccess: wardrobeAccess || 'None',
      paymentStatus: 'Pending',
    });

    // Increment stylist session count
    await Stylist.findByIdAndUpdate(stylistId, { $inc: { sessionCount: 1 } });

    return res.status(201).json({ message: 'Appointment created', appointment });
  } catch (error) {
    console.error('CreateAppointment Error:', error);
    return res.status(500).json({ error: 'Failed to create appointment.' });
  }
};

/**
 * GET /api/appointments
 * Query: status (Upcoming, Completed, Cancelled)
 */
exports.listAppointments = async (req, res) => {
  try {
    const { status } = req.query;
    const filter = { customerId: req.user.id };
    if (status) filter.status = status;

    const appointments = await Appointment.find(filter)
      .populate('stylistId', 'firstName lastName profileImage speciality')
      .sort({ date: -1 });

    return res.status(200).json({ appointments });
  } catch (error) {
    console.error('ListAppointments Error:', error);
    return res.status(500).json({ error: 'Failed to fetch appointments.' });
  }
};

/**
 * GET /api/appointments/:id
 */
exports.getAppointment = async (req, res) => {
  try {
    const appointment = await Appointment.findOne({ _id: req.params.id, customerId: req.user.id })
      .populate('stylistId', 'firstName lastName profileImage speciality location services');
    if (!appointment) return res.status(404).json({ error: 'Appointment not found.' });
    return res.status(200).json({ appointment });
  } catch (error) {
    console.error('GetAppointment Error:', error);
    return res.status(500).json({ error: 'Failed to fetch appointment.' });
  }
};

/**
 * PUT /api/appointments/:id/cancel
 */
exports.cancelAppointment = async (req, res) => {
  try {
    const appointment = await Appointment.findOne({ _id: req.params.id, customerId: req.user.id });
    if (!appointment) return res.status(404).json({ error: 'Appointment not found.' });
    if (appointment.status !== 'Upcoming') {
      return res.status(400).json({ error: 'Only upcoming appointments can be cancelled.' });
    }

    appointment.status = 'Cancelled';
    await appointment.save();

    return res.status(200).json({ message: 'Appointment cancelled', appointment });
  } catch (error) {
    console.error('CancelAppointment Error:', error);
    return res.status(500).json({ error: 'Failed to cancel appointment.' });
  }
};
