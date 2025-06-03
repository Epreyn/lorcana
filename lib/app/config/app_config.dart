class AppConfig {
  // Configuration de l'environnement
  static const bool isDevelopment = true;

  // Configuration des APIs
  static const String lorcanaApiUrl = 'https://lorcana-api.com/api/v1';

  // Note sur les prix
  static const String priceDisclaimer =
      'Les prix affichés sont des estimations basées sur les tendances du marché. '
      'Pour des prix réels, consultez directement les sites marchands.';

  // Configuration du cache
  static const Duration cacheExpiration = Duration(minutes: 10);
  static const Duration priceCacheExpiration = Duration(minutes: 5);

  // Paramètres de l'app
  static const int itemsPerPage = 20;
  static const int maxSearchResults = 50;

  // Sets Lorcana disponibles
  static const Map<String, String> lorcanaSets = {
    'TFC': 'The First Chapter',
    'ROF': 'Rise of the Floodborn',
    'ITI': 'Into the Inklands',
    'URR': 'Ursula\'s Return',
    'SSK': 'Shimmering Skies',
    'AZU': 'Azurite Sea',
  };

  // Raretés
  static const List<String> rarities = [
    'Common',
    'Uncommon',
    'Rare',
    'Super Rare',
    'Legendary',
    'Enchanted',
  ];
}
