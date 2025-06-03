import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../widgets/card_list_item.dart';
import '../widgets/serach_bar.dart' as search;

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lorcana Price Comparator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          search.SearchBar(
            onSearch: controller.updateSearchQuery,
            onFilterRarity: controller.filterByRarity,
            onFilterSet: controller.filterBySet,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final cards = controller.filteredCards;

              if (cards.isEmpty) {
                return const Center(child: Text('Aucune carte trouvée'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return CardListItem(card: cards[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
