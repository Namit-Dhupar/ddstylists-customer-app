import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final String serviceName;
  final String date;
  final String time;
  final String stylistName;
  final double amount;
  final String currency;

  const PaymentSummaryCard({
    super.key,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.stylistName,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Booking Details',
            style: const TextStyle(
              color: Color(0xFFD4AF35),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRow('Stylist', stylistName),
          const SizedBox(height: 8),
          _buildRow('Service', serviceName),
          const SizedBox(height: 8),
          _buildRow('Date & Time', '\$date at \$time'),
          const Divider(color: Color(0xFF333333), height: 32),
          _buildRow('Total Amount', '\$currency \$amount', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFFD4AF35) : Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
