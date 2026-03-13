import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../network/api_config.dart';

/// Booking model
class Booking {
  final String id;
  final String stylistId;
  final String stylistName;
  final String stylistImage;
  final String stylistSpeciality;
  final String date;
  final String time;
  final String status;
  final String packageType;
  final String paymentStatus;

  Booking({
    required this.id,
    required this.stylistId,
    required this.stylistName,
    required this.stylistImage,
    required this.stylistSpeciality,
    required this.date,
    required this.time,
    required this.status,
    required this.packageType,
    required this.paymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final stylist = json['stylistId'];
    String stylistName = 'Stylist';
    String stylistImage = '';
    String stylistSpec = '';
    
    if (stylist is Map<String, dynamic>) {
      stylistName = '${stylist['firstName'] ?? ''} ${stylist['lastName'] ?? ''}'.trim();
      stylistImage = stylist['profileImage'] ?? '';
      final specs = stylist['speciality'] as List?;
      stylistSpec = specs?.isNotEmpty == true ? specs!.first : '';
    }

    String formattedDate = json['date'] ?? '';
    try {
      final dt = DateTime.parse(formattedDate);
      formattedDate = DateFormat('EEE, d MMM yyyy').format(dt);
    } catch (_) {}

    return Booking(
      id: json['_id'] ?? '',
      stylistId: stylist is Map ? (stylist['_id'] ?? '') : (stylist?.toString() ?? ''),
      stylistName: stylistName,
      stylistImage: stylistImage,
      stylistSpeciality: stylistSpec,
      date: formattedDate,
      time: json['time'] ?? '',
      status: json['status'] ?? 'Upcoming',
      packageType: json['packageType'] ?? 'Custom',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
    );
  }
}

/// Selected booking tab
final bookingTabProvider = StateProvider<String>((ref) => 'Upcoming');

/// Fetch bookings from backend
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final status = ref.watch(bookingTabProvider);
  try {
    final dio = ApiConfig.createDio();
    final response = await dio.get('/appointments', queryParameters: {'status': status});
    final List<dynamic> data = response.data['appointments'] ?? [];
    return data.map((json) => Booking.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

/// Actions provider
final bookingActionProvider = Provider((ref) => BookingActions(ref));

class BookingActions {
  final Ref ref;
  BookingActions(this.ref);

  Future<bool> createAppointment({
    required String stylistId,
    required String date,
    required String time,
    String packageType = 'Custom',
  }) async {
    try {
      final dio = ApiConfig.createDio();
      await dio.post('/appointments', data: {
        'stylistId': stylistId,
        'date': date,
        'time': time,
        'packageType': packageType,
      });
      ref.invalidate(bookingsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final dio = ApiConfig.createDio();
      await dio.put('/appointments/$appointmentId/cancel');
      ref.invalidate(bookingsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

