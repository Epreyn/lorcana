import 'package:get/get.dart';
import '../data/models/price_model.dart';
import '../data/models/card_model.dart';
import '../data/repositories/price_repository.dart';

class PriceComparisonController extends GetxController {
  final PriceRepository _priceRepository = PriceRepository();

  final RxList<PriceModel> prices = <PriceModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<CardModel?> currentCard = Rx<CardModel?>(null);

  Future<void> fetchPricesForCard(String cardId, {CardModel? card}) async {
    try {
      isLoading.value = true;
      currentCard.value = card;

      // Récupérer les prix (simulés pour l'instant)
      final fetchedPrices = await _priceRepository.getPricesForCard(
        cardId,
        card: card,
      );

      // Trier par prix croissant
      prices.value = fetchedPrices..sort((a, b) => a.price.compareTo(b.price));

      if (prices.isEmpty && card != null) {
        Get.snackbar(
          'Information',
          'Les prix seront bientôt disponibles pour ${card.name}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Erreur lors du chargement des prix: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les prix pour le moment',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  PriceModel? get bestPrice => prices.isNotEmpty ? prices.first : null;

  void refreshPrices() {
    if (currentCard.value != null) {
      _priceRepository.updatePrices(currentCard.value!.id);
      fetchPricesForCard(currentCard.value!.id, card: currentCard.value);
    }
  }

  @override
  void onClose() {
    // Nettoyer si nécessaire
    super.onClose();
  }
}
