// lib/app/modules/home/widgets/floating_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';

class FloatingFilterBar extends StatelessWidget {
  final HomeController controller;

  const FloatingFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Filtre par couleur d'encre
          Obx(
            () => _buildFilterButton(
              icon: Icons.palette,
              label: 'Couleur',
              isActive: controller.selectedInkColors.isNotEmpty,
              onTap: () => _showInkColorFilter(context),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
            ),
          ),

          // Filtre par rareté
          Obx(
            () => _buildFilterButton(
              icon: Icons.star,
              label: 'Rareté',
              isActive: controller.selectedRarity.value != null,
              onTap: () => _showRarityFilter(context),
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
          ),

          // Filtre par set
          Obx(
            () => _buildFilterButton(
              icon: Icons.collections,
              label: 'Edition',
              isActive: controller.selectedSet.value != null,
              onTap: () => _showSetFilter(context),
              gradient: const LinearGradient(
                colors: [Color(0xFF06BEB6), Color(0xFF48B1BF)],
              ),
            ),
          ),

          // Plus de filtres
          Obx(
            () => _buildFilterButton(
              icon: Icons.tune,
              label: 'Plus',
              isActive: controller.hasAdvancedFilters,
              onTap: () => controller.showAdvancedFilters.value = true,
              gradient: const LinearGradient(
                colors: [Color(0xFFEC008C), Color(0xFFFC6767)],
              ),
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
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: isActive ? gradient : null,
          color: isActive ? null : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            width: isActive ? 2 : 1,
          ),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
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
      {'name': 'Amber', 'color': const Color(0xFFFFC107)},
      {'name': 'Amethyst', 'color': const Color(0xFF9C27B0)},
      {'name': 'Emerald', 'color': const Color(0xFF4CAF50)},
      {'name': 'Ruby', 'color': const Color(0xFFF44336)},
      {'name': 'Sapphire', 'color': const Color(0xFF2196F3)},
      {'name': 'Steel', 'color': const Color(0xFF607D8B)},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Filtrer par couleur d\'encre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(isSelected ? 1 : 0.3),
                              color.withOpacity(isSelected ? 0.8 : 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                  : [],
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
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
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
                  child: const Text(
                    'Effacer',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
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
        'icon': Icons.circle,
        'color': const Color(0xFF9E9E9E),
      },
      {
        'name': 'Uncommon',
        'icon': Icons.square,
        'color': const Color(0xFF4CAF50),
      },
      {'name': 'Rare', 'icon': Icons.diamond, 'color': const Color(0xFF2196F3)},
      {
        'name': 'Super Rare',
        'icon': Icons.star,
        'color': const Color(0xFF9C27B0),
      },
      {
        'name': 'Legendary',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFFF9800),
      },
      {
        'name': 'Enchanted',
        'icon': Icons.blur_on,
        'color': const Color(0xFFE91E63),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Filtrer par rareté',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...rarities.map((rarity) {
            final name = rarity['name'] as String;
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
                    gradient:
                        isSelected
                            ? LinearGradient(
                              colors: [
                                color.withOpacity(0.3),
                                color.withOpacity(0.1),
                              ],
                            )
                            : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.white.withOpacity(0.2),
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
                          name,
                          style: TextStyle(
                            color: isSelected ? color : Colors.white70,
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
        'color': const Color(0xFF1976D2),
        'icon': '1',
      },
      {
        'code': 'ROF',
        'name': 'Rise of the Floodborn',
        'color': const Color(0xFF00ACC1),
        'icon': '2',
      },
      {
        'code': 'ITI',
        'name': 'Into the Inklands',
        'color': const Color(0xFF43A047),
        'icon': '3',
      },
      {
        'code': 'URR',
        'name': 'Ursula\'s Return',
        'color': const Color(0xFF8E24AA),
        'icon': '4',
      },
      {
        'code': 'SSK',
        'name': 'Shimmering Skies',
        'color': const Color(0xFFFFB300),
        'icon': '5',
      },
      {
        'code': 'AZU',
        'name': 'Azurite Sea',
        'color': const Color(0xFF0277BD),
        'icon': '6',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Filtrer par édition',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isSelected
                                ? [color, color.withOpacity(0.7)]
                                : [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                              : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                              isSelected ? 1 : 0.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: TextStyle(
                                color: isSelected ? color : Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          code,
                          style: const TextStyle(
                            color: Colors.white,
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
