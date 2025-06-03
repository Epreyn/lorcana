// lib/app/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/card_model.dart';
import '../data/repositories/card_repository.dart';
import 'cart_controller.dart';

class HomeController extends GetxController {
  final CardRepository _cardRepository = CardRepository();
  final CartController _cartController = Get.find<CartController>();

  // Données
  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxList<CardModel> likedCards = <CardModel>[].obs;
  final RxList<CardModel> rejectedCards = <CardModel>[].obs;
  final RxList<CardModel> superLikedCards = <CardModel>[].obs;

  // États
  final RxBool isLoading = false.obs;
  final RxBool showAdvancedFilters = false.obs;
  final RxBool isSearchActive = false.obs;

  // Filtres
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedRarity = Rx<String?>(null);
  final Rx<String?> selectedSet = Rx<String?>(null);
  final RxList<String> selectedInkColors = <String>[].obs;
  final RxList<String> selectedTypes = <String>[].obs;
  final Rx<RangeValues> inkCostRange = Rx<RangeValues>(
    const RangeValues(0, 10),
  );

  // Navigation
  final RxInt currentCardIndex = 0.obs;
  CardModel? lastActionCard;
  String? lastAction;

  @override
  void onInit() {
    super.onInit();
    fetchCards();
  }

  Future<void> fetchCards() async {
    try {
      isLoading.value = true;
      final fetchedCards = await _cardRepository.getCards();
      cards.value = fetchedCards;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les cartes',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<CardModel> get filteredCards {
    return cards.where((card) {
      // Filtre par recherche
      final matchesSearch =
          searchQuery.value.isEmpty ||
          card.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (card.version?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);

      // Filtre par rareté
      final matchesRarity =
          selectedRarity.value == null || card.rarity == selectedRarity.value;

      // Filtre par set
      final matchesSet =
          selectedSet.value == null || card.setCode == selectedSet.value;

      // Filtre par couleur d'encre
      final matchesInkColor =
          selectedInkColors.isEmpty ||
          (card.inkColor != null && selectedInkColors.contains(card.inkColor));

      // Filtre par type
      final matchesType =
          selectedTypes.isEmpty ||
          selectedTypes.any((type) => card.type.contains(type));

      // Filtre par coût en encre
      final matchesInkCost =
          card.inkCost >= inkCostRange.value.start &&
          card.inkCost <= inkCostRange.value.end;

      // Exclure les cartes déjà swipées
      final notSwiped =
          !likedCards.contains(card) &&
          !rejectedCards.contains(card) &&
          !superLikedCards.contains(card);

      return matchesSearch &&
          matchesRarity &&
          matchesSet &&
          matchesInkColor &&
          matchesType &&
          matchesInkCost &&
          notSwiped;
    }).toList();
  }

  // Actions de swipe
  void onCardLiked(CardModel card) {
    likedCards.add(card);
    lastActionCard = card;
    lastAction = 'liked';
    _showActionFeedback('Ajouté aux favoris!', const Color(0xFF4ECDC4));
  }

  void onCardRejected(CardModel card) {
    rejectedCards.add(card);
    lastActionCard = card;
    lastAction = 'rejected';
  }

  void onCardSuperLiked(CardModel card) {
    superLikedCards.add(card);
    _cartController.addItem(card, 1);
    lastActionCard = card;
    lastAction = 'superLiked';
    _showActionFeedback('Ajouté au panier!', const Color(0xFF6BCF7F));
  }

  void likeCurrentCard() {
    final cards = filteredCards;
    if (cards.isNotEmpty) {
      onCardLiked(cards.first);
    }
  }

  void rejectCurrentCard() {
    final cards = filteredCards;
    if (cards.isNotEmpty) {
      onCardRejected(cards.first);
    }
  }

  void superLikeCurrentCard() {
    final cards = filteredCards;
    if (cards.isNotEmpty) {
      onCardSuperLiked(cards.first);
    }
  }

  void boostCurrentCard() {
    final cards = filteredCards;
    if (cards.isNotEmpty) {
      Get.toNamed('/card-detail', arguments: cards.first.id);
    }
  }

  void undoLastAction() {
    if (lastActionCard == null || lastAction == null) return;

    switch (lastAction) {
      case 'liked':
        likedCards.remove(lastActionCard);
        break;
      case 'rejected':
        rejectedCards.remove(lastActionCard);
        break;
      case 'superLiked':
        superLikedCards.remove(lastActionCard);
        // Note: On ne retire pas du panier ici
        break;
    }

    lastActionCard = null;
    lastAction = null;
    _showActionFeedback('Action annulée', const Color(0xFFFFD93D));
  }

  // Gestion des filtres
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void filterByRarity(String? rarity) {
    selectedRarity.value = rarity;
  }

  void filterBySet(String? set) {
    selectedSet.value = set;
  }

  void toggleInkColor(String color) {
    if (selectedInkColors.contains(color)) {
      selectedInkColors.remove(color);
    } else {
      selectedInkColors.add(color);
    }
  }

  void toggleType(String type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }
  }

  void clearInkColors() {
    selectedInkColors.clear();
  }

  void clearAllFilters() {
    selectedRarity.value = null;
    selectedSet.value = null;
    selectedInkColors.clear();
    selectedTypes.clear();
    inkCostRange.value = const RangeValues(0, 10);
    searchQuery.value = '';
  }

  bool get hasAdvancedFilters {
    return selectedTypes.isNotEmpty ||
        inkCostRange.value.start > 0 ||
        inkCostRange.value.end < 10;
  }

  // UI helpers
  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchQuery.value = '';
    }
  }

  int get cartItemsCount => _cartController.totalItems;

  void _showActionFeedback(String message, Color color) {
    Get.snackbar(
      '',
      message,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      borderRadius: 30,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      snackPosition: SnackPosition.TOP,
      icon: Icon(
        message.contains('panier')
            ? Icons.shopping_cart
            : message.contains('favoris')
            ? Icons.favorite
            : Icons.undo,
        color: Colors.white,
      ),
    );
  }

  // Statistiques
  Map<String, int> get swipeStats => {
    'liked': likedCards.length,
    'rejected': rejectedCards.length,
    'superLiked': superLikedCards.length,
    'remaining': filteredCards.length,
  };
}
