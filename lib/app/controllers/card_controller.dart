import 'package:get/get.dart';
import '../data/models/card_model.dart';
import '../data/repositories/card_repository.dart';
import 'cart_controller.dart';

class CardController extends GetxController {
  final CardRepository _cardRepository = CardRepository();
  final CartController cartController = Get.find<CartController>();

  final Rx<CardModel?> selectedCard = Rx<CardModel?>(null);
  final RxBool isLoading = false.obs;
  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final String cardId = Get.arguments as String;
    fetchCardDetails(cardId);
  }

  Future<void> fetchCardDetails(String cardId) async {
    try {
      isLoading.value = true;
      final card = await _cardRepository.getCardById(cardId);
      selectedCard.value = card;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les détails');
    } finally {
      isLoading.value = false;
    }
  }

  void incrementQuantity() {
    if (selectedCard.value != null &&
        quantity.value < selectedCard.value!.stockQuantity) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    if (selectedCard.value != null) {
      cartController.addItem(selectedCard.value!, quantity.value);
      Get.snackbar(
        'Succès',
        'Ajouté au panier',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
