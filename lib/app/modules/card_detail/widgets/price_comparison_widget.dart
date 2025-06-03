import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/price_comparison_controller.dart';
import '../../../data/models/card_model.dart';

class PriceComparisonWidget extends StatelessWidget {
  final String cardId;
  final CardModel? card;

  const PriceComparisonWidget({super.key, required this.cardId, this.card});

  @override
  Widget build(BuildContext context) {
    final PriceComparisonController controller = Get.find();

    // Charger les prix lors de l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPricesForCard(cardId, card: card);
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
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              const Text('Aucun prix disponible'),
              const SizedBox(height: 4),
              Text(
                'Les prix seront bientôt disponibles',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: controller.refreshPrices,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // En-tête avec bouton de rafraîchissement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.prices.length} offres trouvées',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              IconButton(
                onPressed: controller.refreshPrices,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Actualiser les prix',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Liste des prix
          ...controller.prices.map((price) {
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
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child:
                          price.seller.logoUrl.isNotEmpty
                              ? Image.network(
                                price.seller.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.store,
                                    color: Colors.grey,
                                  );
                                },
                              )
                              : const Icon(Icons.store, color: Colors.grey),
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
                            Flexible(
                              child: Text(
                                price.seller.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                                  : price.condition == 'LP'
                                  ? 'Légèrement joué'
                                  : price.condition,
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            // Langue
                            _buildChip(
                              price.language == 'FR'
                                  ? 'Français'
                                  : price.language == 'EN'
                                  ? 'Anglais'
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      if (price.seller.rating > 0)
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

          // Note sur Cardmarket
          if (controller.prices.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prix fournis par Cardmarket • Mis à jour ${_getTimeAgo(controller.prices.first.updatedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else {
      return 'il y a ${difference.inDays}j';
    }
  }
}
