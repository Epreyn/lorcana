import '../data/models/card_model.dart';
import '../data/models/price_model.dart';

class LorcanaCardAdapter {
  // Convertir les données de l'API Lorcana vers notre modèle CardModel
  static CardModel fromApiResponse(
    Map<String, dynamic> apiData, {
    List<PriceModel>? prices,
  }) {
    return CardModel(
      id: _extractId(apiData),
      name: _extractName(apiData),
      imageUrl: _extractImageUrl(apiData),
      rarity: _extractRarity(apiData),
      set: _extractSet(apiData),
      inkCost: _extractInkCost(apiData),
      type: _extractType(apiData),
      prices: prices ?? [],
      stockQuantity:
          10, // Valeur par défaut, sera mise à jour avec les données de prix
    );
  }

  static String _extractId(Map<String, dynamic> data) {
    // L'API peut utiliser différents noms pour l'ID
    return (data['id'] ??
            data['card_id'] ??
            data['unique_id'] ??
            DateTime.now().millisecondsSinceEpoch)
        .toString();
  }

  static String _extractName(Map<String, dynamic> data) {
    // Combiner le nom et le titre si disponibles
    final name = data['name'] ?? data['card_name'] ?? 'Carte inconnue';
    final title = data['title'] ?? data['subtitle'] ?? '';

    if (title.isNotEmpty && !name.contains(title)) {
      return '$name - $title';
    }
    return name;
  }

  static String _extractImageUrl(Map<String, dynamic> data) {
    // Plusieurs formats possibles pour l'URL de l'image
    final imageUrl =
        data['image'] ??
        data['image_url'] ??
        data['image_uris']?['normal'] ??
        data['image_uris']?['large'] ??
        '';

    // Vérifier si l'URL est complète ou relative
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      return 'https://api.lorcana-api.com$imageUrl';
    }

    // Image par défaut si aucune n'est disponible
    return imageUrl.isEmpty
        ? 'https://via.placeholder.com/300x420/E3F2FD/1976D2?text=Lorcana'
        : imageUrl;
  }

  static String _extractRarity(Map<String, dynamic> data) {
    final rarity =
        (data['rarity'] ?? data['card_rarity'] ?? 'Common').toString();

    // Normaliser les noms de rareté
    switch (rarity.toLowerCase()) {
      case 'common':
      case 'c':
        return 'Common';
      case 'uncommon':
      case 'uc':
      case 'u':
        return 'Uncommon';
      case 'rare':
      case 'r':
        return 'Rare';
      case 'super rare':
      case 'super_rare':
      case 'sr':
        return 'Super Rare';
      case 'legendary':
      case 'l':
        return 'Legendary';
      case 'enchanted':
      case 'e':
        return 'Enchanted';
      default:
        return 'Common';
    }
  }

  static String _extractSet(Map<String, dynamic> data) {
    // Extraire le code ou le nom du set
    final setCode = data['set_code'] ?? data['set'] ?? '';
    final setName = data['set_name'] ?? '';

    // Mapper les codes de sets Lorcana
    switch (setCode.toUpperCase()) {
      case 'TFC':
      case '1':
        return 'TFC'; // The First Chapter
      case 'ROF':
      case '2':
        return 'ROF'; // Rise of the Floodborn
      case 'ITI':
      case '3':
        return 'ITI'; // Into the Inklands
      case 'URR':
      case '4':
        return 'URR'; // Ursula's Return
      case 'SSK':
      case '5':
        return 'SSK'; // Shimmering Skies
      default:
        return setCode.isNotEmpty
            ? setCode
            : (setName.isNotEmpty ? setName : 'Unknown');
    }
  }

  static int _extractInkCost(Map<String, dynamic> data) {
    // L'API peut utiliser différents noms pour le coût
    final cost =
        data['cost'] ??
        data['ink_cost'] ??
        data['ink'] ??
        data['mana_cost'] ??
        0;

    if (cost is int) {
      return cost;
    } else if (cost is String) {
      return int.tryParse(cost) ?? 0;
    } else if (cost is double) {
      return cost.toInt();
    }

    return 0;
  }

  static String _extractType(Map<String, dynamic> data) {
    // Extraire et formater le type de carte
    final type = data['type'] ?? data['card_type'] ?? '';
    final subtype = data['subtype'] ?? data['classifications'] ?? '';

    if (type.isEmpty) {
      return 'Unknown';
    }

    // Traduire les types si nécessaire
    String translatedType = _translateType(type);

    if (subtype.isNotEmpty && !translatedType.contains(subtype)) {
      return '$translatedType - $subtype';
    }

    return translatedType;
  }

  static String _translateType(String type) {
    // Traduction des types de cartes
    switch (type.toLowerCase()) {
      case 'character':
        return 'Personnage';
      case 'action':
        return 'Action';
      case 'item':
        return 'Objet';
      case 'location':
        return 'Lieu';
      default:
        return type;
    }
  }

  // Méthode pour extraire les informations supplémentaires si nécessaire
  static Map<String, dynamic> extractAdditionalInfo(Map<String, dynamic> data) {
    return {
      'strength': data['strength'] ?? data['power'],
      'willpower': data['willpower'] ?? data['toughness'],
      'lore': data['lore'] ?? data['lore_value'],
      'abilities': data['abilities'] ?? data['text'] ?? data['oracle_text'],
      'flavor_text': data['flavor_text'],
      'artist': data['artist'],
      'collector_number': data['collector_number'] ?? data['number'],
      'ink_convertible': data['ink_convertible'] ?? data['inkable'] ?? true,
    };
  }
}
