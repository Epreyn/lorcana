import 'package:get/get.dart';
import '../data/models/card_model.dart';
import '../data/repositories/card_repository.dart';

class HomeController extends GetxController {
  final CardRepository _cardRepository = CardRepository();

  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedRarity = Rx<String?>(null);
  final Rx<String?> selectedSet = Rx<String?>(null);
  final RxBool isGridView = true.obs;

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
      Get.snackbar('Erreur', 'Impossible de charger les cartes');
    } finally {
      isLoading.value = false;
    }
  }

  List<CardModel> get filteredCards {
    return cards.where((card) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          card.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesRarity =
          selectedRarity.value == null || card.rarity == selectedRarity.value;
      final matchesSet =
          selectedSet.value == null || card.set == selectedSet.value;

      return matchesSearch && matchesRarity && matchesSet;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void filterByRarity(String? rarity) {
    selectedRarity.value = rarity;
  }

  void filterBySet(String? set) {
    selectedSet.value = set;
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void clearFilters() {
    selectedRarity.value = null;
    selectedSet.value = null;
    searchQuery.value = '';
  }
}
