import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../themes/app_colors.dart';

class FloatingFilterBar extends StatelessWidget {
  final HomeController controller;

  const FloatingFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(
            () => _buildFilterButton(
              icon: Icons.palette_rounded,
              label: 'Couleur',
              isActive: controller.selectedInkColors.isNotEmpty,
              onTap: () => _showInkColorFilter(context),
              color: AppColors.secondary,
            ),
          ),

          Obx(
            () => _buildFilterButton(
              icon: Icons.star_rounded,
              label: 'Rareté',
              isActive: controller.selectedRarity.value != null,
              onTap: () => _showRarityFilter(context),
              color: AppColors.primary,
            ),
          ),

          Obx(
            () => _buildFilterButton(
              icon: Icons.collections_rounded,
              label: 'Édition',
              isActive: controller.selectedSet.value != null,
              onTap: () => _showSetFilter(context),
              color: AppColors.success,
            ),
          ),

          Obx(
            () => _buildFilterButton(
              icon: Icons.tune_rounded,
              label: 'Plus',
              isActive: controller.hasAdvancedFilters,
              onTap: () => controller.showAdvancedFilters.value = true,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isActive ? 0.2 : 0.1),
              blurRadius: isActive ? 20 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInkColorFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => InkColorFilterSheet(controller: controller),
    );
  }

  void _showRarityFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => RarityFilterSheet(controller: controller),
    );
  }

  void _showSetFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SetFilterSheet(controller: controller),
    );
  }
}

// Filtre par couleur d'encre
class InkColorFilterSheet extends StatelessWidget {
  final HomeController controller;

  const InkColorFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final inkColors = [
      {'name': 'Amber', 'color': AppColors.amberInk},
      {'name': 'Amethyst', 'color': AppColors.amethystInk},
      {'name': 'Emerald', 'color': AppColors.emeraldInk},
      {'name': 'Ruby', 'color': AppColors.rubyInk},
      {'name': 'Sapphire', 'color': AppColors.sapphireInk},
      {'name': 'Steel', 'color': AppColors.steelInk},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Filtrer par couleur d\'encre',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children:
                inkColors.map((ink) {
                  final color = ink['color'] as Color;
                  final name = ink['name'] as String;

                  return Obx(() {
                    final isSelected = controller.selectedInkColors.contains(
                      name,
                    );
                    return GestureDetector(
                      onTap: () => controller.toggleInkColor(name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(isSelected ? 0.8 : 0.3),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white : color,
                                  border: Border.all(
                                    color: isSelected ? color : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    controller.clearInkColors();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Effacer',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Appliquer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

// Filtre par rareté
class RarityFilterSheet extends StatelessWidget {
  final HomeController controller;

  const RarityFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final rarities = [
      {
        'name': 'Common',
        'label': 'Commune',
        'icon': Icons.circle,
        'color': AppColors.common,
      },
      {
        'name': 'Uncommon',
        'label': 'Peu commune',
        'icon': Icons.square,
        'color': AppColors.uncommon,
      },
      {
        'name': 'Rare',
        'label': 'Rare',
        'icon': Icons.diamond,
        'color': AppColors.rare,
      },
      {
        'name': 'Super Rare',
        'label': 'Super Rare',
        'icon': Icons.star,
        'color': AppColors.superRare,
      },
      {
        'name': 'Legendary',
        'label': 'Légendaire',
        'icon': Icons.auto_awesome,
        'color': AppColors.legendary,
      },
      {
        'name': 'Enchanted',
        'label': 'Enchantée',
        'icon': Icons.blur_on,
        'color': AppColors.enchanted,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Filtrer par rareté',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ...rarities.map((rarity) {
            final name = rarity['name'] as String;
            final label = rarity['label'] as String;
            final icon = rarity['icon'] as IconData;
            final color = rarity['color'] as Color;

            return Obx(() {
              final isSelected = controller.selectedRarity.value == name;
              return GestureDetector(
                onTap: () {
                  controller.filterByRarity(isSelected ? null : name);
                  if (!isSelected) Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? color
                              : AppColors.primary.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? color : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 24),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
        ],
      ),
    );
  }
}

// Filtre par set/édition
class SetFilterSheet extends StatelessWidget {
  final HomeController controller;

  const SetFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final sets = [
      {
        'code': 'TFC',
        'name': 'The First Chapter',
        'color': AppColors.primary,
        'icon': '1',
      },
      {
        'code': 'ROF',
        'name': 'Rise of the Floodborn',
        'color': AppColors.sapphireInk,
        'icon': '2',
      },
      {
        'code': 'ITI',
        'name': 'Into the Inklands',
        'color': AppColors.emeraldInk,
        'icon': '3',
      },
      {
        'code': 'URR',
        'name': 'Ursula\'s Return',
        'color': AppColors.amethystInk,
        'icon': '4',
      },
      {
        'code': 'SSK',
        'name': 'Shimmering Skies',
        'color': AppColors.amberInk,
        'icon': '5',
      },
      {
        'code': 'AZU',
        'name': 'Azurite Sea',
        'color': AppColors.sapphireInk,
        'icon': '6',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Filtrer par édition',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: sets.length,
            itemBuilder: (context, index) {
              final set = sets[index];
              final code = set['code'] as String;
              final name = set['name'] as String;
              final color = set['color'] as Color;
              final icon = set['icon'] as String;

              return Obx(() {
                final isSelected = controller.selectedSet.value == code;
                return GestureDetector(
                  onTap: () {
                    controller.filterBySet(isSelected ? null : code);
                    if (!isSelected) Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withOpacity(isSelected ? 0.8 : 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : color,
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: TextStyle(
                                color: isSelected ? color : Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          code,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
