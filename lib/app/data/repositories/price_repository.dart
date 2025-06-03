import '../models/price_model.dart';
import '../providers/api_provider.dart';

class PriceRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<PriceModel>> getPricesForCard(String cardId) async {
    try {
      final response = await _apiProvider.get('/prices/card/$cardId');
      return (response.data as List)
          .map((price) => PriceModel.fromJson(price))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des prix');
    }
  }

  Future<void> updatePrices(String cardId) async {
    try {
      await _apiProvider.post('/prices/update/$cardId', {});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des prix');
    }
  }
}
