import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../controllers/home_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../data/models/card_model.dart';
import '../widgets/carousel_card_view.dart';
import '../widgets/floating_filter_bar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background animé pastel
          const PastelAnimatedBackground(),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header minimaliste
                _buildHeader(),

                // Zone du carousel
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withOpacity(0.6),
                          ),
                          strokeWidth: 2,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Compteur de cartes
          Obx(() {
            final count = controller.filteredCards.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.style_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$count cartes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Actions
          Row(
            children: [
              _buildHeaderAction(
                Icons.search_rounded,
                () => controller.toggleSearch(),
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildHeaderAction(
                  controller.likedCards.isNotEmpty
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  () => Get.toNamed('/favorites'),
                  badge: controller.likedCards.length,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildHeaderAction(
                  Icons.shopping_bag_outlined,
                  () => Get.toNamed('/cart'),
                  badge: controller.cartItemsCount,
                  color: AppColors.success,
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
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            if (badge > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
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
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.style_outlined,
              size: 60,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune carte trouvée',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Modifiez vos filtres pour voir plus de cartes',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: controller.clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Réinitialiser les filtres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background animé avec des couleurs pastelles
class PastelAnimatedBackground extends StatefulWidget {
  const PastelAnimatedBackground({super.key});

  @override
  State<PastelAnimatedBackground> createState() =>
      _PastelAnimatedBackgroundState();
}

class _PastelAnimatedBackgroundState extends State<PastelAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
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
              colors: [
                AppColors.background,
                AppColors.primaryLight.withOpacity(0.1),
                AppColors.secondaryLight.withOpacity(0.1),
                AppColors.success.withOpacity(0.1),
                AppColors.background,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        );
      },
    );
  }
}
