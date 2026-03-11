import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_config.dart';

/// Wardrobe item model
class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final String imageUrl;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

/// Selected wardrobe category
final wardrobeCategoryProvider = StateProvider<String>((ref) => 'All');

/// Fetch wardrobe items from backend
final wardrobeItemsProvider = FutureProvider<List<WardrobeItem>>((ref) async {
  final category = ref.watch(wardrobeCategoryProvider);
  try {
    final dio = ApiConfig.createDio();
    final queryParams = <String, dynamic>{};
    if (category != 'All') queryParams['category'] = category;

    final response = await dio.get('/wardrobe', queryParameters: queryParams);
    final List<dynamic> data = response.data['items'] ?? [];
    return data.map((json) => WardrobeItem.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

/// Wardrobe categories
final wardrobeCategoriesProvider = Provider<List<String>>((ref) {
  return ['All', 'Top Wear', 'Bottom Wear', 'Outfits', 'Accessories', 'Footwear'];
});
