import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Text('Create your account', style: GoogleFonts.playfairDisplay(
                fontSize: 18, color: AppColors.gold,
              )),
              const SizedBox(height: 24),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.cardDark,
                backgroundImage: user?.profileImage != null
                  ? NetworkImage(user!.profileImage!)
                  : null,
                child: user?.profileImage == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.greyMid)
                  : null,
              ),
              const SizedBox(height: 12),
              Text(
                user != null ? '${user.firstName} ${user.lastName}' : 'Guest',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                user != null ? '@${user.username}' : '',
                style: const TextStyle(color: AppColors.greyLight, fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat('Items', '${user?.itemCount ?? 0}'),
                    Container(width: 1, height: 30, color: AppColors.greyDark, margin: const EdgeInsets.symmetric(horizontal: 32)),
                    _stat('Outfit', '${user?.outfitCount ?? 0}'),
                  ],
                ),
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

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _settingsGroup(List<_SettingsItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: Icon(item.icon, color: AppColors.gold, size: 22),
                  title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.trailing != null)
                        Text(item.trailing!, style: const TextStyle(color: AppColors.greyMid, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: AppColors.greyMid, size: 20),
                    ],
                  ),
                  onTap: item.onTap,
                ),
                if (i < items.length - 1)
                  const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
              ],
            );
          }).toList(),
        ),
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
