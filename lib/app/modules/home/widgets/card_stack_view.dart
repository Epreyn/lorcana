import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../data/models/card_model.dart';
import '../../../controllers/card_stack_controller.dart';

class CardStackView extends GetView<CardStackController> {
  final List<CardModel> cards;

  const CardStackView({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    // Initialiser le controller avec les cartes
    Get.put(CardStackController(cards));

    return GetBuilder<CardStackController>(
      builder:
          (_) => PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              double difference = (index - controller.currentPage);
              double scale = 1 - (difference.abs() * 0.15).clamp(0.0, 0.3);
              double rotation = difference * 0.1;
              double verticalOffset = difference.abs() * 30;

              // Prix et stock stables basés sur l'index
              final random = Random(index);
              final price = _generatePrice(card, random);
              final stock = random.nextInt(20) + 1;

              return Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..scale(scale)
                        ..rotateY(rotation)
                        ..translate(0.0, verticalOffset, 0.0),
                  child: GestureDetector(
                    onTap:
                        () => Get.toNamed('/card-detail', arguments: card.id),
                    onDoubleTap: () => controller.flipCard(index),
                    child: Obx(() {
                      final isFlipped = controller.isCardFlipped(index);
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          final rotate = Tween(
                            begin: math.pi,
                            end: 0.0,
                          ).animate(animation);
                          return AnimatedBuilder(
                            animation: rotate,
                            child: child,
                            builder: (context, child) {
                              final isShowingFront = rotate.value < math.pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform:
                                    Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(rotate.value),
                                child: child,
                              );
                            },
                          );
                        },
                        child:
                            isFlipped
                                ? _buildCardBack(card, index)
                                : _buildCardFront(card, price, stock),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildCardFront(CardModel card, double price, int stock) {
    return Container(
      key: const ValueKey('front'),
      width: Get.width * 0.75,
      height: Get.height * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              card.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF5F5F5),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),

            // Dégradé en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Prix et stock
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStockColor(stock),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          stock.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
    );
  }

  Widget _buildCardBack(CardModel card, int index) {
    return Container(
      key: const ValueKey('back'),
      width: Get.width * 0.75,
      height: Get.height * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFF3E5F5), Color(0xFFE3F2FD)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              card.name,
              style: const TextStyle(
                color: Color(0xFF2D3436),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${card.set} • ${card.rarity}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Coût en encre',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Text(
                        card.inkCost.toString(),
                        style: const TextStyle(
                          color: Color(0xFF2D3436),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Type',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Flexible(
                        child: Text(
                          card.type,
                          style: const TextStyle(
                            color: Color(0xFF2D3436),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Double tap pour retourner',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  double _generatePrice(CardModel card, Random random) {
    switch (card.rarity.toLowerCase()) {
      case 'common':
        return 0.5 + random.nextDouble() * 2;
      case 'uncommon':
        return 2 + random.nextDouble() * 5;
      case 'rare':
        return 8 + random.nextDouble() * 12;
      case 'super rare':
        return 20 + random.nextDouble() * 30;
      case 'legendary':
        return 40 + random.nextDouble() * 60;
      case 'enchanted':
        return 100 + random.nextDouble() * 150;
      default:
        return 1 + random.nextDouble() * 5;
    }
  }

  Color _getStockColor(int stock) {
    if (stock <= 3) return const Color(0xFFE57373);
    if (stock <= 10) return const Color(0xFFFFB74D);
    return const Color(0xFF64B5F6);
  }
}
