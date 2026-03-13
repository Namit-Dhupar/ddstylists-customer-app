import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_config.dart';
import 'stylist_provider.dart';

/// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth provider — connects to live backend
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthState()) {
    checkAuth();
  }

  final _dio = ApiConfig.createDio();

  void _syncFavs(Map<String, dynamic>? data) {
    if (data == null) return;
    final List<String> favs = [];
    if (data['favouriteStylists'] != null) {
      favs.addAll((data['favouriteStylists'] as List).map((e) {
        if (e is Map) return e['_id'].toString();
        return e.toString();
      }));
    }
    ref.read(favouriteStylistsProvider.notifier).setInitial(favs);
  }

  Future<void> checkAuth() async {
    final token = await ApiConfig.getToken();
    if (token != null) {
      try {
        final response = await _dio.get('/auth/me');
        final user = response.data['user'] as Map<String, dynamic>;
        _syncFavs(user);
        state = AuthState(
          isAuthenticated: true,
          user: user,
        );
      } catch (_) {
        await ApiConfig.clearToken();
        state = const AuthState();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data;
      await ApiConfig.saveToken(data['token']);
      final user = data['user'] as Map<String, dynamic>;
      _syncFavs(user);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? phone,
    String? dob,
    String? stylePreference,
    String? country,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (dob != null) 'dob': dob,
        if (stylePreference != null) 'stylePreference': stylePreference,
        if (country != null) 'country': country,
      });
      final data = response.data;
      await ApiConfig.saveToken(data['token']);
      final user = data['user'] as Map<String, dynamic>;
      _syncFavs(user);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> socialLogin({
    required String provider,
    required String email,
    String? firstName,
    String? lastName,
    String? profileImage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/social', data: {
        'provider': provider,
        'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (profileImage != null) 'profileImage': profileImage,
      });
      final data = response.data;
      await ApiConfig.saveToken(data['token']);
      final user = data['user'] as Map<String, dynamic>;
      _syncFavs(user);
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
      return true;
    } catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<void> logout() async {
    await ApiConfig.clearToken();
    state = const AuthState();
  }

  String _extractError(dynamic e) {
    if (e is Exception) {
      try {
        final dioErr = e as dynamic;
        return dioErr.response?.data?['error']?.toString() ?? 'Something went wrong';
      } catch (_) {}
    }
    return 'Something went wrong';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

