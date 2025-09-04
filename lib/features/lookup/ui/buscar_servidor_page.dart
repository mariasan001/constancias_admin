import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';
import '../../../data/models.dart';
import '../../../services/api_client.dart';

class BuscarServidorPage extends StatefulWidget {
  const BuscarServidorPage({super.key});

  @override
  State<BuscarServidorPage> createState() => _BuscarServidorPageState();
}

class _BuscarServidorPageState extends State<BuscarServidorPage> {
  final _controller = TextEditingController();
  final _api = ApiClient();
  ServidorPublico? _result;
  bool _loading = false;

  Future<void> _buscar() async {
    setState(() { _loading = true; _result = null; });
    final r = await _api.buscarServidorPorNumero(_controller.text);
    setState(() { _loading = false; _result = r; });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FlowState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar servidor público')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de servidor público',
                hintText: 'Ej. 123456',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loading ? null : _buscar,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
            ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            if (_result != null) Card(
              child: ListTile(
                leading: const Icon(Icons.badge),
                title: Text(_result!.nombre),
                subtitle: Text('${_result!.dependencia}  •  Nº ${_result!.numero}'),
                trailing: FilledButton(
                  onPressed: () {
                    fs.setServidor(_result!);
                    context.go('/adjuntos');
                  },
                  child: const Text('Continuar'),
                ),
              ),
            ),
            if (!_loading && _result == null && _controller.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No encontrado. Verifica el número o acude a RH.'),
              ),
          ],
        ),
      ),
    );
  }
}
