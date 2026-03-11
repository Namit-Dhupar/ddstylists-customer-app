import 'package:flutter_riverpod/flutter_riverpod.dart';

class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final String imageUrl;

  WardrobeItem({required this.id, required this.name, required this.category, required this.imageUrl});
}

class WardrobeNotifier extends StateNotifier<List<WardrobeItem>> {
  WardrobeNotifier() : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    await Future.delayed(const Duration(milliseconds: 600));
    state = [
      WardrobeItem(id: '1', name: 'Blue Blazer', category: 'Top Wear', imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300'),
      WardrobeItem(id: '2', name: 'White Shirt', category: 'Top Wear', imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=300'),
      WardrobeItem(id: '3', name: 'Black T-Shirt', category: 'Top Wear', imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300'),
      WardrobeItem(id: '4', name: 'Denim Jeans', category: 'Bottom Wear', imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300'),
      WardrobeItem(id: '5', name: 'Black Trousers', category: 'Bottom Wear', imageUrl: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=300'),
      WardrobeItem(id: '6', name: 'Sneakers', category: 'Footwear', imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300'),
      WardrobeItem(id: '7', name: 'Oxford Shoes', category: 'Footwear', imageUrl: 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=300'),
      WardrobeItem(id: '8', name: 'Summer Dress', category: 'Outfits', imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=300'),
      WardrobeItem(id: '9', name: 'Watch', category: 'Accessories', imageUrl: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=300'),
      WardrobeItem(id: '10', name: 'Sunglasses', category: 'Accessories', imageUrl: 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=300'),
    ];
  }

  void addItem(WardrobeItem item) {
    state = [...state, item];
  }

  void removeItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }
}

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, List<WardrobeItem>>((ref) {
  return WardrobeNotifier();
});

final wardrobeCategoriesProvider = Provider<List<String>>((ref) {
  return ['All', 'Top Wear', 'Bottom Wear', 'Footwear', 'Outfits', 'Accessories'];
});

final selectedWardrobeCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredWardrobeProvider = Provider<List<WardrobeItem>>((ref) {
  final category = ref.watch(selectedWardrobeCategoryProvider);
  final items = ref.watch(wardrobeProvider);
  if (category == 'All') return items;
  return items.where((i) => i.category == category).toList();
});
