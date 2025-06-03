import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/card_controller.dart';
import '../../../controllers/price_comparison_controller.dart';
import '../../../themes/app_colors.dart';
import '../widgets/price_comparison_widget.dart';
import '../widgets/stock_indicator.dart';

class CardDetailView extends StatelessWidget {
  const CardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final CardController controller = Get.find();
    final PriceComparisonController priceController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedCard.value?.name ?? 'Détails',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final card = controller.selectedCard.value;
        if (card == null) {
          return const Center(child: Text('Carte non trouvée'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de la carte
              Container(
                height: 350,
                width: double.infinity,
                color: Colors.black,
                child: Image.network(
                  card.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et set
                    Text(
                      card.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${card.set} • ${card.rarity}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 16),

                    // Informations de la carte
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(
                          Icons.water_drop,
                          '${card.inkCost}',
                          Colors.blue,
                        ),
                        _buildInfoChip(
                          Icons.category,
                          card.type,
                          Colors.purple,
                        ),
                        StockIndicator(quantity: card.stockQuantity),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Prix le plus bas
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(
                          0.1,
                        ), // Au lieu de Colors.green.withOpacity(0.1)
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Au lieu de 12
                        border: Border.all(
                          color: AppColors.success.withOpacity(
                            0.2,
                          ), // Au lieu de Colors.green
                          width: 1, // Au lieu de border direct
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Meilleur prix',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${card.lowestPrice.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Comparaison des prix
                    const Text(
                      'Comparaison des prix',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PriceComparisonWidget(cardId: card.id),

                    const SizedBox(height: 24),

                    // Section d'achat
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(
                          0.05,
                        ), // Au lieu de Colors.grey[100]
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Au lieu de 12
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quantité',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: controller.decrementQuantity,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      '${controller.quantity.value}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: controller.incrementQuantity,
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed:
                                  card.stockQuantity > 0
                                      ? controller.addToCart
                                      : null,
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text(
                                'Ajouter au panier',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
