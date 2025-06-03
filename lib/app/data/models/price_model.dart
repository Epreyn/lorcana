import 'seller_model.dart';

class PriceModel {
  final String id;
  final String cardId;
  final SellerModel seller;
  final double price;
  final String currency;
  final String condition;
  final String language;
  final bool inStock;
  final DateTime updatedAt;

  PriceModel({
    required this.id,
    required this.cardId,
    required this.seller,
    required this.price,
    required this.currency,
    required this.condition,
    required this.language,
    required this.inStock,
    required this.updatedAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'],
      cardId: json['cardId'],
      seller: SellerModel.fromJson(json['seller']),
      price: json['price'].toDouble(),
      currency: json['currency'],
      condition: json['condition'],
      language: json['language'],
      inStock: json['inStock'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
