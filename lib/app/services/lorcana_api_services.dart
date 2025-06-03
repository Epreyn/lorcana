import 'dart:convert';

import 'package:dio/dio.dart';
import '../data/models/card_model.dart';
import '../data/models/price_model.dart';

class LorcanaApiService {
  static const String baseUrl = 'https://api.lorcana-api.com';
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
      print('Appel API: $baseUrl/bulk/cards');
      final response = await _dio.get('/bulk/cards');

      print('Type de réponse: ${response.data.runtimeType}');
      print('Status code: ${response.statusCode}');

      // Si c'est une String, essayons de la parser
      if (response.data is String) {
        print('Réponse est une String, tentative de parsing JSON...');
        try {
          final parsed = json.decode(response.data);
          if (parsed is List) {
            print('Parsing réussi, ${parsed.length} cartes trouvées');
            return List<Map<String, dynamic>>.from(parsed);
          }
        } catch (e) {
          print('Erreur de parsing JSON: $e');
          print('Contenu de la réponse: ${response.data}');
        }
      }

      // L'API retourne directement une liste
      if (response.data is List) {
        print('Réponse est une List avec ${response.data.length} éléments');
        return List<Map<String, dynamic>>.from(response.data);
      }

      print('Format de réponse inattendu: ${response.data.runtimeType}');
      print('Contenu: ${response.data}');
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des cartes: $e');
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
    // Debug : afficher les clés disponibles
    if (apiData.isNotEmpty) {
      print('Clés disponibles dans apiData: ${apiData.keys.toList()}');
    }

    // Extraire l'ID de différentes façons possibles
    final id =
        (apiData['id'] ??
                apiData['unique_id'] ??
                apiData['card_id'] ??
                apiData['number'] ??
                DateTime.now().millisecondsSinceEpoch)
            .toString();

    // Nom - la clé est "Name"
    String name = apiData['Name'] ?? apiData['name'] ?? 'Carte inconnue';

    // URL de l'image - la clé est "Image"
    String imageUrl = apiData['Image'] ?? apiData['image'] ?? '';
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://via.placeholder.com/300x420/E3F2FD/1976D2?text=Lorcana';
    }

    // Rareté - la clé est "Rarity"
    String rarity =
        (apiData['Rarity'] ?? apiData['rarity'] ?? 'Common').toString();
    rarity = _normalizeRarity(rarity);

    // Set - la clé est "Set_ID"
    String set =
        apiData['Set_ID'] ?? apiData['Set_Name'] ?? apiData['set'] ?? 'Unknown';
    set = _normalizeSetCode(set);

    // Coût en encre - la clé est "Cost"
    final inkCost = _extractNumber(apiData['Cost'] ?? apiData['cost'] ?? 0);

    // Type - la clé est "Type"
    String type = apiData['Type'] ?? apiData['type'] ?? 'Unknown';

    // Debug : afficher ce qui a été extrait
    print('Carte convertie: $name (ID: $id, Set: $set, Type: $type)');

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
