import '../models/card_model.dart';
import '../providers/api_provider.dart';

class CardRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<CardModel>> getCards() async {
    try {
      final response = await _apiProvider.get('/cards');
      return (response.data as List)
          .map((card) => CardModel.fromJson(card))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des cartes');
    }
  }

  Future<CardModel> getCardById(String id) async {
    try {
      final response = await _apiProvider.get('/cards/$id');
      return CardModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la carte');
    }
  }

  Future<List<CardModel>> searchCards(String query) async {
    try {
      final response = await _apiProvider.get('/cards/search?q=$query');
      return (response.data as List)
          .map((card) => CardModel.fromJson(card))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche');
    }
  }
}
