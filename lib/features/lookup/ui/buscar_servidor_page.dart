import 'package:constancias_admin/data/model_buscar_user/models.dart'
    show UserModel;
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

    // Validación simple (solo dígitos, largo 5–12)
    final isValid = RegExp(r'^\d{5,12}$').hasMatch(numero);
    if (!isValid) {
      setState(() {
        _error = "Número inválido, deben ser 5 a 12 dígitos";
        _usuario = null;
      });
      debugPrint("[BuscarServidor] ❌ Número inválido: $numero");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _usuario = null;
    });

    debugPrint("[BuscarServidor] 🔎 Buscando usuario con ID: $numero");

    try {
      final user = await UserService.getUserById(numero);

      debugPrint(
        "[BuscarServidor] ✅ Usuario encontrado: ${user.name} - ${user.email}",
      );

      if (!mounted) return;
      setState(() {
        _usuario = user;
        _loading = false;
      });
    } on DioException catch (e) {
      debugPrint("[BuscarServidor] ❌ DioException");
      debugPrint("→ Type: ${e.type}");
      debugPrint("→ Message: ${e.message}");
      debugPrint("→ Response: ${e.response?.data}");
      debugPrint("→ Status code: ${e.response?.statusCode}");

      if (!mounted) return;
      setState(() {
        _error = "No encontrado. Verifica el número o consulta con RH.";
        _loading = false;
        _usuario = null;
      });
    } catch (e, stack) {
      debugPrint("[BuscarServidor] ⚠️ Error inesperado: $e");
      debugPrint(stack.toString());

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
    final fs = context.read<FlowState>();

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
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
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
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _usuario!.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _usuario!.roles.isNotEmpty
                                      ? _usuario!.roles.first.description
                                      : "Sin rol",
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _infoRow(Icons.badge, "ID", _usuario!.userId),
                      _infoRow(Icons.email, "Correo", _usuario!.email),
                      _infoRow(
                        Icons.phone,
                        "Teléfono",
                        _usuario!.phone ?? "No registrado",
                      ),
                      _infoRow(
                        Icons.credit_card,
                        "RFC",
                        _usuario!.rfc ?? "No registrado",
                      ),
                      _infoRow(
                        Icons.credit_card_outlined,
                        "CURP",
                        _usuario!.curp ?? "No registrado",
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            context.push("/adjuntar"); // 👈 o Navigator.push
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("Continuar con documentación"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _infoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
