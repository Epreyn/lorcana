import 'package:flutter/material.dart';
import '../../services/lorcana_api_service_debug.dart';

class ApiTestView extends StatefulWidget {
  const ApiTestView({super.key});

  @override
  State<ApiTestView> createState() => _ApiTestViewState();
}

class _ApiTestViewState extends State<ApiTestView> {
  final LorcanaApiServiceDebug _apiDebug = LorcanaApiServiceDebug();
  String _output = 'Appuyez sur un bouton pour tester l\'API';
  bool _isLoading = false;

  Future<void> _testAllEndpoints() async {
    setState(() {
      _isLoading = true;
      _output = 'Test en cours...';
    });

    try {
      // Capturer la sortie console
      await _apiDebug.testApiEndpoints();
      setState(() {
        _output = 'Test terminé. Vérifiez la console pour les résultats.';
      });
    } catch (e) {
      setState(() {
        _output = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSpecificEndpoint(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    setState(() {
      _isLoading = true;
      _output = 'Test de $endpoint...';
    });

    try {
      await _apiDebug.testSpecificEndpoint(endpoint, params: params);
      setState(() {
        _output = 'Test de $endpoint terminé. Vérifiez la console.';
      });
    } catch (e) {
      setState(() {
        _output = 'Erreur sur $endpoint: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test des APIs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllEndpoints,
              child: const Text('Tester tous les endpoints'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : () => _testSpecificEndpoint('/cards'),
              child: const Text('Tester /cards'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () =>
                          _testSpecificEndpoint('/cards', params: {'limit': 5}),
              child: const Text('Tester /cards avec limite'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () => _testSpecificEndpoint(
                        '/cards',
                        params: {'name': 'Elsa'},
                      ),
              child: const Text('Rechercher "Elsa"'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _output,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
