import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('D&D', style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gold,
                    )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.black, size: 16),
                          SizedBox(width: 4),
                          Text('Upload Completed', style: TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Grid of 4 cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildFeatureCard(
                      context, 'Appointments', 
                      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
                      () => onNavigate(2),
                      height: 180,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            context, 'Stylists',
                            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400',
                            () => onNavigate(1),
                            height: 160,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureCard(
                            context, 'Wardrobe',
                            'https://images.unsplash.com/photo-1558171813-01a19a8e4fae?w=400',
                            () => onNavigate(0),
                            height: 160,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context, 'Inspirations',
                      'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inspirations coming soon!')),
                        );
                      },
                      height: 180,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String imageUrl, VoidCallback onTap, {double height = 160}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.cardDark),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16, left: 16,
                child: Text(title, style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
                  shadows: [const Shadow(blurRadius: 8, color: Colors.black54)],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
