import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_config.dart';

/// Stylist model
class Stylist {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> speciality;
  final int experienceYears;
  final String location;
  final String bio;
  final String profileImage;
  final double rating;
  final int reviewCount;
  final int sessionCount;
  final List<StylistService> services;
  final bool isApproved;

  Stylist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.speciality,
    required this.experienceYears,
    required this.location,
    required this.bio,
    required this.profileImage,
    required this.rating,
    required this.reviewCount,
    required this.sessionCount,
    required this.services,
    required this.isApproved,
  });

  String get name => '$firstName $lastName';

  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      speciality: List<String>.from(json['speciality'] ?? []),
      experienceYears: json['experienceYears'] ?? 0,
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      profileImage: json['profileImage'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      sessionCount: json['sessionCount'] ?? 0,
      services: (json['services'] as List? ?? [])
          .map((s) => StylistService.fromJson(s))
          .toList(),
      isApproved: json['isApproved'] ?? false,
    );
  }
}

class StylistService {
  final String name;
  final double price;
  final String packageType;

  StylistService({required this.name, required this.price, required this.packageType});

  factory StylistService.fromJson(Map<String, dynamic> json) {
    return StylistService(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      packageType: json['packageType'] ?? 'Custom',
    );
  }
}

/// Selected category state
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Favourite stylists state
class FavouriteStylistsNotifier extends StateNotifier<Set<String>> {
  FavouriteStylistsNotifier() : super({});

  Future<void> toggle(String stylistId) async {
    try {
      final dio = ApiConfig.createDio();
      await dio.put('/users/favourites/$stylistId');
      if (state.contains(stylistId)) {
        state = {...state}..remove(stylistId);
      } else {
        state = {...state}..add(stylistId);
      }
    } catch (e) {
      // Ignore for now
    }
  }

  void setInitial(List<String> favourites) {
    state = favourites.toSet();
  }
}

final favouriteStylistsProvider = StateNotifierProvider<FavouriteStylistsNotifier, Set<String>>((ref) {
  return FavouriteStylistsNotifier();
});

/// Fetch categories from backend
final stylistCategoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final dio = ApiConfig.createDio();
    final response = await dio.get('/stylists/categories');
    return ['All', 'Favourites', ...List<String>.from(response.data['categories'] ?? [])];
  } catch (_) {
    return ['All', 'Favourites', 'Wedding', 'Corporate', 'Casual', 'Red Carpet', 'Maternity', 'Sustainable'];
  }
});

/// Fetch stylists from backend with category and search filter
final filteredStylistsProvider = FutureProvider<List<Stylist>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(searchQueryProvider);
  final favs = ref.watch(favouriteStylistsProvider);

  try {
    final dio = ApiConfig.createDio();
    final queryParams = <String, dynamic>{};
    if (category != 'All' && category != 'Favourites') queryParams['category'] = category;
    if (search.isNotEmpty) queryParams['search'] = search;

    final response = await dio.get('/stylists', queryParameters: queryParams);
    final List<dynamic> data = response.data['stylists'] ?? [];
    var stylists = data.map((json) => Stylist.fromJson(json)).toList();

    if (category == 'Favourites') {
      stylists = stylists.where((s) => favs.contains(s.id)).toList();
    }

    return stylists;
  } catch (_) {
    return [];
  }
});

/// Fetch single stylist detail
final stylistDetailProvider = FutureProvider.family<Stylist?, String>((ref, id) async {
  try {
    final dio = ApiConfig.createDio();
    final response = await dio.get('/stylists/$id');
    return Stylist.fromJson(response.data['stylist']);
  } catch (_) {
    return null;
  }
});

