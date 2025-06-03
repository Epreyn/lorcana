import 'package:dio/dio.dart';
import '../data/models/card_model.dart';
import '../data/models/price_model.dart';

class LorcanaApiService {
  static const String baseUrl = 'https://lorcana-api.com/api/v1';
  late Dio _dio;

  LorcanaApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // Récupérer toutes les cartes
  Future<List<Map<String, dynamic>>> fetchAllCards() async {
    try {
      // L'API lorcana-api.com utilise /cards pour obtenir toutes les cartes
      final response = await _dio.get('/cards');

      // Gérer différents formats de réponse possibles
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map) {
        // Si c'est un objet, chercher les clés communes
        if (response.data.containsKey('cards')) {
          return List<Map<String, dynamic>>.from(response.data['cards']);
        } else if (response.data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(response.data['data']);
        } else if (response.data.containsKey('results')) {
          return List<Map<String, dynamic>>.from(response.data['results']);
        }
      }

      print('Format de réponse inattendu: ${response.data.runtimeType}');
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des cartes: $e');
      // Essayons avec un endpoint alternatif
      try {
        final response = await _dio.get('/bulk');
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        }
      } catch (e2) {
        print('Erreur avec endpoint alternatif: $e2');
      }
      throw Exception(
        'Impossible de récupérer les cartes depuis l\'API Lorcana',
      );
    }
  }

  // Récupérer une carte par ID ou nom
  Future<Map<String, dynamic>> fetchCardByIdOrName(String identifier) async {
    try {
      // Essayer d'abord par ID
      final response = await _dio.get('/cards/$identifier');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      // Si ça échoue, essayer par nom
      try {
        final response = await _dio.get('/cards/fetch?name=$identifier');
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data);
        } else if (response.data is List && response.data.isNotEmpty) {
          return Map<String, dynamic>.from(response.data[0]);
        }
      } catch (e2) {
        print('Erreur lors de la récupération de la carte $identifier: $e2');
      }
      throw Exception('Carte introuvable');
    }
  }

  // Rechercher des cartes
  Future<List<Map<String, dynamic>>> searchCards(String query) async {
    try {
      // Utiliser l'endpoint de recherche de l'API
      final response = await _dio.get(
        '/cards/search',
        queryParameters: {'name': query},
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data['results'] != null) {
        return List<Map<String, dynamic>>.from(response.data['results']);
      }

      // Si ça ne marche pas, essayer une recherche manuelle
      final allCards = await fetchAllCards();
      return allCards.where((card) {
        final name = (card['name'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // Récupérer les sets disponibles
  Future<List<Map<String, dynamic>>> fetchSets() async {
    try {
      final response = await _dio.get('/sets');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data['sets'] != null) {
        return List<Map<String, dynamic>>.from(response.data['sets']);
      }

      return [];
    } catch (e) {
      print('Erreur lors de la récupération des sets: $e');
      return [];
    }
  }
}

// Adaptateur pour convertir les données de l'API vers notre modèle
class LorcanaApiAdapter {
  static CardModel fromApiResponse(
    Map<String, dynamic> apiData, {
    List<PriceModel>? prices,
  }) {
    // Extraire l'ID de différentes façons possibles
    final id =
        (apiData['id'] ??
                apiData['unique_id'] ??
                apiData['card_id'] ??
                apiData['number'] ??
                DateTime.now().millisecondsSinceEpoch)
            .toString();

    // Extraire le nom complet
    String name = apiData['name'] ?? 'Carte inconnue';
    if (apiData['version'] != null &&
        apiData['version'].toString().isNotEmpty) {
      name += ' - ${apiData['version']}';
    } else if (apiData['title'] != null &&
        apiData['title'].toString().isNotEmpty) {
      name += ' - ${apiData['title']}';
    }

    // Extraire l'URL de l'image
    String imageUrl = '';
    if (apiData['image_uris'] != null && apiData['image_uris'] is Map) {
      final images = apiData['image_uris'];
      // Préférer les images digitales
      if (images['digital'] != null && images['digital'] is Map) {
        imageUrl =
            images['digital']['large'] ??
            images['digital']['normal'] ??
            images['digital']['small'] ??
            '';
      }
      // Sinon prendre n'importe quelle image disponible
      if (imageUrl.isEmpty) {
        imageUrl = images['large'] ?? images['normal'] ?? images['small'] ?? '';
      }
    } else if (apiData['image'] != null) {
      imageUrl = apiData['image'];
    } else if (apiData['images'] != null && apiData['images'] is Map) {
      final images = apiData['images'];
      imageUrl = images['large'] ?? images['medium'] ?? images['small'] ?? '';
    }

    // Image par défaut si aucune n'est trouvée
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://via.placeholder.com/300x420/E3F2FD/1976D2?text=Lorcana';
    }

    // Extraire la rareté
    String rarity = (apiData['rarity'] ?? 'Common').toString();
    rarity = _normalizeRarity(rarity);

    // Extraire le set
    String set = '';
    if (apiData['set'] != null && apiData['set'] is Map) {
      set = apiData['set']['code'] ?? apiData['set']['name'] ?? '';
    } else {
      set = apiData['set_code'] ?? apiData['set_name'] ?? apiData['set'] ?? '';
    }
    set = _normalizeSetCode(set);

    // Extraire le coût en encre
    final inkCost = _extractNumber(apiData['cost'] ?? apiData['ink_cost'] ?? 0);

    // Extraire le type
    String type = '';
    if (apiData['type'] is List) {
      type = (apiData['type'] as List).join(' - ');
    } else {
      type = apiData['type']?.toString() ?? '';
    }

    // Ajouter les classifications si disponibles
    if (apiData['classifications'] != null &&
        apiData['classifications'] is List) {
      final classifications = (apiData['classifications'] as List).join(', ');
      if (classifications.isNotEmpty) {
        type += type.isEmpty ? classifications : ' - $classifications';
      }
    }

    return CardModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      rarity: rarity,
      set: set,
      inkCost: inkCost,
      type: type.isEmpty ? 'Unknown' : type,
      prices: prices ?? [],
      stockQuantity: 10, // Valeur par défaut
    );
  }

  static String _normalizeRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
      case 'c':
        return 'Common';
      case 'uncommon':
      case 'uc':
      case 'u':
        return 'Uncommon';
      case 'rare':
      case 'r':
        return 'Rare';
      case 'super rare':
      case 'super_rare':
      case 'sr':
        return 'Super Rare';
      case 'legendary':
      case 'l':
        return 'Legendary';
      case 'enchanted':
      case 'e':
        return 'Enchanted';
      default:
        return 'Common';
    }
  }

  static String _normalizeSetCode(String set) {
    // Mapping des codes de sets Lorcana
    final setMap = {
      '1': 'TFC',
      'tfc': 'TFC',
      'the first chapter': 'TFC',
      '2': 'ROF',
      'rof': 'ROF',
      'rise of the floodborn': 'ROF',
      '3': 'ITI',
      'iti': 'ITI',
      'into the inklands': 'ITI',
      '4': 'URR',
      'urr': 'URR',
      'ursula\'s return': 'URR',
      '5': 'SSK',
      'ssk': 'SSK',
      'shimmering skies': 'SSK',
      '6': 'AZU',
      'azu': 'AZU',
      'azurite sea': 'AZU',
    };

    final normalizedSet = set.toLowerCase();
    return setMap[normalizedSet] ?? set.toUpperCase();
  }

  static int _extractNumber(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
