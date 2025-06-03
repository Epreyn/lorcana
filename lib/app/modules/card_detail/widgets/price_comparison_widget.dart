import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/price_comparison_controller.dart';
import '../../../data/models/card_model.dart';
import '../../../themes/app_colors.dart';

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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withOpacity(0.6),
              ),
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (controller.prices.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'Aucun prix disponible',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Les prix seront bientôt disponibles',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: controller.refreshPrices,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: controller.refreshPrices,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
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
                color:
                    isBestPrice
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isBestPrice
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.1),
                  width: isBestPrice ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Logo du vendeur
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: AppColors.primary.withOpacity(0.05),
                      child:
                          price.seller.logoUrl.isNotEmpty
                              ? Image.network(
                                price.seller.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.store_rounded,
                                    color: AppColors.primary.withOpacity(0.3),
                                  );
                                },
                              )
                              : Icon(
                                Icons.store_rounded,
                                color: AppColors.primary.withOpacity(0.3),
                              ),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
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
                                  color: AppColors.success,
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
                              AppColors.sapphireInk,
                            ),
                            const SizedBox(width: 8),
                            // Langue
                            _buildChip(
                              price.language == 'FR'
                                  ? 'Français'
                                  : price.language == 'EN'
                                  ? 'Anglais'
                                  : price.language,
                              AppColors.amethystInk,
                            ),
                            const SizedBox(width: 8),
                            // Stock
                            if (!price.inStock)
                              _buildChip('Rupture', AppColors.error)
                            else
                              _buildChip('En stock', AppColors.success),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          price.seller.shippingInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
                          color:
                              isBestPrice
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                        ),
                      ),
                      if (price.seller.rating > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              price.seller.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
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
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prix fournis par Cardmarket • Mis à jour ${_getTimeAgo(controller.prices.first.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
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
