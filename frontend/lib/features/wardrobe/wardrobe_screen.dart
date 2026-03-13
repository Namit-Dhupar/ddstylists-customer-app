import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/wardrobe_provider.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    String name = 'New Item';
    String category = ref.read(wardrobeCategoriesProvider).firstWhere((c) => c != 'All', orElse: () => 'Top Wear');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String tempName = name;
        String tempCat = category;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.cardDark,
              title: const Text('Add Wardrobe Item', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Item Name', labelStyle: TextStyle(color: AppColors.greyLight)),
                    onChanged: (val) => tempName = val,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.cardDark,
                    value: tempCat,
                    items: ref.read(wardrobeCategoriesProvider)
                        .where((c) => c != 'All')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => tempCat = val);
                    },
                    decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.greyLight)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.greyMid)),
                ),
                TextButton(
                  onPressed: () {
                    name = tempName;
                    category = tempCat;
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Upload', style: TextStyle(color: AppColors.gold)),
                ),
              ],
            );
          }
        );
      }
    );

    if (result == true) {
      setState(() => _isUploading = true);
      final success = await ref.read(wardrobeServiceProvider).addItem(name, category, image.path);
      setState(() => _isUploading = false);
      
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added successfully! Background removed.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add item')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(wardrobeCategoriesProvider);
    final selectedCategory = ref.watch(wardrobeCategoryProvider);
    final itemsAsync = ref.watch(wardrobeItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header with profile and stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text('Your Digital Wardrobe', style: GoogleFonts.playfairDisplay(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold,
                      )),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload and organize your outfits in one place.\nMix, match, and plan your looks effortlessly!',
                        style: TextStyle(color: AppColors.greyLight, fontSize: 13, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                itemsAsync.when(
                  data: (items) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stat('Items', '${items.length}'),
                        Container(width: 1, height: 30, color: AppColors.greyDark, margin: const EdgeInsets.symmetric(horizontal: 32)),
                        _stat('Outfit', '${(items.length / 3).ceil()}'),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(height: 48), // Match row height approximately
                  error: (_, __) => const SizedBox(height: 48),
                ),
                const SizedBox(height: 20),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final cat = categories[i];
                      final isSelected = cat == selectedCategory;
                      return GestureDetector(
                        onTap: () => ref.read(wardrobeCategoryProvider.notifier).state = cat,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
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
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: itemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.checkroom_outlined, color: AppColors.greyDark, size: 64),
                              const SizedBox(height: 16),
                              const Text('No items yet', style: TextStyle(color: Colors.white, fontSize: 18)),
                              const SizedBox(height: 8),
                              const Text('Add clothes to your wardrobe', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
                            ],
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _WardrobeItemCard(item: items[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                  ),
                ),
              ],
            ),
            if (_isUploading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.gold),
                      SizedBox(height: 16),
                      Text('Removing background & uploading...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: _isUploading ? null : _pickAndUploadImage,
        child: const Icon(Icons.add, color: AppColors.black),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _WardrobeItemCard extends ConsumerStatefulWidget {
  final WardrobeItem item;
  const _WardrobeItemCard({required this.item});

  @override
  ConsumerState<_WardrobeItemCard> createState() => _WardrobeItemCardState();
}

class _WardrobeItemCardState extends ConsumerState<_WardrobeItemCard> {
  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() => _showDelete = !_showDelete);
      },
      onTap: () {
        if (_showDelete) {
          setState(() => _showDelete = false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _showDelete ? Colors.red.withOpacity(0.5) : AppColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.item.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.cardDark),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 10, left: 10, right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(widget.item.category, style: const TextStyle(color: AppColors.greyLight, fontSize: 10)),
                  ],
                ),
              ),
              if (_showDelete)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final success = await ref.read(wardrobeServiceProvider).deleteItem(widget.item.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppColors.black, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
