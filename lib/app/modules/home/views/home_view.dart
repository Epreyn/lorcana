// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../controllers/home_controller.dart';
import '../../../data/models/card_model.dart';
import '../widgets/carousel_card_view.dart';
import '../widgets/floating_filter_bar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration pour un affichage immersif
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          // Background animé avec effet parallaxe
          const AnimatedBackground(),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header minimaliste avec compteur de cartes
                _buildHeader(),

                // Zone du carousel
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF),
                          ),
                        ),
                      );
                    }

                    final cards = controller.filteredCards;
                    if (cards.isEmpty) {
                      return _buildEmptyState();
                    }

                    return CarouselCardView(
                      cards: cards,
                      onCardTap:
                          (card) =>
                              Get.toNamed('/card-detail', arguments: card.id),
                      onLike: (card) => controller.toggleLikeCard(card),
                      onAddToCart: (card) => controller.addCardToCart(card),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Filtres en bas
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FloatingFilterBar(controller: controller),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Compteur de cartes
          Obx(() {
            final count = controller.filteredCards.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.style, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$count cartes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Actions
          Row(
            children: [
              _buildHeaderAction(Icons.search, () => controller.toggleSearch()),
              const SizedBox(width: 12),
              Obx(
                () => _buildHeaderAction(
                  Icons.favorite,
                  () => Get.toNamed('/favorites'),
                  badge: controller.likedCards.length,
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildHeaderAction(
                  Icons.shopping_bag_outlined,
                  () => Get.toNamed('/cart'),
                  badge: controller.cartItemsCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(
    IconData icon,
    VoidCallback onTap, {
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (badge > 0)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4757),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.2),
                  const Color(0xFF4ECDC4).withOpacity(0.2),
                ],
              ),
            ),
            child: const Icon(
              Icons.style_outlined,
              size: 60,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune carte trouvée',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Modifiez vos filtres pour voir plus de cartes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: controller.clearAllFilters,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Réinitialiser les filtres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour le background animé
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.sin(_controller.value * 2 * math.pi),
                math.cos(_controller.value * 2 * math.pi),
              ),
              end: Alignment(
                -math.sin(_controller.value * 2 * math.pi),
                -math.cos(_controller.value * 2 * math.pi),
              ),
              colors: const [
                Color(0xFF0A0E27),
                Color(0xFF1A1F3A),
                Color(0xFF2A2F4A),
                Color(0xFF1A1F3A),
                Color(0xFF0A0E27),
              ],
            ),
          ),
        );
      },
    );
  }
}
