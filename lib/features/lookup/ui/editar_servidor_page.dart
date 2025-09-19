// lib/features/buscar_servidor/ui/editar_servidor_page.dart
import 'package:constancias_admin/features/lookup/ui/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/flow_state.dart';
import '../../../data/model_buscar_user/models.dart';

class EditarServidorPage extends StatefulWidget {
  final UserModel usuario;
  const EditarServidorPage({super.key, required this.usuario});

  @override
  State<EditarServidorPage> createState() => _EditarServidorPageState();
}

class _EditarServidorPageState extends State<EditarServidorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _correoCtrl;
  late TextEditingController _telCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _correoCtrl = TextEditingController(text: widget.usuario.email);
    _telCtrl = TextEditingController(text: widget.usuario.phone ?? '');
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final actualizado = await UserService.updateUser(widget.usuario.userId, {
        "name": widget.usuario.name,
        "email": _correoCtrl.text.trim(),
        "phone": _telCtrl.text.trim(),
      });

      if (actualizado != null) {
        context.read<FlowState>().setUsuario(actualizado);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Información actualizada")),
        );

        context.push('/adjuntos');
      }
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
    final usuario = widget.usuario;

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar datos del servidor")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("👤 ${usuario.name}", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text("Rol: ${usuario.roles.isNotEmpty ? usuario.roles.first.description : "Sin rol"}"),
              const SizedBox(height: 20),

              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
                validator: (v) => v != null && v.contains("@") ? null : "Correo inválido",
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telCtrl,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
                validator: (v) => v != null && v.length >= 10 ? null : "Teléfono inválido",
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _guardar,
                  icon: const Icon(Icons.save),
                  label: _loading ? const Text("Guardando...") : const Text("Guardar y continuar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
