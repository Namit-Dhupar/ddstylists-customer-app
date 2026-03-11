import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';

class StylistFilterSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;

  const StylistFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  static Future<Map<String, dynamic>?> show(BuildContext context, Map<String, dynamic> currentFilters) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StylistFilterSheet(
        currentFilters: currentFilters,
        onApply: (filters) => Navigator.pop(ctx, filters),
      ),
    );
  }

  @override
  State<StylistFilterSheet> createState() => _StylistFilterSheetState();
}

class _StylistFilterSheetState extends State<StylistFilterSheet> {
  late String _selectedCategory;
  late RangeValues _priceRange;
  late double _minRating;
  late String _sortBy;
  late String _location;

  final List<String> _categories = ['All', 'Wedding', 'Corporate', 'Casual', 'Red Carpet', 'Maternity', 'Sustainable'];
  final List<String> _sortOptions = ['Rating', 'Price (Low)', 'Price (High)', 'Experience'];
  final List<String> _locations = ['All', 'London', 'Manchester', 'Birmingham', 'Mumbai', 'Delhi', 'Bangalore'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilters['category'] ?? 'All';
    _priceRange = widget.currentFilters['priceRange'] ?? const RangeValues(0, 500);
    _minRating = widget.currentFilters['minRating'] ?? 0.0;
    _sortBy = widget.currentFilters['sortBy'] ?? 'Rating';
    _location = widget.currentFilters['location'] ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle and header
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.greyMid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Filter Stylists', style: GoogleFonts.playfairDisplay(
                      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gold,
                    )),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _priceRange = const RangeValues(0, 500);
                          _minRating = 0.0;
                          _sortBy = 'Rating';
                          _location = 'All';
                        });
                      },
                      child: const Text('Reset', style: TextStyle(color: AppColors.goldLight, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category
                _sectionTitle('Category'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.gold : AppColors.cardBorder),
                        ),
                        child: Text(cat, style: TextStyle(
                          color: isSelected ? AppColors.black : AppColors.greyLight,
                          fontSize: 13, fontWeight: FontWeight.w500,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Price Range
                _sectionTitle('Price Range'),
                const SizedBox(height: 4),
                Text(
                  '£${_priceRange.start.toInt()} — £${_priceRange.end.toInt()}',
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 14),
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  activeColor: AppColors.gold,
                  inactiveColor: AppColors.greyDark,
                  onChanged: (v) => setState(() => _priceRange = v),
                ),
                const SizedBox(height: 24),

                // Minimum Rating
                _sectionTitle('Minimum Rating'),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (i) {
                    final starValue = (i + 1).toDouble();
                    return GestureDetector(
                      onTap: () => setState(() => _minRating = _minRating == starValue ? 0 : starValue),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          starValue <= _minRating ? Icons.star : Icons.star_border,
                          color: AppColors.gold,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // Location
                _sectionTitle('Location'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locations.map((loc) {
                    final isSelected = _location == loc;
                    return GestureDetector(
                      onTap: () => setState(() => _location = loc),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.gold : AppColors.cardBorder),
                        ),
                        child: Text(loc, style: TextStyle(
                          color: isSelected ? AppColors.black : AppColors.greyLight,
                          fontSize: 13, fontWeight: FontWeight.w500,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Sort By
                _sectionTitle('Sort By'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sortOptions.map((opt) {
                    final isSelected = _sortBy == opt;
                    return GestureDetector(
                      onTap: () => setState(() => _sortBy = opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.gold : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.gold : AppColors.cardBorder),
                        ),
                        child: Text(opt, style: TextStyle(
                          color: isSelected ? AppColors.black : AppColors.greyLight,
                          fontSize: 13, fontWeight: FontWeight.w500,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply({
                        'category': _selectedCategory,
                        'priceRange': _priceRange,
                        'minRating': _minRating,
                        'sortBy': _sortBy,
                        'location': _location,
                      });
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.playfairDisplay(
      fontSize: 16, color: AppColors.gold, fontStyle: FontStyle.italic,
    ));
  }
}
