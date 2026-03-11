import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });
}

class AuthNotifier extends StateNotifier<UserProfile?> {
  AuthNotifier() : super(null) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Mock user session
    await Future.delayed(const Duration(milliseconds: 500));
    state = UserProfile(id: 'u1', firstName: 'Jane', lastName: 'Customer', email: 'jane@example.com', phone: '1234567890');
  }

  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier();
});
