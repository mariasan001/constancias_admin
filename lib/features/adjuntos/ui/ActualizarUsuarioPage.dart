import 'dart:convert';
import 'package:constancias_admin/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../data/flow_state.dart';

class ActualizarUsuarioPage extends StatefulWidget {
  const ActualizarUsuarioPage({super.key});

  @override
  State<ActualizarUsuarioPage> createState() => _ActualizarUsuarioPageState();
}

class _ActualizarUsuarioPageState extends State<ActualizarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _actualizarUsuario(BuildContext context) async {
    final fs = context.read<FlowState>();
    final usuario = fs.usuario;

    if (usuario == null) return;

    if (!_formKey.currentState!.validate()) return;

    final payload = {
      "name": usuario.name,

      "email": _emailCtrl.text.trim(),
      "phone": _telefonoCtrl.text.trim(),
      "active": true,
      // 👇 si no mandas campos, puedes poner null

    };

    setState(() => _loading = true);

    try {
      final resp = await ApiService.dio.put(
        "/api/users/${usuario.userId}",
        data: jsonEncode(payload),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      debugPrint("✅ Usuario actualizado:");
      debugPrint("Status: ${resp.statusCode}");
      debugPrint("Data: ${resp.data}");

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Información actualizada")),
        );
        Navigator.of(context).pop(); // 👈 regresar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${resp.statusMessage}")),
        );
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar usuario (Dio)")),
      );
    } catch (e) {
      debugPrint("⚠️ Error inesperado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error inesperado al actualizar usuario")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();
    final usuario = fs.usuario;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text("No hay usuario cargado")),
      );
    }

    // Prefill
    _telefonoCtrl.text = usuario.phone ?? "";
    _emailCtrl.text = usuario.email;

    return Scaffold(
      appBar: AppBar(title: const Text("Actualizar usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.length < 10) ? "Teléfono inválido" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) =>
                    (v == null || !v.contains("@")) ? "Correo inválido" : null,
              ),
              const SizedBox(height: 30),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _actualizarUsuario(context),
                        icon: const Icon(Icons.save),
                        label: const Text("Guardar cambios"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
