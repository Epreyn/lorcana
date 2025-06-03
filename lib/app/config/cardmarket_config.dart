import '../data/models/seller_model.dart';

class CardmarketConfig {
  // Ces valeurs doivent être obtenues depuis https://www.cardmarket.com/en/Magic/Account/API
  // et stockées de manière sécurisée (variables d'environnement, etc.)
  static const bool useRealApi =
      false; // Mettre à true quand vous avez les clés API

  // Mock seller pour le développement
  static final mockSeller = SellerModel(
    id: 'cardmarket',
    name: 'Cardmarket',
    logoUrl: 'https://static.cardmarket.com/img/logos/logo_cm_blue.png',
    rating: 4.5,
    shippingInfo: 'Vendeurs vérifiés • Protection acheteur',
  );
}
