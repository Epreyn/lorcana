import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../data/models/price_model.dart';
import '../data/models/seller_model.dart';

class CardmarketApiService {
  // Configuration API Cardmarket
  // IMPORTANT: Ces clés doivent être stockées de manière sécurisée
  // Ne jamais les commiter dans le code source
  static const String baseUrl = 'https://api.cardmarket.com/ws/v2.0';
  static const String appToken = 'YOUR_APP_TOKEN'; // À remplacer
  static const String appSecret = 'YOUR_APP_SECRET'; // À remplacer
  static const String accessToken = 'YOUR_ACCESS_TOKEN'; // À remplacer
  static const String accessTokenSecret =
      'YOUR_ACCESS_TOKEN_SECRET'; // À remplacer

  late Dio _dio;

  CardmarketApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Ajouter l'intercepteur pour l'authentification OAuth
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final authHeader = _generateOAuthHeader(
            options.method,
            options.uri.toString(),
          );
          options.headers['Authorization'] = authHeader;
          handler.next(options);
        },
      ),
    );
  }

  // Générer l'en-tête OAuth pour Cardmarket
  String _generateOAuthHeader(String method, String url) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();

    final parameters = {
      'oauth_consumer_key': appToken,
      'oauth_nonce': nonce,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp,
      'oauth_token': accessToken,
      'oauth_version': '1.0',
    };

    // Créer la signature base string
    final sortedParams =
        parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final paramString = sortedParams
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final signatureBaseString =
        '$method&${Uri.encodeComponent(url)}&${Uri.encodeComponent(paramString)}';
    final signingKey = '$appSecret&$accessTokenSecret';

    // Générer la signature
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final signature = base64.encode(
      hmac.convert(utf8.encode(signatureBaseString)).bytes,
    );

    parameters['oauth_signature'] = signature;

    // Construire l'en-tête
    final authHeader =
        'OAuth ' +
        parameters.entries
            .map((e) => '${e.key}="${Uri.encodeComponent(e.value)}"')
            .join(', ');

    return authHeader;
  }

  // Rechercher un produit Lorcana sur Cardmarket
  Future<List<Map<String, dynamic>>> searchProduct(String cardName) async {
    try {
      // Lorcana Game ID sur Cardmarket
      const lorcanaGameId = 22; // ID du jeu Lorcana sur Cardmarket

      final response = await _dio.get(
        '/products/find',
        queryParameters: {
          'search': cardName,
          'idGame': lorcanaGameId,
          'idLanguage': 2, // Français
          'maxResults': 10,
        },
      );

      if (response.data['product'] != null) {
        if (response.data['product'] is List) {
          return List<Map<String, dynamic>>.from(response.data['product']);
        } else {
          return [Map<String, dynamic>.from(response.data['product'])];
        }
      }

      return [];
    } catch (e) {
      print('Erreur recherche Cardmarket: $e');
      return [];
    }
  }

  // Récupérer les prix pour un produit
  Future<List<PriceModel>> fetchPricesForProduct(
    String productId,
    String cardId,
  ) async {
    try {
      final response = await _dio.get(
        '/articles/$productId',
        queryParameters: {
          'idLanguage': 2, // Français
          'minCondition': 'NM', // Near Mint minimum
          'start': 0,
          'maxResults': 20,
        },
      );

      final List<PriceModel> prices = [];

      if (response.data['article'] != null) {
        final articles =
            response.data['article'] is List
                ? response.data['article']
                : [response.data['article']];

        for (var article in articles) {
          final seller = SellerModel(
            id: article['seller']['idUser'].toString(),
            name: article['seller']['username'] ?? 'Vendeur',
            logoUrl:
                'https://static.cardmarket.com/img/users/avatar-default.png',
            rating: (article['seller']['reputation'] ?? 0).toDouble(),
            shippingInfo: _getShippingInfo(article['seller']),
          );

          prices.add(
            PriceModel(
              id: article['idArticle'].toString(),
              cardId: cardId,
              seller: seller,
              price: (article['price'] ?? 0).toDouble(),
              currency: 'EUR',
              condition: article['condition'] ?? 'NM',
              language: _getLanguageName(article['idLanguage']),
              inStock: article['count'] > 0,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      return prices;
    } catch (e) {
      print('Erreur récupération prix Cardmarket: $e');
      return [];
    }
  }

  // Récupérer les prix pour une carte par son nom
  Future<List<PriceModel>> fetchPricesForCard(
    String cardName,
    String cardId,
  ) async {
    try {
      // D'abord rechercher le produit
      final products = await searchProduct(cardName);

      if (products.isEmpty) {
        return [];
      }

      // Prendre le premier résultat (le plus pertinent)
      final productId = products.first['idProduct'].toString();

      // Récupérer les prix pour ce produit
      return fetchPricesForProduct(productId, cardId);
    } catch (e) {
      print('Erreur lors de la récupération des prix: $e');
      return [];
    }
  }

  String _getShippingInfo(Map<String, dynamic> seller) {
    final country = seller['address']['country'] ?? 'EU';
    final shipsFast = seller['shipsFast'] ?? false;
    final freeShippingThreshold = seller['freeShippingThreshold'] ?? 0;

    String info = 'Depuis $country';
    if (shipsFast) {
      info += ' • Envoi rapide';
    }
    if (freeShippingThreshold > 0) {
      info += ' • Gratuit dès ${freeShippingThreshold}€';
    }

    return info;
  }

  String _getLanguageName(int? languageId) {
    switch (languageId) {
      case 1:
        return 'EN';
      case 2:
        return 'FR';
      case 3:
        return 'DE';
      case 4:
        return 'ES';
      case 5:
        return 'IT';
      default:
        return 'EN';
    }
  }
}
