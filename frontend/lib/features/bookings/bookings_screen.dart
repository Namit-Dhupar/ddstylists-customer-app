import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/booking_provider.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(bookingTabProvider);
    final bookingsAsync = ref.watch(bookingsProvider);

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
                    onTap: () => ref.read(bookingTabProvider.notifier).state = tab,
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
              child: bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return Center(
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
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _BookingCard(booking: bookings[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            booking.stylistImage.isNotEmpty
                ? Image.network(booking.stylistImage, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.cardDark))
                : Container(color: AppColors.cardDark),
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
            if (booking.status == 'Cancelled')
              Positioned(
                top: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Cancelled', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(booking.packageType, style: const TextStyle(color: AppColors.goldLight, fontSize: 13)),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today, color: AppColors.greyLight, size: 12),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${booking.date}, ${booking.time}',
                                style: const TextStyle(color: AppColors.greyLight, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (booking.status == 'Upcoming')
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.cardDark,
                                title: const Text('Cancel Appointment?', style: TextStyle(color: Colors.white)),
                                content: const Text('Are you sure you want to cancel this appointment?', style: TextStyle(color: AppColors.greyLight)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('No', style: TextStyle(color: AppColors.greyMid)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            ).then((confirm) {
                              if (confirm == true) {
                                ref.read(bookingActionProvider).cancelAppointment(booking.id).then((success) {
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
                                  }
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
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
}
