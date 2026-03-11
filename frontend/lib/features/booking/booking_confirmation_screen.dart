import 'package:flutter/material.dart';
import '../../core/widgets/molecules/payment_summary_card.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String stylistName;
  final String serviceName;
  final String date;
  final String time;
  final double amount;
  final String currency;
  final String region; // 'IN' or 'UK'

  const BookingConfirmationScreen({
    super.key,
    required this.stylistName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.amount,
    required this.currency,
    required this.region,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    try {
      // Mock API call to our backend /api/checkout/process
      // The backend returns either a Stripe ClientSecret or Razorpay OrderId
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      
      final gateway = widget.region == 'IN' ? 'Razorpay' : 'Stripe';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment processed successfully via \$gateway!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to Success Screen
      // context.go('/booking-success');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Confirm Booking', style: TextStyle(color: Color(0xFFD4AF35))),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaymentSummaryCard(
              serviceName: widget.serviceName,
              date: widget.date,
              time: widget.time,
              stylistName: widget.stylistName,
              amount: widget.amount,
              currency: widget.currency,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.region == 'IN'
                          ? 'You will be redirected to Razorpay securely.'
                          : 'You will be redirected to Stripe securely.',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF35),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[800],
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
