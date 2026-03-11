import 'package:flutter_riverpod/flutter_riverpod.dart';

class Stylist {
  final String id;
  final String firstName;
  final String lastName;
  final String speciality;
  final String profileImage;
  final double rating;

  Stylist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.profileImage,
    required this.rating,
  });
}

class StylistsNotifier extends StateNotifier<AsyncValue<List<Stylist>>> {
  StylistsNotifier() : super(const AsyncValue.loading()) {
    _fetchStylists();
  }

  Future<void> _fetchStylists() async {
    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      final stylists = [
        Stylist(id: 's1', firstName: 'Emma', lastName: 'Stone', speciality: 'Wedding', profileImage: 'https://via.placeholder.com/150', rating: 4.8),
        Stylist(id: 's2', firstName: 'John', lastName: 'Doe', speciality: 'Corporate', profileImage: 'https://via.placeholder.com/150', rating: 4.5),
      ];
      state = AsyncValue.data(stylists);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final stylistsProvider = StateNotifierProvider<StylistsNotifier, AsyncValue<List<Stylist>>>((ref) {
  return StylistsNotifier();
});
