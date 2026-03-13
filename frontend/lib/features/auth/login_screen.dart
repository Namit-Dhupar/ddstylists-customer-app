import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSignUpTap;
  const LoginScreen({super.key, required this.onLoginSuccess, required this.onSignUpTap});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscure = true;
  bool _loading = false;
  int _loadingSeconds = 0;

  void _startLoadingTimer() {
    _loadingSeconds = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_loading || !mounted) return false;
      setState(() => _loadingSeconds++);
      return _loading && mounted;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Future<void> _doLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    setState(() => _loading = true);
    _startLoadingTimer();
    try {
      final success = await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        setState(() => _loading = false);
        if (success) {
          widget.onLoginSuccess();
        } else {
          final error = ref.read(authProvider).error ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) return;

      setState(() => _loading = true);
      _startLoadingTimer();

      final success = await ref.read(authProvider.notifier).socialLogin(
        provider: 'Google',
        email: account.email,
        firstName: account.displayName?.split(' ').first,
        lastName: account.displayName?.split(' ').skip(1).join(' '),
        profileImage: account.photoUrl,
      );

      if (mounted) {
        setState(() => _loading = false);
        if (success) {
          widget.onLoginSuccess();
        } else {
          final error = ref.read(authProvider).error ?? 'Google sign-in failed';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('D&D Portal', style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppColors.gold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header image area with gradient
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF3D2B00).withOpacity(0.6),
                        AppColors.black,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Enter the Realm', style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                      )),
                      const SizedBox(height: 8),
                      Text('Your adventure continues here', style: TextStyle(
                        fontSize: 14, color: AppColors.goldLight.withOpacity(0.7),
                      )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email Address', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(hintText: 'yourname@adventurer.com'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      const Text('Password', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.greyMid),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ));
                          },
                          child: const Text('Forgot Password?', style: TextStyle(color: AppColors.gold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _doLogin,
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
                            : const Text('LOGIN'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.greyDark)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR CONTINUE WITH', style: TextStyle(color: AppColors.greyMid, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: AppColors.greyDark)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Google sign-in only
                      GestureDetector(
                        onTap: _loading ? null : _handleGoogleSignIn,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                              SizedBox(width: 8),
                              Text('Sign in with Google', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
                          GestureDetector(
                            onTap: widget.onSignUpTap,
                            child: const Text('Sign up', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay that allows back navigation
          if (_loading && _loadingSeconds >= 5)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '⏳ Server contacted, waking up...',
                    style: TextStyle(color: AppColors.goldLight, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
