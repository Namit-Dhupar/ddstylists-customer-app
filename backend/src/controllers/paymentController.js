/**
 * Payment Controller — Stripe (UK) + Razorpay (India)
 * Falls back to mock if SDK keys are not configured.
 */

let stripe, razorpay;

// Initialize Stripe
if (process.env.STRIPE_SECRET_KEY && !process.env.STRIPE_SECRET_KEY.startsWith('your_')) {
  const Stripe = require('stripe');
  stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
}

// Initialize Razorpay
if (process.env.RAZORPAY_KEY_ID && !process.env.RAZORPAY_KEY_ID.startsWith('your_')) {
  const Razorpay = require('razorpay');
  razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
}

/**
 * POST /api/checkout/process
 * Region-based payment routing
 */
exports.processCheckout = async (req, res) => {
  try {
    const { amount, currency, region, appointmentId } = req.body;

    if (!amount || !region) {
      return res.status(400).json({ error: 'amount and region are required.' });
    }

    let paymentResponse = {};

    if (region.toUpperCase() === 'IN') {
      // Razorpay for India
      const orderOptions = {
        amount: Math.round(amount * 100), // paise
        currency: currency || 'INR',
        receipt: `receipt_${appointmentId || Date.now()}`,
      };

      if (razorpay) {
        const order = await razorpay.orders.create(orderOptions);
        paymentResponse = {
          gateway: 'Razorpay',
          orderId: order.id,
          amount: order.amount,
          currency: order.currency,
          status: order.status,
          key: process.env.RAZORPAY_KEY_ID,
        };
      } else {
        // Mock mode
        paymentResponse = {
          gateway: 'Razorpay',
          orderId: 'order_mock_' + Date.now(),
          amount: orderOptions.amount,
          currency: orderOptions.currency,
          status: 'created',
          key: 'rzp_test_placeholder',
          mock: true,
        };
      }
    } else if (['UK', 'GB', 'US'].includes(region.toUpperCase())) {
      // Stripe for UK / US / Others
      const intentOptions = {
        amount: Math.round(amount * 100), // pence/cents
        currency: currency || 'GBP',
        payment_method_types: ['card'],
        metadata: { appointmentId: appointmentId || '' },
      };

      if (stripe) {
        const intent = await stripe.paymentIntents.create(intentOptions);
        paymentResponse = {
          gateway: 'Stripe',
          paymentIntentId: intent.id,
          clientSecret: intent.client_secret,
          amount: intent.amount,
          currency: intent.currency,
          status: intent.status,
          publishableKey: process.env.STRIPE_PUBLISHABLE_KEY || '',
        };
      } else {
        // Mock mode
        paymentResponse = {
          gateway: 'Stripe',
          paymentIntentId: 'pi_mock_' + Date.now(),
          clientSecret: 'mock_secret_' + Date.now(),
          amount: intentOptions.amount,
          currency: intentOptions.currency,
          status: 'requires_payment_method',
          publishableKey: 'pk_test_placeholder',
          mock: true,
        };
      }
    } else {
      return res.status(400).json({ error: 'Unsupported region. Only IN, UK, GB, US are supported.' });
    }

    return res.status(200).json({
      message: 'Checkout session created',
      data: paymentResponse,
    });
  } catch (error) {
    console.error('Payment Error:', error);
    return res.status(500).json({ error: 'Payment processing failed.' });
  }
};

/**
 * POST /api/checkout/verify
 * Verify Razorpay payment signature
 */
exports.verifyPayment = async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
    const crypto = require('crypto');

    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || '')
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (expectedSignature === razorpay_signature) {
      // Update appointment payment status
      const Appointment = require('../models/Appointment');
      await Appointment.findOneAndUpdate(
        { transactionId: razorpay_order_id },
        { paymentStatus: 'Completed', transactionId: razorpay_payment_id }
      );
      return res.status(200).json({ message: 'Payment verified', verified: true });
    } else {
      return res.status(400).json({ message: 'Payment verification failed', verified: false });
    }
  } catch (error) {
    console.error('Verify Error:', error);
    return res.status(500).json({ error: 'Verification failed.' });
  }
};

/**
 * POST /api/checkout/webhook
 * Stripe webhook
 */
exports.stripeWebhook = async (req, res) => {
  try {
    const sig = req.headers['stripe-signature'];
    let event;

    if (stripe && process.env.STRIPE_WEBHOOK_SECRET) {
      event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    } else {
      // Mock mode: parse body directly
      event = req.body;
    }

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data?.object;
      const Appointment = require('../models/Appointment');
      await Appointment.findOneAndUpdate(
        { transactionId: paymentIntent?.id },
        { paymentStatus: 'Completed' }
      );
    }

    return res.status(200).json({ received: true });
  } catch (error) {
    console.error('Webhook Error:', error);
    return res.status(400).json({ error: 'Webhook failed.' });
  }
};
