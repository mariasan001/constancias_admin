import 'package:constancias_admin/data/model_buscar_user/models.dart' show UserModel;
import 'package:constancias_admin/services/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/flow_state.dart';

class BuscarServidorPage extends StatefulWidget {
  const BuscarServidorPage({super.key});

  @override
  State<BuscarServidorPage> createState() => _BuscarServidorPageState();
}

class _BuscarServidorPageState extends State<BuscarServidorPage> {
  final _controller = TextEditingController();

  bool _loading = false;
  String? _error;
  UserModel? _usuario;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final numero = _controller.text.trim();

    // Validación básica
    final isValid = RegExp(r'^\d{5,12}$').hasMatch(numero);
    if (!isValid) {
      setState(() {
        _error = "Número inválido, deben ser 5 a 12 dígitos";
        _usuario = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _usuario = null;
    });

    try {
      final user = await UserService.getUserById(numero);

      if (!mounted) return;
      setState(() {
        _usuario = user;
        _loading = false;
      });

      // Guardar en FlowState
      context.read<FlowState>().setUsuario(user);
    } on DioException {
      if (!mounted) return;
      setState(() {
        _error = "No encontrado. Verifica el número o consulta con RH.";
        _loading = false;
        _usuario = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Ocurrió un error inesperado";
        _loading = false;
        _usuario = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar servidor público')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loading ? null : _buscar(),
              decoration: InputDecoration(
                labelText: 'Número de servidor público',
                hintText: 'Ej. 210000884',
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _usuario = null;
                            _error = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
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

            if (_error != null && !_loading)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),

            if (_usuario != null && !_loading) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nombre: ${_usuario!.name}"),
                      Text("Correo: ${_usuario!.email}"),
                      Text(
                        "Rol: ${_usuario!.roles.isNotEmpty ? _usuario!.roles.first.description : 'Sin rol'}",
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            context.push('/adjuntos');
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("Continuar"),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
