// lib/app/modules/home/widgets/search_bar.dart
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String?) onFilterRarity;
  final Function(String?) onFilterSet;

  const SearchBar({
    super.key,
    required this.onSearch,
    required this.onFilterRarity,
    required this.onFilterSet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Rechercher une carte...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  hint: const Text('Rareté', overflow: TextOverflow.ellipsis),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Toutes', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Common',
                      child: Text('Commune', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Uncommon',
                      child: Text(
                        'Peu commune',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Rare',
                      child: Text('Rare', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Super Rare',
                      child: Text(
                        'Super Rare',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Legendary',
                      child: Text(
                        'Légendaire',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: onFilterRarity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  hint: const Text('Set', overflow: TextOverflow.ellipsis),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Tous', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'TFC',
                      child: Text(
                        'First Chapter',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ROF',
                      child: Text('Floodborn', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'ITI',
                      child: Text('Inklands', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'URR',
                      child: Text(
                        'Ursula Return',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: onFilterSet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
