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

      return matchesSearch &&
          matchesRarity &&
          matchesSet &&
          matchesInkColor &&
          matchesType &&
          matchesInkCost;
    }).toList();
  }

  // Actions sur les cartes
  void toggleLikeCard(CardModel card) {
    if (likedCards.contains(card)) {
      likedCards.remove(card);
      _showActionFeedback('Retiré des favoris', const Color(0xFFFF4757));
    } else {
      likedCards.add(card);
      _showActionFeedback('Ajouté aux favoris!', const Color(0xFFFF4757));
    }
  }

  void addCardToCart(CardModel card) {
    _cartController.addItem(card, 1);
    _showActionFeedback('Ajouté au panier!', const Color(0xFF6BCF7F));
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
            : Icons.check,
        color: Colors.white,
      ),
    );
  }
}
