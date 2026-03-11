import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final username = user?['username'] ?? 'guest';
    final profileImage = user?['profileImage'] as String?;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('My Profile', style: GoogleFonts.playfairDisplay(
                fontSize: 18, color: AppColors.gold,
              )),
              const SizedBox(height: 24),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.cardDark,
                backgroundImage: profileImage != null && profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : null,
                child: profileImage == null || profileImage.isEmpty
                  ? const Icon(Icons.person, size: 40, color: AppColors.greyMid)
                  : null,
              ),
              const SizedBox(height: 12),
              Text(
                '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName' : 'Guest',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                '@$username',
                style: const TextStyle(color: AppColors.greyLight, fontSize: 14),
              ),
              const SizedBox(height: 32),
              // Settings list
              _settingsGroup([
                _SettingsItem(icon: Icons.lock_outline, title: 'Change Password', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change password coming soon')));
                }),
                _SettingsItem(icon: Icons.language, title: 'Language', trailing: 'English', onTap: () {}),
                _SettingsItem(icon: Icons.support_agent, title: 'Contact Us', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact support coming soon')));
                }),
              ]),
              const SizedBox(height: 16),
              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _settingsGroup(List<_SettingsItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: Icon(item.icon, color: AppColors.gold, size: 22),
            title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15)),
            trailing: item.trailing != null
              ? Text(item.trailing!, style: const TextStyle(color: AppColors.greyMid, fontSize: 14))
              : const Icon(Icons.chevron_right, color: AppColors.greyMid, size: 20),
            onTap: item.onTap,
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  _SettingsItem({required this.icon, required this.title, this.trailing, required this.onTap});
}
