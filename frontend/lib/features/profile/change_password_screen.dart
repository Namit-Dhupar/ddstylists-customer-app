import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/network/api_config.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _changePassword() async {
    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _error = 'New passwords do not match');
      return;
    }

    if (newPass.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ApiConfig.createDio();
      await dio.put('/auth/change-password', data: {
        'currentPassword': currentPass,
        'newPassword': newPass,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to change password';
        if (e is DioException && e.response?.data != null) {
          msg = e.response?.data['message'] ?? msg;
        }
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: GoogleFonts.playfairDisplay(
                fontSize: 32, color: AppColors.gold, fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              const Text('Update your account password', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
              const SizedBox(height: 32),
              
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildPasswordField('Current Password', _currentPasswordController, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
              const SizedBox(height: 20),
              _buildPasswordField('New Password', _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 20),
              _buildPasswordField('Confirm New Password', _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                    : const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.greyMid),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
