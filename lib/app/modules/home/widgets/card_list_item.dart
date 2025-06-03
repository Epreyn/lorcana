import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../../../data/models/card_model.dart';

class CardListItem extends StatelessWidget {
  final CardModel card;
  final int index;

  // Générer les valeurs une seule fois basées sur l'index
  late final double price;
  late final int stock;

  CardListItem({super.key, required this.card, required this.index}) {
    final random = Random(
      index,
    ); // Seed basé sur l'index pour des valeurs stables
    price = _generateRandomPrice(random);
    stock = random.nextInt(20) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/card-detail', arguments: card.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 12,
              color: Colors.grey.withOpacity(0.2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de la carte en plein écran
              Image.network(
                card.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF5F5F5),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),

              // Dégradé pour améliorer la lisibilité des chips
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Chips en bas de la carte
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip de prix
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784), // Vert pastel
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Chip de stock
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStockColor(stock),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStockIcon(stock),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stock.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
        ),
      ),
    );
  }

  double _generateRandomPrice(Random random) {
    switch (card.rarity.toLowerCase()) {
      case 'common':
        return 0.5 + random.nextDouble() * 2; // 0.50€ - 2.50€
      case 'uncommon':
        return 2 + random.nextDouble() * 5; // 2€ - 7€
      case 'rare':
        return 8 + random.nextDouble() * 12; // 8€ - 20€
      case 'super rare':
        return 20 + random.nextDouble() * 30; // 20€ - 50€
      case 'legendary':
        return 40 + random.nextDouble() * 60; // 40€ - 100€
      case 'enchanted':
        return 100 + random.nextDouble() * 150; // 100€ - 250€
      default:
        return 1 + random.nextDouble() * 5;
    }
  }

  Color _getStockColor(int stock) {
    if (stock <= 3) return const Color(0xFFE57373); // Rouge pastel
    if (stock <= 10) return const Color(0xFFFFB74D); // Orange pastel
    return const Color(0xFF64B5F6); // Bleu pastel
  }

  IconData _getStockIcon(int stock) {
    if (stock <= 3) return Icons.warning;
    return Icons.inventory_2;
  }
}
