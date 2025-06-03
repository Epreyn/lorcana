import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class FloatingFilterMenu extends StatelessWidget {
  final Function(String?) onRaritySelected;
  final Function(String?) onSetSelected;
  final String? selectedRarity;
  final String? selectedSet;

  const FloatingFilterMenu({
    super.key,
    required this.onRaritySelected,
    required this.onSetSelected,
    this.selectedRarity,
    this.selectedSet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RARETÉ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Toutes',
                null,
                selectedRarity,
                onRaritySelected,
              ),
              _buildFilterChip(
                'Common',
                'Common',
                selectedRarity,
                onRaritySelected,
                color: AppColors.common,
              ),
              _buildFilterChip(
                'Uncommon',
                'Uncommon',
                selectedRarity,
                onRaritySelected,
                color: AppColors.uncommon,
              ),
              _buildFilterChip(
                'Rare',
                'Rare',
                selectedRarity,
                onRaritySelected,
                color: AppColors.rare,
              ),
              _buildFilterChip(
                'Super Rare',
                'Super Rare',
                selectedRarity,
                onRaritySelected,
                color: AppColors.superRare,
              ),
              _buildFilterChip(
                'Legendary',
                'Legendary',
                selectedRarity,
                onRaritySelected,
                color: AppColors.legendary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'ÉDITION',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Tous', null, selectedSet, onSetSelected),
              _buildFilterChip('TFC', 'TFC', selectedSet, onSetSelected),
              _buildFilterChip('ROF', 'ROF', selectedSet, onSetSelected),
              _buildFilterChip('ITI', 'ITI', selectedSet, onSetSelected),
              _buildFilterChip('URR', 'URR', selectedSet, onSetSelected),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? selectedValue,
    Function(String?) onSelected, {
    Color? color,
  }) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (color ?? Colors.white).withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? (color ?? Colors.white).withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? (color ?? Colors.white)
                    : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
