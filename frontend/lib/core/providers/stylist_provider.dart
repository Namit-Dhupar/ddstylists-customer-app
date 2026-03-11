import 'package:flutter_riverpod/flutter_riverpod.dart';

class Stylist {
  final String id;
  final String firstName;
  final String lastName;
  final List<String> speciality;
  final String profileImage;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final String location;
  final String bio;
  final List<StylistService> services;

  Stylist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.profileImage,
    required this.rating,
    this.reviewCount = 0,
    this.experienceYears = 0,
    this.location = '',
    this.bio = '',
    this.services = const [],
  });

  String get fullName => '$firstName $lastName';
}

class StylistService {
  final String name;
  final double price;
  final String packageType;

  StylistService({required this.name, required this.price, required this.packageType});
}

class StylistsNotifier extends StateNotifier<AsyncValue<List<Stylist>>> {
  StylistsNotifier() : super(const AsyncValue.loading()) {
    _fetchStylists();
  }

  Future<void> _fetchStylists() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final stylists = [
        Stylist(
          id: 's1', firstName: 'Jenny', lastName: 'Wilson',
          speciality: ['Wedding', 'Wardrobe'],
          profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
          rating: 4.8, reviewCount: 127, experienceYears: 5, location: 'London',
          bio: 'Specializing in wedding and bridal styling with 5+ years of experience.',
          services: [
            StylistService(name: 'Wedding/per hour', price: 75, packageType: 'Custom'),
            StylistService(name: 'Bridal Package', price: 250, packageType: 'Signature'),
          ],
        ),
        Stylist(
          id: 's2', firstName: 'Olivia', lastName: 'Brown',
          speciality: ['Wedding', 'Wardrobe'],
          profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
          rating: 4.8, reviewCount: 98, experienceYears: 7, location: 'Manchester',
          bio: 'Creative stylist passionate about unique wedding looks.',
          services: [
            StylistService(name: 'Style Session', price: 60, packageType: 'Custom'),
          ],
        ),
        Stylist(
          id: 's3', firstName: 'Emily', lastName: 'Carter',
          speciality: ['Wedding', 'Corporate'],
          profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
          rating: 4.7, reviewCount: 85, experienceYears: 5, location: 'London',
          bio: 'Fashion-forward stylist blending classic elegance with modern trends.',
          services: [
            StylistService(name: 'Wedding/per hour', price: 75, packageType: 'Custom'),
            StylistService(name: 'Corporate Package', price: 120, packageType: 'Signature'),
          ],
        ),
        Stylist(
          id: 's4', firstName: 'Edward', lastName: 'Evans',
          speciality: ['Wedding', 'Wardrobe'],
          profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
          rating: 4.6, reviewCount: 65, experienceYears: 4, location: 'Birmingham',
          bio: 'Menswear specialist with an eye for detail.',
          services: [
            StylistService(name: 'Styling Session', price: 55, packageType: 'Custom'),
          ],
        ),
        Stylist(
          id: 's5', firstName: 'Cody', lastName: 'Fisher',
          speciality: ['Casual', 'Wardrobe'],
          profileImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
          rating: 4.5, reviewCount: 42, experienceYears: 3, location: 'Leeds',
          bio: 'Casual and streetwear styling expert.',
          services: [
            StylistService(name: 'Style Session', price: 45, packageType: 'Custom'),
          ],
        ),
        Stylist(
          id: 's6', firstName: 'Charlotte', lastName: 'May',
          speciality: ['Corporate', 'Wardrobe'],
          profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
          rating: 4.9, reviewCount: 152, experienceYears: 8, location: 'London',
          bio: 'Corporate image consultant for executives.',
          services: [
            StylistService(name: 'Corporate Package', price: 150, packageType: 'Signature'),
          ],
        ),
        Stylist(
          id: 's7', firstName: 'Sergei', lastName: 'Babcock',
          speciality: ['Wedding', 'Casual'],
          profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
          rating: 4.4, reviewCount: 38, experienceYears: 2, location: 'Bristol',
          bio: 'Young and creative stylist building unique looks.',
          services: [
            StylistService(name: 'Style Session', price: 40, packageType: 'Custom'),
          ],
        ),
        Stylist(
          id: 's8', firstName: 'Victoria', lastName: 'Foster',
          speciality: ['Wedding', 'Corporate'],
          profileImage: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400',
          rating: 4.7, reviewCount: 91, experienceYears: 6, location: 'Edinburgh',
          bio: 'Versatile stylist for weddings and professional settings.',
          services: [
            StylistService(name: 'Full Day Package', price: 300, packageType: 'Signature'),
          ],
        ),
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

final stylistCategoriesProvider = Provider<List<String>>((ref) {
  return ['All', 'Wedding', 'Corporate', 'Casual', 'Wardrobe'];
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredStylistsProvider = Provider<AsyncValue<List<Stylist>>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final stylistsState = ref.watch(stylistsProvider);

  return stylistsState.whenData((stylists) {
    if (category == 'All') return stylists;
    return stylists.where((s) => s.speciality.contains(category)).toList();
  });
});
