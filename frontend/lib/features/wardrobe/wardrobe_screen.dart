import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/wardrobe_provider.dart';
import '../../core/widgets/molecules/wardrobe_item_card.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeItems = ref.watch(wardrobeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Digital Wardrobe'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo, color: Color(0xFFD4AF35)),
            onPressed: () {
              // Trigger Add Item Flow (Camera/Gallery)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Item flow triggered')),
              );
            },
          ),
        ],
      ),
      body: wardrobeItems.isEmpty
          ? const Center(
              child: Text(
                'Your wardrobe is empty. Add some items!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: wardrobeItems.length,
                itemBuilder: (context, index) {
                  return WardrobeItemCard(item: wardrobeItems[index]);
                },
              ),
            ),
    );
  }
}
