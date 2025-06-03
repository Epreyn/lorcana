// lib/app/modules/home/widgets/swipeable_card_stack.dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;
import '../../../data/models/card_model.dart';

class SwipeableCardStack extends StatefulWidget {
  final List<CardModel> cards;
  final Function(CardModel) onSwipeLeft;
  final Function(CardModel) onSwipeRight;
  final Function(CardModel) onSwipeUp;

  const SwipeableCardStack({
    super.key,
    required this.cards,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack>
    with TickerProviderStateMixin {
  late List<CardModel> _cards;
  final List<SwipeableCard> _cardWidgets = [];

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);
    _setupCards();
  }

  @override
  void didUpdateWidget(SwipeableCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards.length != oldWidget.cards.length) {
      _cards = List.from(widget.cards);
      _setupCards();
    }
  }

  void _setupCards() {
    _cardWidgets.clear();
    for (int i = 0; i < math.min(3, _cards.length); i++) {
      _cardWidgets.add(
        SwipeableCard(
          key: ValueKey(_cards[i].id),
          card: _cards[i],
          onSwipeLeft: () => _handleSwipe(_cards[i], SwipeDirection.left),
          onSwipeRight: () => _handleSwipe(_cards[i], SwipeDirection.right),
          onSwipeUp: () => _handleSwipe(_cards[i], SwipeDirection.up),
          index: i,
        ),
      );
    }
  }

  void _handleSwipe(CardModel card, SwipeDirection direction) {
    setState(() {
      _cards.removeAt(0);
      _setupCards();
    });

    switch (direction) {
      case SwipeDirection.left:
        widget.onSwipeLeft(card);
        break;
      case SwipeDirection.right:
        widget.onSwipeRight(card);
        break;
      case SwipeDirection.up:
        widget.onSwipeUp(card);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cardWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.65,
        child: Stack(
          children:
              _cardWidgets.reversed.map((card) {
                final index = _cardWidgets.indexOf(card);
                return Positioned(
                  top: index * 8.0,
                  left: 0,
                  right: 0,
                  child: card,
                );
              }).toList(),
        ),
      ),
    );
  }
}

enum SwipeDirection { left, right, up }

class SwipeableCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final int index;

  const SwipeableCard({
    super.key,
    required this.card,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    required this.index,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _rotationController;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _positionController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Déterminer la direction du swipe
    if (_dragOffset.dx.abs() > screenWidth * 0.3) {
      // Swipe horizontal
      if (_dragOffset.dx > 0) {
        _swipeAway(SwipeDirection.right);
      } else {
        _swipeAway(SwipeDirection.left);
      }
    } else if (_dragOffset.dy < -screenHeight * 0.2 &&
        _dragOffset.dy.abs() > _dragOffset.dx.abs()) {
      // Swipe vers le haut
      _swipeAway(SwipeDirection.up);
    } else {
      // Retour à la position initiale
      _animateBack();
    }
  }

  void _swipeAway(SwipeDirection direction) {
    _swipeDirection = direction;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Offset endPosition;
    double endRotation;

    switch (direction) {
      case SwipeDirection.left:
        endPosition = Offset(-screenWidth * 1.5, _dragOffset.dy);
        endRotation = -0.5;
        break;
      case SwipeDirection.right:
        endPosition = Offset(screenWidth * 1.5, _dragOffset.dy);
        endRotation = 0.5;
        break;
      case SwipeDirection.up:
        endPosition = Offset(_dragOffset.dx, -screenHeight * 1.5);
        endRotation = 0;
        break;
    }

    _positionAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: endPosition,
    ).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / screenWidth * 0.3,
      end: endRotation,
    ).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );

    _positionController.forward().then((_) {
      switch (direction) {
        case SwipeDirection.left:
          widget.onSwipeLeft();
          break;
        case SwipeDirection.right:
          widget.onSwipeRight();
          break;
        case SwipeDirection.up:
          widget.onSwipeUp();
          break;
      }
    });
    _rotationController.forward();
  }

  void _animateBack() {
    _positionAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _positionController, curve: const SpringCurve()),
    );

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / MediaQuery.of(context).size.width * 0.3,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _rotationController, curve: const SpringCurve()),
    );

    _positionController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });
    });
    _rotationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotationAngle =
        _isDragging
            ? _dragOffset.dx / screenWidth * 0.3
            : _rotationAnimation.value;

    return AnimatedBuilder(
      animation: Listenable.merge([_positionController, _rotationController]),
      builder: (context, child) {
        final position = _isDragging ? _dragOffset : _positionAnimation.value;

        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..translate(position.dx, position.dy)
                ..rotateZ(rotationAngle),
          child: GestureDetector(
            onPanStart: widget.index == 0 ? _onPanStart : null,
            onPanUpdate: widget.index == 0 ? _onPanUpdate : null,
            onPanEnd: widget.index == 0 ? _onPanEnd : null,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final opacity = widget.index == 0 ? 1.0 : 0.9 - (widget.index * 0.1);
    final scale = 1.0 - (widget.index * 0.05);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de la carte
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.grey[900],
                  child: Image.network(
                    widget.card.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Overlay avec informations
              if (widget.index == 0) ...[
                // Indicateurs de swipe
                if (_isDragging) _buildSwipeIndicators(),

                // Informations de la carte
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.card.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.card.rarityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.card.rarityColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.card.rarity,
                                style: TextStyle(
                                  color: widget.card.rarityColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (widget.card.inkColor != null) ...[
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.card.inkColorValue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.card.inkColorValue
                                          .withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '${widget.card.set} • ${widget.card.type}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoChip(
                              Icons.water_drop,
                              '${widget.card.inkCost}',
                              Colors.blue,
                            ),
                            if (widget.card.strength != null)
                              _buildInfoChip(
                                Icons.fitness_center,
                                '${widget.card.strength}',
                                Colors.orange,
                              ),
                            if (widget.card.willpower != null)
                              _buildInfoChip(
                                Icons.shield,
                                '${widget.card.willpower}',
                                Colors.red,
                              ),
                            if (widget.card.loreValue != null)
                              _buildInfoChip(
                                Icons.diamond,
                                '${widget.card.loreValue}',
                                Colors.purple,
                              ),
                            _buildPriceChip(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress = _dragOffset.dx.abs() / (screenWidth * 0.3);
    final verticalProgress =
        (_dragOffset.dy / (MediaQuery.of(context).size.height * 0.2)).abs();

    return Stack(
      children: [
        // Indicateur gauche (Rejeter)
        if (_dragOffset.dx < -50)
          Positioned(
            top: 50,
            left: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: progress.clamp(0.0, 1.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Text(
                  'PASS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Indicateur droit (Aimer)
        if (_dragOffset.dx > 50)
          Positioned(
            top: 50,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: progress.clamp(0.0, 1.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Text(
                  'LIKE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Indicateur haut (Super Like)
        if (_dragOffset.dy < -50 && _dragOffset.dy.abs() > _dragOffset.dx.abs())
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: verticalProgress.clamp(0.0, 1.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6BCF7F),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'SUPER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6BCF7F), Color(0xFF4ECDC4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6BCF7F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${widget.card.lowestPrice.toStringAsFixed(2)} €',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Spring physics for bounce back animation
class SpringCurve extends Curve {
  const SpringCurve();

  @override
  double transform(double t) {
    return -math.pow(math.e, -6 * t) * math.cos(10 * t) + 1;
  }
}
