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

  // Mock des cartes Lorcana amélioré
  final List<Map<String, dynamic>> _mockCards = [
    {
      'id': '1',
      'name': 'Elsa',
      'version': 'Reine des Neiges',
      'imageUrl': 'https://via.placeholder.com/300x420/E3F2FD/1976D2?text=Elsa',
      'rarity': 'Legendary',
      'set': 'The First Chapter',
      'setCode': 'TFC',
      'inkCost': 8,
      'type': 'Personnage - Reine - Héros',
      'classifications': ['Reine', 'Héros', 'Storyborn'],
      'inkColor': 'Sapphire',
      'strength': 5,
      'willpower': 6,
      'loreValue': 3,
      'abilities':
          'Lorsque vous jouez ce personnage, tous vos personnages Reine des Neiges gagnent +2 Force ce tour.',
      'stockQuantity': 3,
      'inkable': true,
    },
    {
      'id': '2',
      'name': 'Mickey Mouse',
      'version': 'Brave Petit Tailleur',
      'imageUrl':
          'https://via.placeholder.com/300x420/FFF3E0/F57C00?text=Mickey',
      'rarity': 'Super Rare',
      'set': 'The First Chapter',
      'setCode': 'TFC',
      'inkCost': 6,
      'type': 'Personnage - Héros - Souris',
      'classifications': ['Héros', 'Souris', 'Dreamborn'],
      'inkColor': 'Amber',
      'strength': 4,
      'willpower': 5,
      'loreValue': 2,
      'abilities':
          'Défi +3 (Lorsque ce personnage défie, il gagne +3 Force ce tour.)',
      'stockQuantity': 8,
      'inkable': false,
    },
    {
      'id': '3',
      'name': 'Maui',
      'version': 'Demi-Dieu',
      'imageUrl': 'https://via.placeholder.com/300x420/E8F5E9/388E3C?text=Maui',
      'rarity': 'Rare',
      'set': 'Rise of the Floodborn',
      'setCode': 'ROF',
      'inkCost': 5,
      'type': 'Personnage - Héros - Divinité',
      'classifications': ['Héros', 'Divinité', 'Floodborn'],
      'inkColor': 'Emerald',
      'strength': 6,
      'willpower': 4,
      'loreValue': 2,
      'abilities': 'Rush (Ce personnage peut défier le tour où il est joué.)',
      'stockQuantity': 15,
      'inkable': true,
    },
    {
      'id': '4',
      'name': 'Raiponce',
      'version': 'Cheveux Dorés',
      'imageUrl':
          'https://via.placeholder.com/300x420/FCE4EC/C2185B?text=Raiponce',
      'rarity': 'Uncommon',
      'set': 'Into the Inklands',
      'setCode': 'ITI',
      'inkCost': 3,
      'type': 'Personnage - Princesse',
      'classifications': ['Princesse', 'Storyborn'],
      'inkColor': 'Amethyst',
      'strength': 2,
      'willpower': 4,
      'loreValue': 1,
      'abilities':
          'Soutien (Lorsque ce personnage est banni en défiant, vous pouvez piocher une carte.)',
      'stockQuantity': 25,
      'inkable': true,
    },
    {
      'id': '5',
      'name': 'Simba',
      'version': 'Roi de la Terre des Lions',
      'imageUrl':
          'https://via.placeholder.com/300x420/FFF8E1/FFA000?text=Simba',
      'rarity': 'Common',
      'set': 'The First Chapter',
      'setCode': 'TFC',
      'inkCost': 4,
      'type': 'Personnage - Roi - Lion',
      'classifications': ['Roi', 'Lion', 'Storyborn'],
      'inkColor': 'Amber',
      'strength': 4,
      'willpower': 3,
      'loreValue': 2,
      'stockQuantity': 30,
      'inkable': true,
    },
    {
      'id': '6',
      'name': 'Ursula',
      'version': 'Sorcière des Mers',
      'imageUrl':
          'https://via.placeholder.com/300x420/F3E5F5/7B1FA2?text=Ursula',
      'rarity': 'Legendary',
      'set': 'Ursula\'s Return',
      'setCode': 'URR',
      'inkCost': 7,
      'type': 'Personnage - Sorcière - Méchant',
      'classifications': ['Sorcière', 'Méchant', 'Dreamborn'],
      'inkColor': 'Amethyst',
      'strength': 4,
      'willpower': 7,
      'loreValue': 2,
      'abilities':
          'Contrat maudit - Lorsque ce personnage est joué, bannissez un personnage adverse avec un coût de 3 ou moins.',
      'flavorText': '"Les idiots mortels sont si faciles à manipuler."',
      'stockQuantity': 2,
      'inkable': false,
    },
    {
      'id': '7',
      'name': 'Stitch',
      'version': 'Expérience 626',
      'imageUrl':
          'https://via.placeholder.com/300x420/E1F5FE/0277BD?text=Stitch',
      'rarity': 'Rare',
      'set': 'Rise of the Floodborn',
      'setCode': 'ROF',
      'inkCost': 4,
      'type': 'Personnage - Alien - Héros',
      'classifications': ['Alien', 'Héros', 'Floodborn'],
      'inkColor': 'Sapphire',
      'strength': 3,
      'willpower': 5,
      'loreValue': 1,
      'abilities':
          'Évasif (Seuls les personnages avec Évasif peuvent défier ce personnage.)',
      'stockQuantity': 12,
      'inkable': true,
    },
    {
      'id': '8',
      'name': 'Ariel',
      'version': 'Sirène Rêveuse',
      'imageUrl':
          'https://via.placeholder.com/300x420/E0F2F1/00695C?text=Ariel',
      'rarity': 'Super Rare',
      'set': 'Into the Inklands',
      'setCode': 'ITI',
      'inkCost': 5,
      'type': 'Personnage - Princesse - Sirène',
      'classifications': ['Princesse', 'Sirène', 'Storyborn'],
      'inkColor': 'Emerald',
      'strength': 3,
      'willpower': 4,
      'loreValue': 2,
      'abilities':
          'Chanteuse (Ce personnage compte comme ayant un coût de 5 de plus pour vos chansons.)',
      'flavorText': '"Je veux être là où vivent les humains..."',
      'stockQuantity': 6,
      'inkable': true,
    },
    {
      'id': '9',
      'name': 'Hadès',
      'version': 'Seigneur des Enfers',
      'imageUrl':
          'https://via.placeholder.com/300x420/424242/FF5252?text=Hades',
      'rarity': 'Legendary',
      'set': 'Shimmering Skies',
      'setCode': 'SSK',
      'inkCost': 8,
      'type': 'Personnage - Dieu - Méchant',
      'classifications': ['Dieu', 'Méchant', 'Dreamborn'],
      'inkColor': 'Ruby',
      'strength': 7,
      'willpower': 7,
      'loreValue': 3,
      'abilities':
          'Flamme éternelle - Ce personnage ne peut pas être banni par des dégâts.',
      'stockQuantity': 1,
      'inkable': false,
    },
    {
      'id': '10',
      'name': 'Belle',
      'version': 'Lectrice Passionnée',
      'imageUrl':
          'https://via.placeholder.com/300x420/FFF9C4/FFB300?text=Belle',
      'rarity': 'Common',
      'set': 'The First Chapter',
      'setCode': 'TFC',
      'inkCost': 2,
      'type': 'Personnage - Princesse',
      'classifications': ['Princesse', 'Storyborn'],
      'inkColor': 'Amber',
      'strength': 1,
      'willpower': 3,
      'loreValue': 1,
      'abilities': 'Lorsque vous jouez ce personnage, piochez une carte.',
      'stockQuantity': 40,
      'inkable': true,
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
            version: cardData['version'],
            imageUrl: cardData['imageUrl'],
            rarity: cardData['rarity'],
            set: cardData['set'],
            setCode: cardData['setCode'],
            inkCost: cardData['inkCost'],
            type: cardData['type'],
            classifications:
                cardData['classifications'] != null
                    ? List<String>.from(cardData['classifications'])
                    : null,
            inkColor: cardData['inkColor'],
            strength: cardData['strength'],
            willpower: cardData['willpower'],
            loreValue: cardData['loreValue'],
            abilities: cardData['abilities'],
            flavorText: cardData['flavorText'],
            artist: cardData['artist'],
            collectorNumber: cardData['collectorNumber'],
            inkable: cardData['inkable'] ?? true,
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
      version: cardData['version'],
      imageUrl: cardData['imageUrl'],
      rarity: cardData['rarity'],
      set: cardData['set'],
      setCode: cardData['setCode'],
      inkCost: cardData['inkCost'],
      type: cardData['type'],
      classifications:
          cardData['classifications'] != null
              ? List<String>.from(cardData['classifications'])
              : null,
      inkColor: cardData['inkColor'],
      strength: cardData['strength'],
      willpower: cardData['willpower'],
      loreValue: cardData['loreValue'],
      abilities: cardData['abilities'],
      flavorText: cardData['flavorText'],
      artist: cardData['artist'],
      collectorNumber: cardData['collectorNumber'],
      inkable: cardData['inkable'] ?? true,
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
          final searchStr = query.toLowerCase();
          return card.name.toLowerCase().contains(searchStr) ||
              (card.version?.toLowerCase().contains(searchStr) ?? false) ||
              card.type.toLowerCase().contains(searchStr) ||
              (card.inkColor?.toLowerCase().contains(searchStr) ?? false);
        }).toList();

    return _simulateNetworkDelay(filteredCards);
  }
}
