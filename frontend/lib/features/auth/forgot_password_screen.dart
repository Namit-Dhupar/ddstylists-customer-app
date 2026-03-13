import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/network/api_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  int _loadingSeconds = 0;

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _startLoadingTimer() {
    _loadingSeconds = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_loading || !mounted) return false;
      setState(() => _loadingSeconds++);
      return _loading && mounted;
    });
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _loading = true);
    _startLoadingTimer();
    try {
      final dio = ApiConfig.createDio();
      await dio.post('/auth/forgot-password', data: {'email': email});
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset link. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Reset Password', style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppColors.gold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text('Forgot your password?', style: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
        )),
        const SizedBox(height: 12),
        const Text(
          'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
          style: TextStyle(color: AppColors.greyLight, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        const Text('Email Address', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'yourname@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.greyMid),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _sendResetLink,
            child: _loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black)),
                    if (_loadingSeconds >= 5) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Server is waking up, please wait...',
                        style: TextStyle(color: AppColors.black.withOpacity(0.7), fontSize: 10),
                      ),
                    ],
                  ],
                )
              : const Text('Send Reset Link'),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Sign In', style: TextStyle(color: AppColors.gold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withOpacity(0.1),
            border: Border.all(color: AppColors.gold, width: 2),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.gold, size: 40),
        ),
        const SizedBox(height: 24),
        Text('Check your email', style: GoogleFonts.playfairDisplay(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
        )),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text.trim()}',
          style: const TextStyle(color: AppColors.greyLight, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Sign In'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() => _sent = false);
          },
          child: const Text("Didn't receive the email? Resend", style: TextStyle(color: AppColors.gold)),
        ),
      ],
    );
  }
}
