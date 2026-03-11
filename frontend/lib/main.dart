import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/home/home_screen.dart';
import 'features/wardrobe/wardrobe_screen.dart';
import 'features/stylists/stylist_discovery_screen.dart';
import 'features/bookings/bookings_screen.dart';
import 'features/chat/conversations_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D&D Stylists',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}

// App-level navigation state
enum AppScreen { splash, onboarding, login, signup, main }

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  AppScreen _currentScreen = AppScreen.splash;

  void _navigateTo(AppScreen screen) {
    setState(() => _currentScreen = screen);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for logout
    ref.listen<UserProfile?>(authProvider, (prev, next) {
      if (prev != null && next == null) {
        _navigateTo(AppScreen.onboarding);
      }
    });

    switch (_currentScreen) {
      case AppScreen.splash:
        return SplashScreen(
          onFinished: () => _navigateTo(AppScreen.onboarding),
        );
      case AppScreen.onboarding:
        return OnboardingScreen(
          onSignIn: () => _navigateTo(AppScreen.login),
          onSignUp: () => _navigateTo(AppScreen.signup),
        );
      case AppScreen.login:
        return LoginScreen(
          onLoginSuccess: () => _navigateTo(AppScreen.main),
          onSignUpTap: () => _navigateTo(AppScreen.signup),
        );
      case AppScreen.signup:
        return SignupScreen(
          onSignUpSuccess: () => _navigateTo(AppScreen.main),
          onSignInTap: () => _navigateTo(AppScreen.login),
        );
      case AppScreen.main:
        return const MainScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Start on Home

  void _onTabChange(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const WardrobeScreen(),
      const StylistDiscoveryScreen(),
      HomeScreen(onNavigate: _onTabChange),
      const ConversationsScreen(),
      const BookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.checkroom_outlined, 'Wardrobe'),
                _navItem(1, Icons.explore_outlined, 'Explore'),
                _navItemCenter(2),
                _navItem(3, Icons.chat_bubble_outline, 'Chat'),
                _navItem(4, Icons.calendar_today_outlined, 'Bookings'),
                _navItem(5, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabChange(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.gold : AppColors.greyMid, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: isSelected ? AppColors.gold : AppColors.greyMid,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  Widget _navItemCenter(int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabChange(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : AppColors.greyDark,
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 12, spreadRadius: 2),
          ] : [],
        ),
        child: Icon(
          Icons.home_rounded,
          color: isSelected ? AppColors.black : AppColors.greyMid,
          size: 26,
        ),
      ),
    );
  }
}
