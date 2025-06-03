// lib/app/services/mock_api_service.dart
import 'dart:async';
import 'dart:math';
import '../data/models/card_model.dart';
import '../data/models/price_model.dart';
import '../data/models/seller_model.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  final Random _random = Random();

  // Mock des vendeurs
  final List<SellerModel> _mockSellers = [
    SellerModel(
      id: '1',
      name: 'CardMarket',
      logoUrl: 'https://via.placeholder.com/50x50/4CAF50/FFFFFF?text=CM',
      rating: 4.5,
      shippingInfo: 'Livraison 2-3 jours • Frais: 2.99€',
    ),
    SellerModel(
      id: '2',
      name: 'Play-In',
      logoUrl: 'https://via.placeholder.com/50x50/2196F3/FFFFFF?text=PI',
      rating: 4.3,
      shippingInfo: 'Livraison 3-5 jours • Frais: 3.49€',
    ),
    SellerModel(
      id: '3',
      name: 'Magic Bazar',
      logoUrl: 'https://via.placeholder.com/50x50/FF9800/FFFFFF?text=MB',
      rating: 4.7,
      shippingInfo: 'Livraison 1-2 jours • Frais: 4.99€',
    ),
    SellerModel(
      id: '4',
      name: 'Parkage',
      logoUrl: 'https://via.placeholder.com/50x50/9C27B0/FFFFFF?text=PK',
      rating: 4.2,
      shippingInfo: 'Livraison 2-4 jours • Frais: 2.49€',
    ),
  ];

  // Mock des cartes Lorcana
  final List<Map<String, dynamic>> _mockCards = [
    {
      'id': '1',
      'name': 'Elsa - Reine des Neiges',
      'imageUrl': 'https://via.placeholder.com/300x420/E3F2FD/1976D2?text=Elsa',
      'rarity': 'Legendary',
      'set': 'TFC',
      'inkCost': 8,
      'type': 'Personnage',
      'stockQuantity': 3,
    },
    {
      'id': '2',
      'name': 'Mickey Mouse - Brave Petit Tailleur',
      'imageUrl':
          'https://via.placeholder.com/300x420/FFF3E0/F57C00?text=Mickey',
      'rarity': 'Super Rare',
      'set': 'TFC',
      'inkCost': 6,
      'type': 'Personnage',
      'stockQuantity': 8,
    },
    {
      'id': '3',
      'name': 'Maui - Demi-Dieu',
      'imageUrl': 'https://via.placeholder.com/300x420/E8F5E9/388E3C?text=Maui',
      'rarity': 'Rare',
      'set': 'ROF',
      'inkCost': 5,
      'type': 'Personnage',
      'stockQuantity': 15,
    },
    {
      'id': '4',
      'name': 'Raiponce - Cheveux Dorés',
      'imageUrl':
          'https://via.placeholder.com/300x420/FCE4EC/C2185B?text=Raiponce',
      'rarity': 'Uncommon',
      'set': 'ITI',
      'inkCost': 3,
      'type': 'Personnage',
      'stockQuantity': 25,
    },
    {
      'id': '5',
      'name': 'Simba - Roi de la Terre des Lions',
      'imageUrl':
          'https://via.placeholder.com/300x420/FFF8E1/FFA000?text=Simba',
      'rarity': 'Common',
      'set': 'TFC',
      'inkCost': 4,
      'type': 'Personnage',
      'stockQuantity': 30,
    },
    {
      'id': '6',
      'name': 'Ursula - Sorcière des Mers',
      'imageUrl':
          'https://via.placeholder.com/300x420/F3E5F5/7B1FA2?text=Ursula',
      'rarity': 'Legendary',
      'set': 'URR',
      'inkCost': 7,
      'type': 'Personnage - Méchant',
      'stockQuantity': 2,
    },
    {
      'id': '7',
      'name': 'Stitch - Expérience 626',
      'imageUrl':
          'https://via.placeholder.com/300x420/E1F5FE/0277BD?text=Stitch',
      'rarity': 'Rare',
      'set': 'ROF',
      'inkCost': 4,
      'type': 'Personnage',
      'stockQuantity': 12,
    },
    {
      'id': '8',
      'name': 'Ariel - Sirène Rêveuse',
      'imageUrl':
          'https://via.placeholder.com/300x420/E0F2F1/00695C?text=Ariel',
      'rarity': 'Super Rare',
      'set': 'ITI',
      'inkCost': 5,
      'type': 'Personnage - Princesse',
      'stockQuantity': 6,
    },
  ];

  // Générer des prix pour une carte
  List<PriceModel> _generatePricesForCard(String cardId) {
    final basePrice = _random.nextDouble() * 50 + 5; // Prix entre 5€ et 55€

    return _mockSellers.map((seller) {
      final priceVariation = _random.nextDouble() * 0.2 - 0.1; // ±10%
      final price = basePrice * (1 + priceVariation);

      return PriceModel(
        id: '${cardId}_${seller.id}',
        cardId: cardId,
        seller: seller,
        price: double.parse(price.toStringAsFixed(2)),
        currency: 'EUR',
        condition: _random.nextBool() ? 'NM' : 'LP',
        language: _random.nextBool() ? 'FR' : 'EN',
        inStock: _random.nextDouble() > 0.2, // 80% de chance d'être en stock
        updatedAt: DateTime.now().subtract(
          Duration(minutes: _random.nextInt(60)),
        ),
      );
    }).toList();
  }

  // Simuler un délai réseau
  Future<T> _simulateNetworkDelay<T>(T data) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
    return data;
  }

  // API Methods
  Future<List<CardModel>> getCards() async {
    final cards =
        _mockCards.map((cardData) {
          final prices = _generatePricesForCard(cardData['id']);
          return CardModel(
            id: cardData['id'],
            name: cardData['name'],
            imageUrl: cardData['imageUrl'],
            rarity: cardData['rarity'],
            set: cardData['set'],
            inkCost: cardData['inkCost'],
            type: cardData['type'],
            prices: prices,
            stockQuantity: cardData['stockQuantity'],
          );
        }).toList();

    return _simulateNetworkDelay(cards);
  }

  Future<CardModel> getCardById(String id) async {
    final cardData = _mockCards.firstWhere(
      (card) => card['id'] == id,
      orElse: () => throw Exception('Carte non trouvée'),
    );

    final prices = _generatePricesForCard(id);
    final card = CardModel(
      id: cardData['id'],
      name: cardData['name'],
      imageUrl: cardData['imageUrl'],
      rarity: cardData['rarity'],
      set: cardData['set'],
      inkCost: cardData['inkCost'],
      type: cardData['type'],
      prices: prices,
      stockQuantity: cardData['stockQuantity'],
    );

    return _simulateNetworkDelay(card);
  }

  Future<List<PriceModel>> getPricesForCard(String cardId) async {
    final prices = _generatePricesForCard(cardId);
    return _simulateNetworkDelay(prices);
  }

  Future<List<CardModel>> searchCards(String query) async {
    final allCards = await getCards();
    final filteredCards =
        allCards.where((card) {
          return card.name.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return _simulateNetworkDelay(filteredCards);
  }
}
