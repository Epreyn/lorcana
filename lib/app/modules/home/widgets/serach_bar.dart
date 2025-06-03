import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

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
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 10,
            color: AppColors.primary.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Rechercher une carte...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.primary.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.05),
                  ),
                  hint: Text(
                    'Rareté',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  dropdownColor: AppColors.surface,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Toutes',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Common',
                      child: Text(
                        'Commune',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Uncommon',
                      child: Text(
                        'Peu commune',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Rare',
                      child: Text(
                        'Rare',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Super Rare',
                      child: Text(
                        'Super Rare',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Legendary',
                      child: Text(
                        'Légendaire',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                  onChanged: onFilterRarity,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.05),
                  ),
                  hint: Text(
                    'Set',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  dropdownColor: AppColors.surface,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Tous',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'TFC',
                      child: Text(
                        'First Chapter',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ROF',
                      child: Text(
                        'Floodborn',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ITI',
                      child: Text(
                        'Inklands',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'URR',
                      child: Text(
                        'Ursula Return',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                  onChanged: onFilterSet,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
