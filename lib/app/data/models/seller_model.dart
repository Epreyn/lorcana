class SellerModel {
  final String id;
  final String name;
  final String logoUrl;
  final double rating;
  final String shippingInfo;

  SellerModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.rating,
    required this.shippingInfo,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      rating: json['rating'].toDouble(),
      shippingInfo: json['shippingInfo'],
    );
  }
}
