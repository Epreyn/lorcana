import '../providers/api_provider.dart';

class OrderRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _apiProvider.post('/orders', orderData);
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande');
    }
  }

  Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await _apiProvider.get('/orders/user/$userId');
      return response.data as List;
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes');
    }
  }
}
