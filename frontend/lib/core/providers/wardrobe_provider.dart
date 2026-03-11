import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dummy models for state
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
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    state = [
      WardrobeItem(id: '1', name: 'Summer Dress', category: 'Outfits', imageUrl: 'https://via.placeholder.com/150'),
      WardrobeItem(id: '2', name: 'Denim Jacket', category: 'Top Wear', imageUrl: 'https://via.placeholder.com/150'),
    ];
  }

  void addItem(WardrobeItem item) {
    state = [...state, item];
  }
}

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, List<WardrobeItem>>((ref) {
  return WardrobeNotifier();
});
