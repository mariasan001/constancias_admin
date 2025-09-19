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
    const bg = Color(0xFFFAF7F2);
    const brand = Color(0xFF7D5C0F);
    final usuario = widget.usuario;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Confirmar datos del servidor",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black.withOpacity(0.08)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con avatar e info básica
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: brand.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_outline, color: brand),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                            ),
                            Text(
                              "Rol: ${usuario.roles.isNotEmpty ? usuario.roles.first.description : "Sin rol"}",
                              style: TextStyle(color: Colors.black.withOpacity(0.65)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Campo correo
                  TextFormField(
                    controller: _correoCtrl,
                    validator: (v) => v != null && v.contains("@") ? null : "Correo inválido",
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo teléfono
                  TextFormField(
                    controller: _telCtrl,
                    validator: (v) => v != null && v.length >= 10 ? null : "Teléfono inválido",
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Teléfono",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón CTA
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _guardar,
                      icon: const Icon(Icons.save_outlined),
                      label: _loading
                          ? const Text("Guardando...")
                          : const Text("Guardar y continuar"),
                      style: FilledButton.styleFrom(
                        backgroundColor: brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
