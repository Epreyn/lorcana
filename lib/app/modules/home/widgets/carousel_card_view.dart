// lib/app/modules/home/widgets/carousel_card_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../data/models/card_model.dart';
import '../../../themes/app_colors.dart';

class CarouselCardView extends StatefulWidget {
  final List<CardModel> cards;
  final Function(CardModel) onCardTap;
  final Function(CardModel) onLike;
  final Function(CardModel) onAddToCart;

  const CarouselCardView({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.onLike,
    required this.onAddToCart,
  });

  @override
  State<CarouselCardView> createState() => _CarouselCardViewState();
}

// Custom ScrollPhysics pour permettre le scroll libre mais avec snap à la fin
class CustomPageScrollPhysics extends ScrollPhysics {
  const CustomPageScrollPhysics({ScrollPhysics? parent})
    : super(parent: parent);

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Si la vélocité est faible, on snap immédiatement
    if (velocity.abs() < 500) {
      final double page = position.pixels / position.viewportDimension;
      final double target = page.roundToDouble() * position.viewportDimension;

      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }

    // Sinon, on laisse le scroll se faire naturellement
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool get allowImplicitScrolling => false;
}

class _CarouselCardViewState extends State<CarouselCardView> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<String, bool> _likedCards = {};
  final Map<String, bool> _cartCards = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _currentIndex,
    );
  }

  void _snapToNearestCard() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page ?? 0;
    final nearestPage = page.round();

    // Animer vers la page la plus proche
    _pageController.animateToPage(
      nearestPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentIndex = nearestPage % widget.cards.length;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CarouselCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards.length != oldWidget.cards.length) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          // Le scroll s'est arrêté
          Future.microtask(() => _snapToNearestCard());
        }
        return false;
      },
      child: PageView.builder(
        controller: _pageController,
        physics:
            const PageScrollPhysics(), // Utiliser PageScrollPhysics au lieu de BouncingScrollPhysics
        pageSnapping: true, // Activer le snap natif
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index % widget.cards.length;
          });
        },
        itemBuilder: (context, index) {
          final cardIndex = index % widget.cards.length;
          final card = widget.cards[cardIndex];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0.0;
              if (_pageController.position.haveDimensions) {
                value = index.toDouble() - (_pageController.page ?? 0);
                value = (value * 0.8).clamp(-1, 1);
              }

              double scale = 1 - (value.abs() * 0.1);
              double opacity = 1 - (value.abs() * 0.3);

              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: _buildCard(card, cardIndex == _currentIndex),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // lib/app/modules/home/widgets/carousel_card_view.dart
  Widget _buildCard(CardModel card, bool isCurrent) {
    final isLiked = _likedCards[card.id] ?? false;
    final isInCart = _cartCards[card.id] ?? false;

    return GestureDetector(
      onTap: () => widget.onCardTap(card),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        child: AspectRatio(
          aspectRatio: 63 / 88,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(isCurrent ? 0.15 : 0.08),
                  blurRadius: isCurrent ? 30 : 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de la carte
                  Image.network(
                    card.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: AppColors.primary.withOpacity(0.3),
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),

                  // Overlay avec infos en bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.transparent,
                      //       Colors.white.withOpacity(0.7),
                      //       Colors.white.withOpacity(0.9),
                      //     ],
                      //   ),
                      // ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Prix
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors
                                      .success, // Couleur pleine pour la visibilité
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${card.lowestPrice.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Actions
                          Row(
                            children: [
                              _buildActionButton(
                                icon:
                                    isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                color: AppColors.error,
                                isActive: isLiked,
                                onTap: () {
                                  setState(() {
                                    _likedCards[card.id] = !isLiked;
                                  });
                                  widget.onLike(card);
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildActionButton(
                                icon:
                                    isInCart
                                        ? Icons.shopping_bag
                                        : Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                                isActive: isInCart,
                                onTap: () {
                                  setState(() {
                                    _cartCards[card.id] = !isInCart;
                                  });
                                  widget.onAddToCart(card);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Badge de stock
                  if (card.stockQuantity < 5)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              card.stockQuantity == 0
                                  ? AppColors.error
                                  : AppColors.warning,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          card.stockQuantity == 0
                              ? 'Rupture'
                              : 'Stock: ${card.stockQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Icon(icon, color: isActive ? Colors.white : color, size: 20),
      ),
    );
  }
}
