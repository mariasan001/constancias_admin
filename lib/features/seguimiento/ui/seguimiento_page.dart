import 'package:flutter/material.dart';

class SeguimientoPage extends StatefulWidget {
  const SeguimientoPage({super.key});

  @override
  State<SeguimientoPage> createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  final _folio = TextEditingController();
  String? _estado;

  Future<void> _consultar() async {
    setState(() => _estado = null);
    await Future.delayed(const Duration(milliseconds: 600));
    // demo
    setState(() => _estado = 'En revisión (estimado: 3 días hábiles)');
  }

  @override
  void dispose() {
    _folio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _folio,
              decoration: const InputDecoration(
                labelText: 'Folio',
                hintText: 'Ej. CON-2025-000123',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _consultar,
              icon: const Icon(Icons.search),
              label: const Text('Consultar estado'),
            ),
            const SizedBox(height: 16),
            if (_estado != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Estado'),
                  subtitle: Text(_estado!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
