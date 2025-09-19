import 'package:constancias_admin/data/model_buscar_user/models.dart' show UserModel;
import 'package:constancias_admin/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/flow_state.dart';

// Servicio de usuario (GET y PUT)
class UserService {
  static Future<UserModel> getUserById(String userId) async {
    final resp = await ApiService.dio.get('/api/users/$userId');
    return UserModel.fromJson(resp.data);
  }

  static Future<UserModel> updateUser(String userId, Map<String, dynamic> data) async {
    final resp = await ApiService.dio.put('/api/users/$userId', data: data);
    return UserModel.fromJson(resp.data);
  }
}

class BuscarServidorPage extends StatefulWidget {
  const BuscarServidorPage({super.key});

  @override
  State<BuscarServidorPage> createState() => _BuscarServidorPageState();
}

class _BuscarServidorPageState extends State<BuscarServidorPage> {
  final _controller = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  UserModel? _usuario;

  @override
  void dispose() {
    _controller.dispose();
    _correoCtrl.dispose();
    _telCtrl.dispose();
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
        _correoCtrl.text = user.email;
        _telCtrl.text = user.phone ?? "";
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

  Future<void> _guardar() async {
    if (_usuario == null) return;

    setState(() => _loading = true);

    try {
      final actualizado = await UserService.updateUser(_usuario!.userId, {
        "name": _usuario!.name,
        "email": _correoCtrl.text.trim(),
        "phone": _telCtrl.text.trim(),
      });

      if (!mounted) return;
      context.read<FlowState>().setUsuario(actualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Información actualizada")),
      );

      context.push('/adjuntos');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al actualizar: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
            // Campo de búsqueda
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
                      Text("👤 Nombre: ${_usuario!.name}",
                          style: Theme.of(context).textTheme.titleMedium),
                      Text("Rol: ${_usuario!.roles.isNotEmpty ? _usuario!.roles.first.description : 'Sin rol'}"),
                      const SizedBox(height: 16),

                      // Campos editables
                      TextField(
                        controller: _correoCtrl,
                        decoration: const InputDecoration(labelText: "Correo electrónico"),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "Teléfono"),
                      ),
                      const SizedBox(height: 20),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _loading ? null : _guardar,
                              icon: const Icon(Icons.save),
                              label: const Text("Guardar y continuar"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/adjuntos'),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text("Es correcto, continuar"),
                            ),
                          ),
                        ],
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
