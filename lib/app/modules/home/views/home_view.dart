import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../widgets/card_list_item.dart';
import '../widgets/card_stack_view.dart';
import '../widgets/custom_search_delegate.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Blanc cassé pastel
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lorcana Collection',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Bouton de recherche
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D3436)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(controller),
              );
            },
          ),
          // Bouton de filtre
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF2D3436)),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          // Bouton de changement de vue
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isGridView.value
                    ? Icons.view_agenda
                    : Icons.grid_view,
                color: const Color(0xFF2D3436),
              ),
              onPressed: controller.toggleView,
            ),
          ),
          // Bouton panier
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF2D3436),
            ),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF0F3F7), // Gris très clair pastel
            ],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chargement des cartes...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final cards = controller.filteredCards;

          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text(
                    'Aucune carte trouvée',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                controller.isGridView.value
                    ? _buildGridView(cards)
                    : CardStackView(cards: cards),
          );
        }),
      ),
    );
  }

  Widget _buildGridView(List<dynamic> cards) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return CardListItem(
          card: cards[index],
          index: index, // Pour générer des valeurs stables
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rareté',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        'Toutes',
                        null,
                        controller.selectedRarity.value,
                        (value) => controller.filterByRarity(value),
                      ),
                      _buildFilterChip(
                        'Common',
                        'Common',
                        controller.selectedRarity.value,
                        (value) => controller.filterByRarity(value),
                        color: const Color(0xFFB2DFDB),
                      ),
                      _buildFilterChip(
                        'Uncommon',
                        'Uncommon',
                        controller.selectedRarity.value,
                        (value) => controller.filterByRarity(value),
                        color: const Color(0xFFC5E1A5),
                      ),
                      _buildFilterChip(
                        'Rare',
                        'Rare',
                        controller.selectedRarity.value,
                        (value) => controller.filterByRarity(value),
                        color: const Color(0xFFB3E5FC),
                      ),
                      _buildFilterChip(
                        'Super Rare',
                        'Super Rare',
                        controller.selectedRarity.value,
                        (value) => controller.filterByRarity(value),
                        color: const Color(0xFFE1BEE7),
                      ),
                      _buildFilterChip(
                        'Legendary',
                        'Legendary',
                        controller.selectedRarity.value,
                        (value) => controller.filterByRarity(value),
                        color: const Color(0xFFFFE0B2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Édition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        'Tous',
                        null,
                        controller.selectedSet.value,
                        (value) => controller.filterBySet(value),
                      ),
                      _buildFilterChip(
                        'TFC',
                        'TFC',
                        controller.selectedSet.value,
                        (value) => controller.filterBySet(value),
                      ),
                      _buildFilterChip(
                        'ROF',
                        'ROF',
                        controller.selectedSet.value,
                        (value) => controller.filterBySet(value),
                      ),
                      _buildFilterChip(
                        'ITI',
                        'ITI',
                        controller.selectedSet.value,
                        (value) => controller.filterBySet(value),
                      ),
                      _buildFilterChip(
                        'URR',
                        'URR',
                        controller.selectedSet.value,
                        (value) => controller.filterBySet(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? selectedValue,
    Function(String?) onSelected, {
    Color? color,
  }) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (color ?? const Color(0xFFE3F2FD))
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? (color ?? const Color(0xFF2196F3)).withOpacity(0.5)
                    : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
