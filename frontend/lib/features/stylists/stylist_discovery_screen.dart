import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/stylist_provider.dart';
import '../../core/widgets/molecules/stylist_card.dart';

class StylistDiscoveryScreen extends ConsumerWidget {
  const StylistDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stylistsState = ref.watch(stylistsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Explore Stylists', style: TextStyle(color: Color(0xFFD4AF35))),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Trigger Search / Filter
            },
          ),
        ],
      ),
      body: stylistsState.when(
        data: (stylists) {
          if (stylists.isEmpty) {
            return const Center(
              child: Text('No stylists available at the moment.', style: TextStyle(color: Colors.white)),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: stylists.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to Stylist Details
                  },
                  child: StylistCard(stylist: stylists[index]),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF35)),
        ),
        error: (error, stack) => Center(
          child: Text('Error loading stylists: \$error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
