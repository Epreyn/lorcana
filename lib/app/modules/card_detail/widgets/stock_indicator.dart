import 'package:flutter/material.dart';

class StockIndicator extends StatelessWidget {
  final int quantity;

  const StockIndicator({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    if (quantity == 0) {
      color = Colors.red;
      icon = Icons.cancel;
      text = 'Rupture';
    } else if (quantity < 5) {
      color = Colors.orange;
      icon = Icons.warning;
      text = 'Stock faible';
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
      text = 'En stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
