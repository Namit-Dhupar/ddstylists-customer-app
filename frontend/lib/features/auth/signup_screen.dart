import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/auth_provider.dart';

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

  // Step 2 fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();
  String _stylePreference = 'Both';
  bool _loading = false;

  void _nextStep() {
    if (_step < 1) {
      setState(() => _step++);
      _pageController.animateToPage(_step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _completeSignUp() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).signUp(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: '${_usernameController.text.trim()}@ddstylists.com',
      password: 'demo123',
      stylePreference: _stylePreference,
    );
    setState(() => _loading = false);
    widget.onSignUpSuccess();
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
              final country = await _showCountryPicker(context);
              if (country != null) {
                setState(() => _selectedCountry = country);
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
          // Social login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.apple),
              const SizedBox(width: 16),
              _socialIcon(Icons.g_mobiledata_rounded),
              const SizedBox(width: 16),
              _socialIcon(Icons.facebook),
            ],
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
          _field('Username*', _usernameController),
          const SizedBox(height: 16),
          _field('Date of Birth*', _dobController, hint: 'DD/MM/YYYY'),
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
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                : const Text('Continue'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {String? hint}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardDark,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Future<String?> _showCountryPicker(BuildContext context) async {
    final countries = ['United Kingdom', 'United States', 'India', 'Australia', 'Canada', 'France', 'Germany', 'UAE', 'Singapore', 'Japan'];
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Column(
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
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(countries[i], style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.greyMid, size: 18),
                    onTap: () => Navigator.pop(ctx, countries[i]),
                  );
                },
              ),
            ),
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
