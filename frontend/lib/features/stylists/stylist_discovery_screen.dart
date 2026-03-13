import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/stylist_provider.dart';
import 'stylist_detail_screen.dart';
import 'stylist_filter_sheet.dart';

class StylistDiscoveryScreen extends ConsumerStatefulWidget {
  const StylistDiscoveryScreen({super.key});

  @override
  ConsumerState<StylistDiscoveryScreen> createState() => _StylistDiscoveryScreenState();
}

class _StylistDiscoveryScreenState extends ConsumerState<StylistDiscoveryScreen> {
  Map<String, dynamic> _filters = {};
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(stylistCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final stylistsState = ref.watch(filteredStylistsProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_isSearching)
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search by name or specialty...',
                          prefixIcon: Icon(Icons.search, color: AppColors.greyMid),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onChanged: (val) {
                          ref.read(searchQueryProvider.notifier).state = val;
                        },
                      ),
                    )
                  else
                    Text('D&D Stylists', style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold,
                    )),
                  if (!_isSearching) const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.gold),
                    onPressed: () async {
                      final result = await StylistFilterSheet.show(context, _filters);
                      if (result != null) {
                        setState(() => _filters = result);
                        if (result['category'] != null && result['category'] != 'All') {
                          ref.read(selectedCategoryProvider.notifier).state = result['category'];
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Find Your Perfect Stylist', style: GoogleFonts.playfairDisplay(
                fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic,
              )),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Book expert stylists for any occasion', style: TextStyle(color: AppColors.greyLight, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: GoogleFonts.playfairDisplay(
                    fontSize: 16, color: AppColors.gold, fontStyle: FontStyle.italic,
                  )),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: categories.when(
                      data: (cats) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cats.length,
                        itemBuilder: (context, i) {
                          final cat = cats[i];
                          final isSelected = cat == selectedCategory;
                          return GestureDetector(
                            onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.gold : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppColors.gold : AppColors.cardBorder),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? AppColors.black : AppColors.greyLight,
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Explore stylists', style: GoogleFonts.playfairDisplay(
                fontSize: 16, color: AppColors.gold, fontStyle: FontStyle.italic,
              )),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: stylistsState.when(
                data: (stylists) {
                  if (stylists.isEmpty) {
                    return const Center(child: Text('No stylists found', style: TextStyle(color: Colors.white)));
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: stylists.length,
                      itemBuilder: (context, index) {
                        return _StylistCard(
                          stylist: stylists[index],
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => StylistDetailScreen(stylist: stylists[index]),
                            ));
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StylistCard extends ConsumerWidget {
  final Stylist stylist;
  final VoidCallback onTap;
  const _StylistCard({required this.stylist, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favouriteStylistsProvider);
    final isFav = favs.contains(stylist.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(stylist.profileImage, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.cardDark),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Rating badge
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.gold, size: 12),
                      const SizedBox(width: 2),
                      Text('${stylist.rating}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              // Favorite
              Positioned(
                top: 8, left: 8,
                child: GestureDetector(
                  onTap: () {
                    ref.read(favouriteStylistsProvider.notifier).toggle(stylist.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Info at bottom
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stylist.name, style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      stylist.speciality.join(' · '),
                      style: const TextStyle(color: AppColors.greyLight, fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
