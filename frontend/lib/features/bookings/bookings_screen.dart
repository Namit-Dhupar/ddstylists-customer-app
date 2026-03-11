import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/booking_provider.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedBookingTabProvider);
    final bookings = ref.watch(filteredBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Appointments', style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gold,
                fontStyle: FontStyle.italic,
              )),
            ),
            const SizedBox(height: 20),
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['Upcoming', 'Completed', 'Cancelled'].map((tab) {
                  final isSelected = tab == selectedTab;
                  return GestureDetector(
                    onTap: () => ref.read(selectedBookingTabProvider.notifier).state = tab,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cardDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.gold : Colors.transparent),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? AppColors.gold : AppColors.greyLight,
                          fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, color: AppColors.greyDark, size: 64),
                        const SizedBox(height: 16),
                        const Text('No Appointments', style: TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 8),
                        const Text('Explore Stylists and make\nyour first appointment',
                          style: TextStyle(color: AppColors.greyLight, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _BookingCard(booking: bookings[index]);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(booking.stylistImage, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.cardDark),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.stylistName, style: GoogleFonts.playfairDisplay(
                    fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(booking.service, style: const TextStyle(color: AppColors.goldLight, fontSize: 13)),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, color: AppColors.greyLight, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${_dayName(booking.date)}, ${booking.date.day} ${_monthName(booking.date)}, ${booking.time}',
                        style: const TextStyle(color: AppColors.greyLight, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(DateTime d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
  String _monthName(DateTime d) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}
