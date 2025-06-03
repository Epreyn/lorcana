import 'package:get/get.dart';
import '../data/models/price_model.dart';
import '../data/repositories/price_repository.dart';

class PriceComparisonController extends GetxController {
  final PriceRepository _priceRepository = PriceRepository();

  final RxList<PriceModel> prices = <PriceModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchPricesForCard(String cardId) async {
    try {
      isLoading.value = true;
      final fetchedPrices = await _priceRepository.getPricesForCard(cardId);
      prices.value = fetchedPrices..sort((a, b) => a.price.compareTo(b.price));
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les prix');
    } finally {
      isLoading.value = false;
    }
  }

  PriceModel? get bestPrice => prices.isNotEmpty ? prices.first : null;
}
