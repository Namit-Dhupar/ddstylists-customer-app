import 'package:flutter_riverpod/flutter_riverpod.dart';

class Booking {
  final String id;
  final String stylistId;
  final String stylistName;
  final String stylistImage;
  final String service;
  final DateTime date;
  final String time;
  final String status; // Upcoming, Completed, Cancelled
  final double price;

  Booking({
    required this.id,
    required this.stylistId,
    required this.stylistName,
    required this.stylistImage,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
  });
}

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]) {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    state = [
      Booking(
        id: 'b1', stylistId: 's3', stylistName: 'Emily Carter',
        stylistImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        service: 'Wedding', date: DateTime(2025, 3, 22), time: '11:00 am',
        status: 'Upcoming', price: 75,
      ),
      Booking(
        id: 'b2', stylistId: 's1', stylistName: 'Jenny Wilson',
        stylistImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        service: 'Bridal Package', date: DateTime(2025, 2, 15), time: '2:00 pm',
        status: 'Completed', price: 250,
      ),
      Booking(
        id: 'b3', stylistId: 's6', stylistName: 'Charlotte May',
        stylistImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        service: 'Corporate Package', date: DateTime(2025, 1, 10), time: '10:00 am',
        status: 'Cancelled', price: 150,
      ),
    ];
  }

  void addBooking(Booking booking) {
    state = [booking, ...state];
  }

  void cancelBooking(String id) {
    state = state.map((b) {
      if (b.id == id) {
        return Booking(
          id: b.id, stylistId: b.stylistId, stylistName: b.stylistName,
          stylistImage: b.stylistImage, service: b.service,
          date: b.date, time: b.time, status: 'Cancelled', price: b.price,
        );
      }
      return b;
    }).toList();
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  return BookingsNotifier();
});

final selectedBookingTabProvider = StateProvider<String>((ref) => 'Upcoming');

final filteredBookingsProvider = Provider<List<Booking>>((ref) {
  final tab = ref.watch(selectedBookingTabProvider);
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == tab).toList();
});
