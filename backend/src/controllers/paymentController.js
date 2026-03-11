// backend/src/controllers/paymentController.js

/**
 * Mocking Stripe and Razorpay SDKs for sandbox implementation
 */
const mockStripe = {
  paymentIntents: {
    create: async ({ amount, currency, payment_method_types }) => {
      // Return a mocked PaymentIntent object
      return {
        id: 'pi_mock_' + Math.floor(Math.random() * 1000000),
        amount,
        currency,
        client_secret: 'mock_client_secret_stripe_sandbox',
        status: 'requires_payment_method',
      };
    }
  }
};

const mockRazorpay = {
  orders: {
    create: async ({ amount, currency, receipt }) => {
      // Return a mocked Razorpay Order object
      return {
        id: 'order_mock_' + Math.floor(Math.random() * 1000000),
        amount,
        currency,
        receipt,
        status: 'created',
      };
    }
  }
};

/**
 * Process Checkout based on Region
 */
exports.processCheckout = async (req, res) => {
  try {
    const { amount, currency, region, appointmentId } = req.body;

    if (!amount || !currency || !region) {
      return res.status(400).json({ error: 'Missing required fields: amount, currency, or region.' });
    }

    let paymentResponse = {};

    if (region.toUpperCase() === 'IN') {
      // Route through Razorpay for India
      const orderOptions = {
        amount: amount * 100, // Amount in paise
        currency: 'INR',
        receipt: `receipt_${appointmentId || Date.now()}`,
      };
      
      const order = await mockRazorpay.orders.create(orderOptions);
      paymentResponse = {
        gateway: 'Razorpay',
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        status: order.status,
        key: 'rzp_test_placeholder_key' // placeholder key for frontend
      };
    } else if (region.toUpperCase() === 'UK' || region.toUpperCase() === 'GB') {
      // Route through Stripe for UK / Others
      const intentOptions = {
        amount: amount * 100, // Amount in pence
        currency: 'GBP',
        payment_method_types: ['card'],
      };

      const intent = await mockStripe.paymentIntents.create(intentOptions);
      paymentResponse = {
        gateway: 'Stripe',
        paymentIntentId: intent.id,
        clientSecret: intent.client_secret,
        amount: intent.amount,
        currency: intent.currency,
        status: intent.status,
        publishableKey: 'pk_test_placeholder_key' // placeholder key for frontend
      };
    } else {
      return res.status(400).json({ error: 'Unsupported region for payment routing. Only IN or UK are supported currently.' });
    }

    return res.status(200).json({
      message: 'Checkout session created successfully',
      data: paymentResponse
    });

  } catch (error) {
    console.error('Payment Processing Error:', error);
    res.status(500).json({ error: 'Failed to process payment session' });
  }
};
