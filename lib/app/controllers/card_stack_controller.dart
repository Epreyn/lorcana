import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/card_model.dart';

class CardStackController extends GetxController {
  final List<CardModel> cards;
  late PageController pageController;
  double currentPage = 0;
  final RxMap<int, bool> flippedCards = <int, bool>{}.obs;

  CardStackController(this.cards);

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.8);
    pageController.addListener(() {
      currentPage = pageController.page ?? 0;
      update();
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage = index.toDouble();
    update();
  }

  void flipCard(int index) {
    flippedCards[index] = !(flippedCards[index] ?? false);
  }

  bool isCardFlipped(int index) {
    return flippedCards[index] ?? false;
  }
}
