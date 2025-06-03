// lib/app/services/lorcana_api_adapter.dart
import 'package:flutter/material.dart';
import '../data/models/card_model.dart';
import '../data/models/price_model.dart';

class LorcanaApiAdapter {
  static CardModel fromApiResponse(
    Map<String, dynamic> apiData, {
    List<PriceModel>? prices,
  }) {
    // Debug : afficher les clés disponibles
    // if (apiData.isNotEmpty) {
    //   print('Clés disponibles dans apiData: ${apiData.keys.toList()}');
    // }

    // Extraire l'ID
    final id =
        (apiData['id'] ??
                apiData['unique_id'] ??
                apiData['card_id'] ??
                apiData['number'] ??
                DateTime.now().millisecondsSinceEpoch)
            .toString();

    // Nom et version
    String name = apiData['Name'] ?? apiData['name'] ?? 'Carte inconnue';
    String? version =
        apiData['Version'] ?? apiData['version'] ?? apiData['subtitle'];

    // Si le nom contient déjà la version (format "Nom - Version"), séparer
    if (version == null && name.contains(' - ')) {
      final parts = name.split(' - ');
      name = parts[0];
      version = parts[1];
    }

    // URL de l'image
    String imageUrl = apiData['Image'] ?? apiData['image'] ?? '';
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://via.placeholder.com/300x420/E3F2FD/1976D2?text=Lorcana';
    } else if (!imageUrl.startsWith('http')) {
      // Ajouter le domaine si l'URL est relative
      imageUrl = 'https://api.lorcana-api.com$imageUrl';
    }

    // Rareté
    String rarity =
        (apiData['Rarity'] ?? apiData['rarity'] ?? 'Common').toString();
    rarity = _normalizeRarity(rarity);

    // Set
    String setName =
        apiData['Set_Name'] ??
        apiData['set_name'] ??
        apiData['set'] ??
        'Unknown';
    String setCode =
        apiData['Set_ID'] ?? apiData['set_id'] ?? apiData['set_code'] ?? '';
    if (setCode.isEmpty) {
      // Si pas de code, essayer de le déduire du nom
      setCode = _normalizeSetCode(setName);
    } else {
      setCode = _normalizeSetCode(setCode);
    }

    // Coût en encre
    final inkCost = _extractNumber(
      apiData['Cost'] ?? apiData['cost'] ?? apiData['ink_cost'] ?? 0,
    );

    // Type et classifications
    String type =
        apiData['Type'] ?? apiData['type'] ?? apiData['card_type'] ?? 'Unknown';
    List<String>? classifications;

    if (apiData['Classifications'] != null) {
      if (apiData['Classifications'] is List) {
        classifications = List<String>.from(apiData['Classifications']);
      } else if (apiData['Classifications'] is String) {
        classifications =
            (apiData['Classifications'] as String)
                .split(',')
                .map((e) => e.trim())
                .toList();
      }
    }

    // Couleur d'encre
    String? inkColor =
        apiData['Color'] ?? apiData['color'] ?? apiData['ink_color'];
    if (inkColor != null) {
      inkColor = _normalizeInkColor(inkColor);
    }

    // Caractéristiques de combat
    final strength = _extractNumber(
      apiData['Strength'] ?? apiData['strength'] ?? apiData['power'],
    );
    final willpower = _extractNumber(
      apiData['Willpower'] ?? apiData['willpower'] ?? apiData['toughness'],
    );
    final loreValue = _extractNumber(
      apiData['Lore'] ?? apiData['lore'] ?? apiData['lore_value'],
    );

    // Textes
    final abilities =
        apiData['Abilities'] ??
        apiData['abilities'] ??
        apiData['text'] ??
        apiData['oracle_text'];
    final flavorText = apiData['Flavor_Text'] ?? apiData['flavor_text'];

    // Artiste et numéro de collection
    final artist = apiData['Artist'] ?? apiData['artist'];
    final collectorNumber =
        apiData['Collector_Number'] ??
        apiData['collector_number'] ??
        apiData['number'];

    // Inkable
    final inkable =
        apiData['Inkable'] ??
        apiData['inkable'] ??
        apiData['ink_convertible'] ??
        true;

    // Debug
    // print(
    //   'Carte convertie: $name${version != null ? " - $version" : ""} (ID: $id, Set: $setCode, Type: $type, Color: $inkColor)',
    // );

    return CardModel(
      id: id,
      name: name,
      version: version,
      imageUrl: imageUrl,
      rarity: rarity,
      set: setName,
      setCode: setCode,
      inkCost: inkCost,
      type: type,
      classifications: classifications,
      inkColor: inkColor,
      strength: strength > 0 ? strength : null,
      willpower: willpower > 0 ? willpower : null,
      loreValue: loreValue > 0 ? loreValue : null,
      abilities:
          abilities?.toString().isNotEmpty == true
              ? abilities.toString()
              : null,
      flavorText:
          flavorText?.toString().isNotEmpty == true
              ? flavorText.toString()
              : null,
      artist: artist?.toString(),
      collectorNumber: collectorNumber?.toString(),
      inkable: inkable is bool ? inkable : true,
      prices: prices ?? [],
      stockQuantity: 10, // Valeur par défaut
    );
  }

  static String _normalizeRarity(String rarity) {
    switch (rarity.toLowerCase().trim()) {
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

  static String _normalizeSetCode(String set) {
    // Mapping des codes de sets Lorcana
    final setMap = {
      '1': 'TFC',
      'tfc': 'TFC',
      'the first chapter': 'TFC',
      'first chapter': 'TFC',
      '2': 'ROF',
      'rof': 'ROF',
      'rise of the floodborn': 'ROF',
      'floodborn': 'ROF',
      '3': 'ITI',
      'iti': 'ITI',
      'into the inklands': 'ITI',
      'inklands': 'ITI',
      '4': 'URR',
      'urr': 'URR',
      'ursula\'s return': 'URR',
      'ursulas return': 'URR',
      '5': 'SSK',
      'ssk': 'SSK',
      'shimmering skies': 'SSK',
      '6': 'AZU',
      'azu': 'AZU',
      'azurite sea': 'AZU',
      'unknown': 'TFC', // Par défaut, on met TFC
      '': 'TFC', // Si vide, on met TFC
    };

    final normalizedSet = set.toLowerCase().trim();
    final result = setMap[normalizedSet];
    if (result != null) return result;

    // Si pas trouvé, essayer de créer un code de 3 lettres
    if (set.length >= 3) {
      return set.substring(0, 3).toUpperCase();
    }

    // Par défaut
    return 'TFC';
  }

  static String _normalizeInkColor(String color) {
    final colorMap = {
      'amber': 'Amber',
      'yellow': 'Amber',
      'amethyst': 'Amethyst',
      'purple': 'Amethyst',
      'emerald': 'Emerald',
      'green': 'Emerald',
      'ruby': 'Ruby',
      'red': 'Ruby',
      'sapphire': 'Sapphire',
      'blue': 'Sapphire',
      'steel': 'Steel',
      'gray': 'Steel',
      'grey': 'Steel',
    };

    final normalizedColor = color.toLowerCase().trim();
    return colorMap[normalizedColor] ?? color;
  }

  static int _extractNumber(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Nettoyer la chaîne (enlever les symboles, espaces, etc.)
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  // Méthode pour extraire les informations supplémentaires
  static Map<String, dynamic> extractAdditionalInfo(Map<String, dynamic> data) {
    return {
      'franchise': data['Franchise'] ?? data['franchise'] ?? 'Disney',
      'body_text': data['Body_Text'] ?? data['body_text'],
      'set_number': _extractNumber(data['Set_Num'] ?? data['set_num']),
      'card_number': _extractNumber(data['Card_Num'] ?? data['card_num']),
      'date_added': data['Date_Added'] ?? data['date_added'],
      'enchanted_id': data['Enchanted_ID'] ?? data['enchanted_id'],
      'foil_types': data['Foil_Types'] ?? data['foil_types'],
      'variant': data['Variant'] ?? data['variant'],
      'promo': data['Promo'] ?? data['promo'] ?? false,
      'keywords': data['Keywords'] ?? data['keywords'],
      'move_cost': _extractNumber(data['Move_Cost'] ?? data['move_cost']),
      'tcgplayer_id': data['TCGPlayer_ID'] ?? data['tcgplayer_id'],
    };
  }
}
