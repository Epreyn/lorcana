class CardModel {
  final String id;
  final String name;
  final String imageUrl;
  final String rarity;
  final String set;
  final int inkCost;
  final String type;
  final List<PriceModel> prices;
  final int stockQuantity;

  CardModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rarity,
    required this.set,
    required this.inkCost,
    required this.type,
    required this.prices,
    required this.stockQuantity,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      rarity: json['rarity'],
      set: json['set'],
      inkCost: json['inkCost'],
      type: json['type'],
      prices:
          (json['prices'] as List)
              .map((price) => PriceModel.fromJson(price))
              .toList(),
      stockQuantity: json['stockQuantity'],
    );
  }

  double get lowestPrice =>
      prices.isNotEmpty
          ? prices.map((p) => p.price).reduce((a, b) => a < b ? a : b)
          : 0.0;
}
