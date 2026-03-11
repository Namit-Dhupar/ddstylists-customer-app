import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String? profileImage;
  final String stylePreference;
  final String country;
  final int itemCount;
  final int outfitCount;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.phone = '',
    this.profileImage,
    this.stylePreference = 'Both',
    this.country = 'United Kingdom',
    this.itemCount = 0,
    this.outfitCount = 0,
  });
}

class AuthNotifier extends StateNotifier<UserProfile?> {
  AuthNotifier() : super(null);

  bool get isLoggedIn => state != null;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = UserProfile(
      id: 'u1',
      firstName: 'Vishnu',
      lastName: 'Sidharth',
      username: 'vishnu7',
      email: email,
      phone: '+44 7911 123456',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      stylePreference: 'Both',
      country: 'United Kingdom',
      itemCount: 12,
      outfitCount: 5,
    );
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String stylePreference = 'Both',
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = UserProfile(
      id: 'u_new',
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      stylePreference: stylePreference,
    );
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier();
});
