import 'dart:math';
import '../data/models/price_model.dart';
import '../data/models/seller_model.dart';
import '../data/models/card_model.dart';

class PriceSimulationService {
  static final PriceSimulationService _instance =
      PriceSimulationService._internal();
  factory PriceSimulationService() => _instance;
  PriceSimulationService._internal();

  final Random _random = Random();

  // Vendeurs populaires en France pour les cartes TCG
  final List<SellerModel> _sellers = [
    SellerModel(
      id: '1',
      name: 'Cardmarket Pro Seller',
      logoUrl: 'https://static.cardmarket.com/img/logos/logo_cm_blue.png',
      rating: 4.8,
      shippingInfo: 'Envoi suivi • 2-3 jours • Gratuit dès 50€',
    ),
    SellerModel(
      id: '2',
      name: 'Magic Bazar',
      logoUrl: 'https://via.placeholder.com/50x50/FF6B00/FFFFFF?text=MB',
      rating: 4.6,
      shippingInfo: 'Envoi 24h • Gratuit dès 100€',
    ),
    SellerModel(
      id: '3',
      name: 'Play-In Store',
      logoUrl: 'https://via.placeholder.com/50x50/2196F3/FFFFFF?text=PI',
      rating: 4.5,
      shippingInfo: 'Envoi 48h • Gratuit dès 75€',
    ),
    SellerModel(
      id: '4',
      name: 'Parkage',
      logoUrl: 'https://via.placeholder.com/50x50/9C27B0/FFFFFF?text=PK',
      rating: 4.3,
      shippingInfo: 'Envoi standard • 3-5 jours',
    ),
    SellerModel(
      id: '5',
      name: 'UltraJeux',
      logoUrl: 'https://via.placeholder.com/50x50/4CAF50/FFFFFF?text=UJ',
      rating: 4.7,
      shippingInfo: 'Envoi rapide • Protection renforcée',
    ),
    SellerModel(
      id: '6',
      name: 'CartaMundi',
      logoUrl: 'https://via.placeholder.com/50x50/E91E63/FFFFFF?text=CM',
      rating: 4.4,
      shippingInfo: 'Livraison internationale disponible',
    ),
  ];

  // Calculer le prix de base selon les caractéristiques de la carte
  double _calculateBasePrice(CardModel card) {
    double basePrice = 5.0;

    // Prix selon la rareté
    switch (card.rarity.toLowerCase()) {
      case 'common':
        basePrice = 0.5 + _random.nextDouble() * 1.5; // 0.50€ - 2€
        break;
      case 'uncommon':
        basePrice = 2.0 + _random.nextDouble() * 3.0; // 2€ - 5€
        break;
      case 'rare':
        basePrice = 5.0 + _random.nextDouble() * 10.0; // 5€ - 15€
        break;
      case 'super rare':
        basePrice = 15.0 + _random.nextDouble() * 20.0; // 15€ - 35€
        break;
      case 'legendary':
        basePrice = 30.0 + _random.nextDouble() * 40.0; // 30€ - 70€
        break;
      case 'enchanted':
        basePrice = 80.0 + _random.nextDouble() * 120.0; // 80€ - 200€
        break;
    }

    // Modificateurs selon le set
    switch (card.set) {
      case 'TFC': // First Chapter - Plus ancien, peut être plus cher
        basePrice *= 1.2;
        break;
      case 'URR': // Ursula's Return - Plus récent
        basePrice *= 0.95;
        break;
    }

    // Modificateur selon le coût en encre (cartes plus chères = souvent plus rares)
    if (card.inkCost >= 7) {
      basePrice *= 1.15;
    }

    // Modificateur pour les personnages populaires
    final popularCharacters = ['Elsa', 'Mickey', 'Stitch', 'Maui', 'Ursula'];
    if (popularCharacters.any((char) => card.name.contains(char))) {
      basePrice *= 1.25;
    }

    return basePrice;
  }

  Future<List<PriceModel>> generatePricesForCard(CardModel card) async {
    // Simuler un délai réseau
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

    final basePrice = _calculateBasePrice(card);
    final List<PriceModel> prices = [];

    // Générer des prix pour chaque vendeur
    for (var seller in _sellers) {
      // Variation de prix entre vendeurs (±15%)
      final priceVariation = (_random.nextDouble() * 0.3) - 0.15;
      final sellerPrice = basePrice * (1 + priceVariation);

      // Conditions disponibles
      final conditions = ['NM', 'LP', 'MP'];
      final selectedConditions =
          _random.nextBool()
              ? [conditions[0]] // 50% n'ont que du NM
              : conditions.sublist(
                0,
                _random.nextInt(2) + 1,
              ); // Les autres ont plusieurs conditions

      for (String condition in selectedConditions) {
        // Prix selon la condition
        double conditionMultiplier = 1.0;
        switch (condition) {
          case 'LP':
            conditionMultiplier = 0.85;
            break;
          case 'MP':
            conditionMultiplier = 0.70;
            break;
        }

        final finalPrice = sellerPrice * conditionMultiplier;

        // Langues disponibles
        final languages = ['FR', 'EN'];
        final selectedLanguage =
            _random.nextDouble() > 0.3 ? 'FR' : 'EN'; // 70% FR

        // Ajustement prix selon la langue (EN souvent moins cher)
        final languageMultiplier = selectedLanguage == 'EN' ? 0.9 : 1.0;

        prices.add(
          PriceModel(
            id: '${card.id}_${seller.id}_${condition}_$selectedLanguage',
            cardId: card.id,
            seller: seller,
            price: double.parse(
              (finalPrice * languageMultiplier).toStringAsFixed(2),
            ),
            currency: 'EUR',
            condition: condition,
            language: selectedLanguage,
            inStock: _random.nextDouble() > 0.15, // 85% en stock
            updatedAt: DateTime.now().subtract(
              Duration(minutes: _random.nextInt(60)),
            ),
          ),
        );
      }
    }

    // Trier par prix croissant
    prices.sort((a, b) => a.price.compareTo(b.price));

    // S'assurer qu'il y a au moins 3-4 offres
    return prices.take(8).toList(); // Maximum 8 offres pour ne pas surcharger
  }

  // Méthode pour simuler une mise à jour des prix
  Future<List<PriceModel>> updatePrices(List<PriceModel> currentPrices) async {
    await Future.delayed(const Duration(seconds: 1));

    return currentPrices.map((price) {
        // Petite variation de prix (±2%)
        final variation = (_random.nextDouble() * 0.04) - 0.02;
        final newPrice = price.price * (1 + variation);

        // Possibilité de changement de stock
        final newInStock =
            _random.nextDouble() > 0.1 ? price.inStock : !price.inStock;

        return PriceModel(
          id: price.id,
          cardId: price.cardId,
          seller: price.seller,
          price: double.parse(newPrice.toStringAsFixed(2)),
          currency: price.currency,
          condition: price.condition,
          language: price.language,
          inStock: newInStock,
          updatedAt: DateTime.now(),
        );
      }).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
  }
}
