import 'package:get/get.dart';
import '../modules/home/views/home_view.dart';
import '../modules/card_detail/views/card_detail_view.dart';
import '../modules/cart/views/cart_view.dart';
import '../bindings/home_binding.dart';
import '../bindings/card_detail_binding.dart';
import '../bindings/cart_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CARD_DETAIL,
      page: () => const CardDetailView(),
      binding: CardDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
  ];
}
