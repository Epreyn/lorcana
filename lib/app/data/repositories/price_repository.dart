import '../models/price_model.dart';
import '../models/card_model.dart';
import '../../services/price_simulation_service.dart';

class PriceRepository {
  final PriceSimulationService _priceService = PriceSimulationService();

  // Cache des prix
  final Map<String, List<PriceModel>> _priceCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  Future<List<PriceModel>> getPricesForCard(
    String cardId, {
    CardModel? card,
  }) async {
    // Vérifier le cache
    if (_priceCache.containsKey(cardId)) {
      final timestamp = _cacheTimestamps[cardId];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiration) {
        return _priceCache[cardId]!;
      }
    }

    try {
      // Pour l'instant, on utilise le service de simulation
      // Dans le futur, on pourrait implémenter du web scraping ici

      if (card == null) {
        throw Exception('La carte est requise pour générer les prix');
      }

      final prices = await _priceService.generatePricesForCard(card);

      // Mettre en cache
      _priceCache[cardId] = prices;
      _cacheTimestamps[cardId] = DateTime.now();

      return prices;
    } catch (e) {
      print('Erreur lors du chargement des prix: $e');
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  Future<void> updatePrices(String cardId) async {
    // Invalider le cache pour forcer une mise à jour
    _priceCache.remove(cardId);
    _cacheTimestamps.remove(cardId);
  }

  void clearCache() {
    _priceCache.clear();
    _cacheTimestamps.clear();
  }
}
