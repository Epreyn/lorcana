// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../controllers/home_controller.dart';
import '../../../data/models/card_model.dart';
import '../widgets/swipeable_card_stack.dart';
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
                // Header minimaliste
                _buildHeader(),

                // Zone de swipe des cartes
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

                    return SwipeableCardStack(
                      cards: cards,
                      onSwipeLeft: (card) => controller.onCardRejected(card),
                      onSwipeRight: (card) => controller.onCardLiked(card),
                      onSwipeUp: (card) => controller.onCardSuperLiked(card),
                    );
                  }),
                ),

                // Barre de filtres flottante
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Filtres et actions en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),

          // Menu flottant pour les filtres avancés
          Obx(() {
            if (controller.showAdvancedFilters.value) {
              return _buildAdvancedFiltersOverlay();
            }
            return const SizedBox.shrink();
          }),
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
          // Logo/Titre avec effet glow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6C63FF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lorcana Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              _buildHeaderAction(Icons.search, () => controller.toggleSearch()),
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
                      badge.toString(),
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

  Widget _buildBottomControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF0A0E27),
            const Color(0xFF0A0E27).withOpacity(0.8),
            const Color(0xFF0A0E27).withOpacity(0),
          ],
        ),
      ),
      child: Column(
        children: [
          // Barre de filtres rapides
          FloatingFilterBar(controller: controller),

          // Actions de swipe
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.refresh,
                  color: const Color(0xFFFFD93D),
                  onTap: controller.undoLastAction,
                  size: 50,
                ),
                _buildActionButton(
                  icon: Icons.close,
                  color: const Color(0xFFFF4757),
                  onTap: controller.rejectCurrentCard,
                  size: 60,
                ),
                _buildActionButton(
                  icon: Icons.star,
                  color: const Color(0xFF6BCF7F),
                  onTap: controller.superLikeCurrentCard,
                  size: 50,
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  color: const Color(0xFF4ECDC4),
                  onTap: controller.likeCurrentCard,
                  size: 60,
                ),
                _buildActionButton(
                  icon: Icons.flash_on,
                  color: const Color(0xFF6C63FF),
                  onTap: controller.boostCurrentCard,
                  size: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
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

  Widget _buildAdvancedFiltersOverlay() {
    return GestureDetector(
      onTap: () => controller.showAdvancedFilters.value = false,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on the menu
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtres avancés',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed:
                            () => controller.showAdvancedFilters.value = false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filtre par coût en encre
                  const Text(
                    'Coût en encre',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => RangeSlider(
                      values: controller.inkCostRange.value,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: const Color(0xFF6C63FF),
                      inactiveColor: Colors.white.withOpacity(0.2),
                      labels: RangeLabels(
                        controller.inkCostRange.value.start.round().toString(),
                        controller.inkCostRange.value.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        controller.inkCostRange.value = values;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Filtre par type
                  const Text(
                    'Type de carte',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTypeChip('Personnage', Icons.person),
                      _buildTypeChip('Action', Icons.flash_on),
                      _buildTypeChip('Objet', Icons.category),
                      _buildTypeChip('Lieu', Icons.place),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: controller.clearAllFilters,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Réinitialiser',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () =>
                                  controller.showAdvancedFilters.value = false,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Appliquer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedTypes.contains(label);
      return GestureDetector(
        onTap: () => controller.toggleType(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
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
