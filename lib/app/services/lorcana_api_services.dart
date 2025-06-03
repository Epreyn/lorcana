// lib/app/services/lorcana_api_services.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../data/models/card_model.dart';
import '../data/models/price_model.dart';
import 'lorcana_api_adapter.dart';

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
