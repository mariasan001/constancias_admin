//lib/features/admins/ui/admin_form_page.dart
import 'package:flutter/material.dart';
import '../../scanner/ui/scan_page.dart'; // Para recibir anexos escaneados
import '../../../data/admin_model.dart';

class AdminFormPage extends StatefulWidget {
  const AdminFormPage({super.key});
  @override
  State<AdminFormPage> createState() => _AdminFormPageState();
}

class _AdminFormPageState extends State<AdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _anexos = <String>[]; // paths a PDFs/imagenes
  // Controladores
  final _nombre = TextEditingController();
  final _curp = TextEditingController();
  final _rfc = TextEditingController();
  final _cargo = TextEditingController();
  final _dep = TextEditingController();
  final _correo = TextEditingController();
  final _tel = TextEditingController();
  final _dir = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nombre, _curp, _rfc, _cargo, _dep, _correo, _tel, _dir]) {
      c.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState?.validate() != true) return;
    final admin = AdminModel(
      nombreCompleto: _nombre.text.trim(),
      curp: _curp.text.trim().toUpperCase(),
      rfc: _rfc.text.trim().toUpperCase(),
      cargo: _cargo.text.trim(),
      dependencia: _dep.text.trim(),
      correo: _correo.text.trim(),
      telefono: _tel.text.trim(),
      direccion: _dir.text.trim().isEmpty ? null : _dir.text.trim(),
      anexos: List.unmodifiable(_anexos),
    );
    // TODO: manda a tu API/almacenamiento local
    debugPrint('ADMIN A ENVIAR: ${admin.toJson()}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos validados. Listo para enviar.')),
    );
  }

  Future<void> _agregarAnexo() async {
    // Navegamos a la pantalla de escaneo y esperamos un path de archivo
    final res = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanPage(returnPath: true)),
    );
    if (res != null) {
      setState(() => _anexos.add(res));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de administrador')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _curp,
              decoration: const InputDecoration(labelText: 'CURP'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.length < 18) ? 'CURP inválida' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _rfc,
              decoration: const InputDecoration(labelText: 'RFC'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.length < 12) ? 'RFC inválido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cargo,
              decoration: const InputDecoration(labelText: 'Cargo'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dep,
              decoration: const InputDecoration(labelText: 'Dependencia/Unidad'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _correo,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v != null && v.contains('@')) ? null : 'Correo inválido',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tel,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v != null && v.length >= 10) ? null : 'Teléfono inválido',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dir,
              decoration: const InputDecoration(labelText: 'Dirección (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Anexos escaneados
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _agregarAnexo,
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Agregar anexo (escaneo)'),
                ),
                const SizedBox(width: 12),
                Text('${_anexos.length} archivo(s)'),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: const Text('Guardar / Validar'),
            ),
          ],
        ),
      ),
    );
  }
}

