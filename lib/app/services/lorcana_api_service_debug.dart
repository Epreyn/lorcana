import 'package:dio/dio.dart';
import 'dart:convert';

class LorcanaApiServiceDebug {
  static const String baseUrl = 'https://api.lorcana-api.com';
  late Dio _dio;

  LorcanaApiServiceDebug() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Ajouter un intercepteur pour logger les réponses
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Tester différents endpoints pour trouver le bon format
  Future<void> testApiEndpoints() async {
    print('\n=== TEST DES ENDPOINTS API LORCANA ===\n');

    // Liste des endpoints à tester
    final endpoints = [
      '/cards',
      '/bulk/cards',
      '/catalog/cards',
      '/cards/all',
      '/api/cards',
      '/v1/cards',
      '/', // Racine pour voir si il y a une doc
    ];

    for (String endpoint in endpoints) {
      try {
        print('\n--- Test de $endpoint ---');
        final response = await _dio.get(endpoint);

        print('Status: ${response.statusCode}');
        print('Headers: ${response.headers}');

        // Afficher un aperçu de la structure
        if (response.data != null) {
          final dataType = response.data.runtimeType;
          print('Type de données: $dataType');

          if (response.data is Map) {
            print('Clés disponibles: ${response.data.keys.toList()}');

            // Si il y a une clé "data" ou "cards"
            if (response.data.containsKey('data')) {
              print('Structure data: ${response.data['data'].runtimeType}');
              if (response.data['data'] is List &&
                  response.data['data'].isNotEmpty) {
                print(
                  'Premier élément: ${jsonEncode(response.data['data'][0])}',
                );
              }
            }

            if (response.data.containsKey('cards')) {
              print('Structure cards: ${response.data['cards'].runtimeType}');
              if (response.data['cards'] is List &&
                  response.data['cards'].isNotEmpty) {
                print(
                  'Premier élément: ${jsonEncode(response.data['cards'][0])}',
                );
              }
            }
          } else if (response.data is List && response.data.isNotEmpty) {
            print('Nombre d\'éléments: ${response.data.length}');
            print('Premier élément: ${jsonEncode(response.data[0])}');
          }
        }
      } catch (e) {
        print('Erreur sur $endpoint: $e');
      }
    }
  }

  // Méthode pour tester un endpoint spécifique avec des paramètres
  Future<void> testSpecificEndpoint(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    try {
      print('\n=== Test spécifique: $endpoint ===');
      if (params != null) print('Paramètres: $params');

      final response = await _dio.get(endpoint, queryParameters: params);

      // Pretty print de la réponse
      final encoder = JsonEncoder.withIndent('  ');
      String prettyJson;

      if (response.data is List && response.data.length > 3) {
        // Si c'est une longue liste, afficher seulement les 3 premiers
        prettyJson = encoder.convert(response.data.take(3).toList());
        print('Réponse (3 premiers éléments sur ${response.data.length}):');
      } else {
        prettyJson = encoder.convert(response.data);
        print('Réponse complète:');
      }

      print(prettyJson);
    } catch (e, stackTrace) {
      print('Erreur: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
