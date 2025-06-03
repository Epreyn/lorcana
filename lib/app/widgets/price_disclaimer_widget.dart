import 'package:flutter/material.dart';
import '../config/app_config.dart';

class PriceDisclaimerWidget extends StatelessWidget {
  const PriceDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.amber[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppConfig.priceDisclaimer,
              style: TextStyle(fontSize: 12, color: Colors.amber[900]),
            ),
          ),
        ],
      ),
    );
  }
}
