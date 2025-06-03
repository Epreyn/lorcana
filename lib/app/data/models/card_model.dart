// lib/app/data/models/card_model.dart
import 'package:flutter/material.dart';
import 'price_model.dart';

class CardModel {
  final String id;
  final String name;
  final String? version; // Version/titre de la carte (ex: "Snow Queen")
  final String imageUrl;
  final String rarity;
  final String set;
  final String setCode;
  final int inkCost;
  final String type;
  final List<String>? classifications; // ex: ["Storyborn", "Hero", "Princess"]
  final String? inkColor; // Amber, Amethyst, Emerald, Ruby, Sapphire, Steel
  final int? strength;
  final int? willpower;
  final int? loreValue;
  final String? abilities;
  final String? flavorText;
  final String? artist;
  final String? collectorNumber;
  final bool? inkable;
  final List<PriceModel> prices;
  final int stockQuantity;

  // Propriétés calculées pour les filtres
  bool get isCharacter => type.toLowerCase().contains('character');
  bool get isAction => type.toLowerCase().contains('action');
  bool get isItem => type.toLowerCase().contains('item');
  bool get isLocation => type.toLowerCase().contains('location');

  CardModel({
    required this.id,
    required this.name,
    this.version,
    required this.imageUrl,
    required this.rarity,
    required this.set,
    required this.setCode,
    required this.inkCost,
    required this.type,
    this.classifications,
    this.inkColor,
    this.strength,
    this.willpower,
    this.loreValue,
    this.abilities,
    this.flavorText,
    this.artist,
    this.collectorNumber,
    this.inkable,
    required this.prices,
    required this.stockQuantity,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      version: json['version'],
      imageUrl: json['imageUrl'],
      rarity: json['rarity'],
      set: json['set'],
      setCode: json['setCode'],
      inkCost: json['inkCost'],
      type: json['type'],
      classifications:
          json['classifications'] != null
              ? List<String>.from(json['classifications'])
              : null,
      inkColor: json['inkColor'],
      strength: json['strength'],
      willpower: json['willpower'],
      loreValue: json['loreValue'],
      abilities: json['abilities'],
      flavorText: json['flavorText'],
      artist: json['artist'],
      collectorNumber: json['collectorNumber'],
      inkable: json['inkable'],
      prices:
          (json['prices'] as List)
              .map((price) => PriceModel.fromJson(price))
              .toList(),
      stockQuantity: json['stockQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'imageUrl': imageUrl,
      'rarity': rarity,
      'set': set,
      'setCode': setCode,
      'inkCost': inkCost,
      'type': type,
      'classifications': classifications,
      'inkColor': inkColor,
      'strength': strength,
      'willpower': willpower,
      'loreValue': loreValue,
      'abilities': abilities,
      'flavorText': flavorText,
      'artist': artist,
      'collectorNumber': collectorNumber,
      'inkable': inkable,
      'prices': prices, // Les prix sont déjà des objets PriceModel
      'stockQuantity': stockQuantity,
    };
  }

  double get lowestPrice =>
      prices.isNotEmpty
          ? prices.map((p) => p.price).reduce((a, b) => a < b ? a : b)
          : 0.0;

  String get fullName => version != null ? '$name - $version' : name;

  // Helper pour obtenir la couleur de l'encre
  Color get inkColorValue {
    switch (inkColor?.toLowerCase()) {
      case 'amber':
        return const Color(0xFFFFC107);
      case 'amethyst':
        return const Color(0xFF9C27B0);
      case 'emerald':
        return const Color(0xFF4CAF50);
      case 'ruby':
        return const Color(0xFFF44336);
      case 'sapphire':
        return const Color(0xFF2196F3);
      case 'steel':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Helper pour obtenir la couleur de rareté
  Color get rarityColor {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF9E9E9E);
      case 'uncommon':
        return const Color(0xFF4CAF50);
      case 'rare':
        return const Color(0xFF2196F3);
      case 'super rare':
        return const Color(0xFF9C27B0);
      case 'legendary':
        return const Color(0xFFFF9800);
      case 'enchanted':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
