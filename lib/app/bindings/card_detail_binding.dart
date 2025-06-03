import 'package:get/get.dart';
import '../controllers/card_controller.dart';
import '../controllers/price_comparison_controller.dart';

class CardDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CardController>(() => CardController());
    Get.lazyPut<PriceComparisonController>(() => PriceComparisonController());
  }
}
