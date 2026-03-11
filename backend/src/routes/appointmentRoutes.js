const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointmentController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.post('/', appointmentController.createAppointment);
router.get('/', appointmentController.listAppointments);
router.get('/:id', appointmentController.getAppointment);
router.put('/:id/cancel', appointmentController.cancelAppointment);

module.exports = router;
