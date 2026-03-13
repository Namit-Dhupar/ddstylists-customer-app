import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/network/api_config.dart';
import '../../core/widgets/smart_image.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourcePicker() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.greyDark, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Update Profile Photo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.gold),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _uploadProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.gold),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _uploadProfileImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadProfileImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final dio = ApiConfig.createDio();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path),
      });

      await dio.put('/users/profile-image', data: formData);
      
      // Refresh user data
      await ref.read(authProvider.notifier).checkAuth();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile image')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    final username = user?['username'] ?? 'guest';
    final rawProfileImage = user?['profileImage'] as String?;
    // Backend returns relative paths like /uploads/... — prepend server base URL
    final profileImage = (rawProfileImage != null && rawProfileImage.startsWith('/'))
        ? '${ApiConfig.serverBaseUrl}$rawProfileImage'
        : rawProfileImage;

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
              GestureDetector(
                onTap: _isUploading ? null : _showImageSourcePicker,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.cardDark,
                      backgroundImage: profileImage != null && profileImage.isNotEmpty
                        ? SmartImage.providerFor(profileImage)
                        : null,
                      child: profileImage == null || profileImage.isEmpty
                        ? const Icon(Icons.person, size: 40, color: AppColors.greyMid)
                        : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(color: AppColors.gold),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: AppColors.black, size: 16),
                      ),
                    ),
                  ],
                ),
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
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

  Widget _settingsGroup(List<_SettingsItem> items) {
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
