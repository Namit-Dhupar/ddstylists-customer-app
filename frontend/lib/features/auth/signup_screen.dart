import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/network/api_config.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignUpSuccess;
  final VoidCallback onSignInTap;
  const SignupScreen({super.key, required this.onSignUpSuccess, required this.onSignInTap});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _pageController = PageController();
  int _step = 0;

  // Step 1 fields
  String _selectedCountry = '';
  String _selectedFlag = '';

  // Step 2 fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDob;
  String _stylePreference = 'Both';
  bool _loading = false;
  bool _obscurePassword = true;
  String? _usernameError;
  bool _checkingUsername = false;
  int _loadingSeconds = 0;

  void _nextStep() {
    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your country')),
      );
      return;
    }
    if (_step < 1) {
      setState(() => _step++);
      _pageController.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  Future<void> _checkUsername(String username) async {
    if (username.isEmpty) {
      setState(() => _usernameError = null);
      return;
    }
    setState(() => _checkingUsername = true);
    try {
      final dio = ApiConfig.createDio();
      final response = await dio.get('/auth/check-username', queryParameters: {'username': username});
      final available = response.data['available'] as bool;
      if (mounted) {
        setState(() {
          _usernameError = available ? null : 'Username is already taken';
          _checkingUsername = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _checkingUsername = false);
      }
    }
  }

  Future<void> _selectDob() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.gold, surface: AppColors.cardDark),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDob = date;
        _dobController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      });
    }
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

  Future<void> _completeSignUp() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty || _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    if (_usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a unique username')),
      );
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    setState(() => _loading = true);
    _startLoadingTimer();
    final success = await ref.read(authProvider.notifier).register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      stylePreference: _stylePreference,
      country: _selectedCountry,
      dob: _selectedDob?.toIso8601String(),
    );
    setState(() => _loading = false);
    if (success) {
      widget.onSignUpSuccess();
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) return; // User cancelled

      setState(() => _loading = true);
      _startLoadingTimer();

      final success = await ref.read(authProvider.notifier).socialLogin(
        provider: 'Google',
        email: account.email,
        firstName: account.displayName?.split(' ').first,
        lastName: account.displayName?.split(' ').skip(1).join(' '),
        profileImage: account.photoUrl,
      );

      setState(() => _loading = false);
      if (success) {
        widget.onSignUpSuccess();
      } else {
        if (mounted) {
          final error = ref.read(authProvider).error ?? 'Google sign-up failed';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-up failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          CustomPaint(size: MediaQuery.of(context).size, painter: _GeoBgPainter()),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (_step > 0) IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.gold),
                        onPressed: () {
                          setState(() => _step--);
                          _pageController.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                      const Spacer(),
                      Text(
                        _step == 0 ? '' : 'Create your account',
                        style: GoogleFonts.playfairDisplay(color: AppColors.gold, fontSize: 18),
                      ),
                      const Spacer(),
                      if (_step > 0) const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCountryStep(),
                      _buildProfileStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(),
          Text('D&D', style: GoogleFonts.playfairDisplay(
            fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.gold,
          )),
          const SizedBox(height: 8),
          Text('Where Style Meets Affordability', style: GoogleFonts.playfairDisplay(
            fontSize: 16, color: AppColors.greyLight, fontStyle: FontStyle.italic,
          )),
          const Spacer(),
          // Country selector
          GestureDetector(
            onTap: () async {
              final result = await _showCountryPicker(context);
              if (result != null) {
                setState(() {
                  _selectedCountry = result['name']!;
                  _selectedFlag = result['flag']!;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (_selectedFlag.isNotEmpty) ...[
                    Text(_selectedFlag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    _selectedCountry.isEmpty ? 'Select your country' : _selectedCountry,
                    style: TextStyle(
                      color: _selectedCountry.isEmpty ? AppColors.greyMid : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.greyMid),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text('Sign Up'),
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.greyDark)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: AppColors.greyMid, fontSize: 12)),
              ),
              Expanded(child: Divider(color: AppColors.greyDark)),
            ],
          ),
          const SizedBox(height: 16),
          // Google sign-up only
          GestureDetector(
            onTap: _loading ? null : _handleGoogleSignUp,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text('Sign Up with Google', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Have an account? ', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
              GestureDetector(
                onTap: widget.onSignInTap,
                child: const Text('Sign in', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Tell us who you are', style: GoogleFonts.playfairDisplay(
            fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
          )),
          const SizedBox(height: 8),
          const Text(
            'We customize your experience to fit your country, age, and fashion preferences.',
            style: TextStyle(color: AppColors.greyLight, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          _field('First name*', _firstNameController),
          const SizedBox(height: 16),
          _field('Last name*', _lastNameController),
          const SizedBox(height: 16),
          // Username with uniqueness check
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username*',
              errorText: _usernameError,
              suffixIcon: _checkingUsername
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
                  )
                : _usernameController.text.isNotEmpty && _usernameError == null
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : null,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Debounced check
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_usernameController.text == value) {
                    _checkUsername(value);
                  }
                });
              } else {
                setState(() => _usernameError = null);
              }
            },
          ),
          const SizedBox(height: 16),
          _field('Email*', _emailController, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          // Password with visibility toggle
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password*',
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.greyMid,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // DOB with date picker
          GestureDetector(
            onTap: _selectDob,
            child: AbsorbPointer(
              child: TextField(
                controller: _dobController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Date of Birth*',
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: const Icon(Icons.calendar_today, color: AppColors.gold, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Style preference', style: GoogleFonts.playfairDisplay(
            fontSize: 16, color: AppColors.gold, fontStyle: FontStyle.italic,
          )),
          const SizedBox(height: 12),
          Row(
            children: ['Womenswear', 'Menswear', 'Both'].map((pref) {
              final isSelected = _stylePreference == pref;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _stylePreference = pref),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.greyDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.gold : AppColors.cardBorder),
                    ),
                    child: Text(
                      pref,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isSelected ? AppColors.gold : AppColors.greyLight, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _completeSignUp,
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
                : const Text('Continue'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {String? hint, bool obscure = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Future<Map<String, String>?> _showCountryPicker(BuildContext context) async {
    final countries = [
      {'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'name': 'India', 'flag': '🇮🇳'},
    ];
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Select Your Country', style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppColors.gold)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('You can change the country & language in your profile settings anytime.',
                style: TextStyle(color: AppColors.greyLight, fontSize: 13), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ...countries.map((c) => ListTile(
              leading: Text(c['flag']!, style: const TextStyle(fontSize: 28)),
              title: Text(c['name']!, style: const TextStyle(color: Colors.white, fontSize: 16)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.greyMid, size: 18),
              onTap: () => Navigator.pop(ctx, c),
            )),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _GeoBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A).withOpacity(0.25)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const step = 80.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawLine(Offset(x, y), Offset(x + step, y + step), paint);
        canvas.drawLine(Offset(x + step, y), Offset(x, y + step), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
