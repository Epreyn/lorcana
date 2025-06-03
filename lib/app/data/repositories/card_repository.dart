import '../../services/lorcana_api_services.dart';
import '../models/card_model.dart';
import '../../services/mock_api_service.dart';

class CardRepository {
  final LorcanaApiService _lorcanaApi = LorcanaApiService();
  final MockApiService _mockService = MockApiService();

  // Cache pour éviter trop de requêtes
  List<CardModel>? _cachedCards;
  DateTime? _lastFetch;
  static const Duration _cacheExpiration = Duration(minutes: 10);

  Future<List<CardModel>> getCards() async {
    // Vérifier le cache
    if (_cachedCards != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheExpiration) {
      return _cachedCards!;
    }

    try {
      print('Récupération des cartes depuis l\'API Lorcana...');

      // Récupérer les données depuis l'API Lorcana
      final apiCards = await _lorcanaApi.fetchAllCards();

      print('Nombre de cartes reçues: ${apiCards.length}');

      // Convertir vers notre modèle
      final cards =
          apiCards
              .map((apiCard) {
                try {
                  return LorcanaApiAdapter.fromApiResponse(apiCard);
                } catch (e) {
                  print('Erreur conversion carte: $e');
                  print('Données problématiques: $apiCard');
                  return null;
                }
              })
              .whereType<CardModel>()
              .toList();

      // Mettre en cache
      _cachedCards = cards;
      _lastFetch = DateTime.now();

      print('${cards.length} cartes converties avec succès');
      return cards;
    } catch (e) {
      print('Erreur lors du chargement des cartes: $e');
      // En cas d'erreur, utiliser les données mock
      print('Basculement vers les données mock...');
      return _mockService.getCards();
    }
  }

  Future<CardModel> getCardById(String id) async {
    try {
      // Vérifier d'abord le cache
      if (_cachedCards != null) {
        final cachedCard = _cachedCards!.firstWhere(
          (card) => card.id == id,
          orElse: () => throw Exception('Carte non trouvée dans le cache'),
        );
        return cachedCard;
      }

      // Sinon récupérer depuis l'API
      final apiCard = await _lorcanaApi.fetchCardByIdOrName(id);
      return LorcanaApiAdapter.fromApiResponse(apiCard);
    } catch (e) {
      print('Erreur lors du chargement de la carte: $e');
      return _mockService.getCardById(id);
    }
  }

  Future<List<CardModel>> searchCards(String query) async {
    try {
      // Rechercher via l'API Lorcana
      final apiCards = await _lorcanaApi.searchCards(query);

      // Convertir vers notre modèle
      final cards =
          apiCards
              .map((apiCard) {
                try {
                  return LorcanaApiAdapter.fromApiResponse(apiCard);
                } catch (e) {
                  return null;
                }
              })
              .whereType<CardModel>()
              .toList();

      return cards;
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return _mockService.searchCards(query);
    }
  }

  void clearCache() {
    _cachedCards = null;
    _lastFetch = null;
  }
}
