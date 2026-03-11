import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  const OnboardingScreen({super.key, required this.onSignIn, required this.onSignUp});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Personal Styling, Now Accessible',
      subtitle: 'Find The Perfect Stylist For Your Needs And Budget. Dressing Well Has Never Been This Easy!',
      images: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      ],
      names: ['Jenny Wilson', 'Olivia Brown'],
      specs: [['Wedding', 'Wardrobe'], ['Wedding', 'Wardrobe']],
      ratings: [4.8, 4.8],
    ),
    _OnboardingSlide(
      title: 'Your Closet, Anytime, Anywhere',
      subtitle: 'Digitize Your Wardrobe And Create Stylish Outfits Effortlessly. Plan Your Looks And Stay Organized!',
      images: [],
      names: [],
      specs: [],
      ratings: [],
    ),
  ];

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
                const SizedBox(height: 16),
                Text('D&D', style: GoogleFonts.playfairDisplay(
                  fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.gold,
                )),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(index);
                    },
                  ),
                ),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? AppColors.gold : AppColors.greyDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Title and subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        _slides[_currentPage].title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _slides[_currentPage].subtitle,
                        style: const TextStyle(fontSize: 14, color: AppColors.greyLight, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onSignIn,
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onSignUp,
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(int index) {
    if (index == 0) {
      return _buildStylistSlide();
    } else {
      return _buildWardrobeSlide();
    }
  }

  Widget _buildStylistSlide() {
    final slide = _slides[0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.cardDark,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Popular', style: GoogleFonts.playfairDisplay(
                      fontSize: 16, color: AppColors.goldLight, fontStyle: FontStyle.italic,
                    )),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: AppColors.gold, size: 16),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(2, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(slide.images[i], fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: AppColors.greyDark),
                                    ),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, color: AppColors.gold, size: 12),
                                            const SizedBox(width: 2),
                                            Text('${slide.ratings[i]}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8, left: 8,
                                      child: Icon(Icons.favorite_border, color: Colors.white.withOpacity(0.8), size: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(slide.names[i], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(slide.specs[i].join(' · '), style: const TextStyle(color: AppColors.greyLight, fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardrobeSlide() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.cardDark,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('My Wardrobe', style: GoogleFonts.playfairDisplay(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _wardrobeStat('Items', '77'),
                  Container(width: 1, height: 30, color: AppColors.greyDark, margin: const EdgeInsets.symmetric(horizontal: 24)),
                  _wardrobeStat('Outfit', '9'),
                ],
              ),
              const SizedBox(height: 16),
              // Category chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _categoryChip('All', true),
                    _categoryChip('Top wear', false),
                    _categoryChip('Bottom wear', false),
                    _categoryChip('Foot wear', false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.greyDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=300',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.greyDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wardrobeStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _categoryChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.gold : AppColors.greyDark),
      ),
      child: Text(label, style: TextStyle(
        color: selected ? AppColors.black : AppColors.greyLight, fontSize: 12, fontWeight: FontWeight.w500,
      )),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final List<String> images;
  final List<String> names;
  final List<List<String>> specs;
  final List<double> ratings;

  _OnboardingSlide({
    required this.title, required this.subtitle,
    required this.images, required this.names,
    required this.specs, required this.ratings,
  });
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
