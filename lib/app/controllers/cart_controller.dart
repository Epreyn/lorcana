import 'package:get/get.dart';
import '../data/models/card_model.dart';
import '../data/models/cart_item_model.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> items = <CartItemModel>[].obs;

  double get totalPrice => items.fold(
    0.0,
    (sum, item) => sum + (item.card.lowestPrice * item.quantity),
  );

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(CardModel card, int quantity) {
    final existingIndex = items.indexWhere((item) => item.card.id == card.id);

    if (existingIndex != -1) {
      final newQuantity = items[existingIndex].quantity + quantity;
      if (newQuantity <= card.stockQuantity) {
        items[existingIndex] = CartItemModel(card: card, quantity: newQuantity);
      } else {
        Get.snackbar('Attention', 'Stock insuffisant');
      }
    } else {
      items.add(CartItemModel(card: card, quantity: quantity));
    }
  }

  void removeItem(String cardId) {
    items.removeWhere((item) => item.card.id == cardId);
  }

  void updateQuantity(String cardId, int newQuantity) {
    final index = items.indexWhere((item) => item.card.id == cardId);
    if (index != -1 && newQuantity > 0) {
      if (newQuantity <= items[index].card.stockQuantity) {
        items[index] = CartItemModel(
          card: items[index].card,
          quantity: newQuantity,
        );
      }
    }
  }

  void clearCart() {
    items.clear();
  }

  Future<void> checkout() async {
    // TODO: Implémenter la logique de paiement
    Get.snackbar('Commande', 'Commande passée avec succès');
    clearCart();
    Get.offAllNamed('/');
  }
}
