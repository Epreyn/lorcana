import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/price_comparison_controller.dart';

class PriceComparisonWidget extends StatelessWidget {
  final String cardId;

  const PriceComparisonWidget({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final PriceComparisonController controller = Get.find();

    // Charger les prix lors de l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPricesForCard(cardId);
    });

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.prices.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('Aucun prix disponible')),
        );
      }

      return Column(
        children:
            controller.prices.map((price) {
              final isBestPrice = price == controller.bestPrice;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isBestPrice ? Colors.green[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBestPrice ? Colors.green : Colors.grey[300]!,
                    width: isBestPrice ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Logo du vendeur
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        price.seller.logoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.store),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Informations du vendeur
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                price.seller.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isBestPrice)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Meilleur prix',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // État
                              _buildChip(
                                price.condition == 'NM'
                                    ? 'Neuf'
                                    : price.condition,
                                Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              // Langue
                              _buildChip(
                                price.language == 'FR'
                                    ? 'Français'
                                    : price.language,
                                Colors.purple,
                              ),
                              const SizedBox(width: 8),
                              // Stock
                              if (!price.inStock)
                                _buildChip('Rupture', Colors.red)
                              else
                                _buildChip('En stock', Colors.green),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price.seller.shippingInfo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Prix
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${price.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isBestPrice ? Colors.green : Colors.black,
                          ),
                        ),
                        // Note du vendeur
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              price.seller.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
