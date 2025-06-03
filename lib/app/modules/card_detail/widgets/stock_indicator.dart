import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class StockIndicator extends StatelessWidget {
  final int quantity;

  const StockIndicator({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    if (quantity == 0) {
      color = AppColors.error;
      icon = Icons.cancel_rounded;
      text = 'Rupture';
    } else if (quantity < 5) {
      color = AppColors.warning;
      icon = Icons.warning_rounded;
      text = 'Stock faible';
    } else {
      color = AppColors.success;
      icon = Icons.check_circle_rounded;
      text = 'En stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
