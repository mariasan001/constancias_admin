// lib/features/seguimiento/ui/seguimiento_page.dart
import 'package:constancias_admin/features/seguimiento/ui/seguimiento_service.dart';
import 'package:constancias_admin/features/seguimiento/ui/tramite_full.dart';
import 'package:flutter/material.dart';


class SeguimientoPage extends StatefulWidget {
  const SeguimientoPage({super.key});

  @override
  State<SeguimientoPage> createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  final _folioCtrl = TextEditingController();
  TramiteFull? tramite;
  String? errorMsg;
  bool loading = false;

  Future<void> _consultarTramite() async {
    final folio = _folioCtrl.text.trim();
    if (folio.isEmpty) {
      setState(() => errorMsg = "⚠️ Ingresa un folio válido");
      return;
    }

    setState(() {
      loading = true;
      tramite = null;
      errorMsg = null;
    });

    try {
      final result = await SeguimientoService.getTramiteByFolio(folio);
      if (result != null) {
        setState(() => tramite = result);
      } else {
        setState(() => errorMsg = "❌ Trámite no encontrado");
      }
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seguimiento por folio")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _folioCtrl,
              decoration: const InputDecoration(
                labelText: "Ingrese folio del trámite",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: loading ? null : _consultarTramite,
              icon: const Icon(Icons.search),
              label: const Text("Consultar"),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (errorMsg != null)
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
            if (tramite != null) Expanded(child: _tramiteCard(tramite!)),
          ],
        ),
      ),
    );
  }

  Widget _tramiteCard(TramiteFull data) {
    return ListView(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📑 Folio: ${data.folio}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("📌 Tipo: ${data.tramiteType}"),
                Text("👤 Usuario: ${data.userName} (${data.userId})"),
                Text("📊 Estatus actual: ${data.currentStatus}"),
                Text("🕒 Creado: ${data.createdAt}"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (data.history.isNotEmpty) ...[
          const Text("📜 Historial:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...data.history.map((h) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.timeline),
                  title: Text("${h.fromStatus} ➝ ${h.toStatus}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 Cambió: ${h.changedBy}"),
                      Text("🕒 Fecha: ${h.changedAt}"),
                      if (h.comment.isNotEmpty) Text("💬 ${h.comment}"),
                    ],
                  ),
                ),
              )),
        ] else
          const Text("Sin historial todavía."),
      ],
    );
  }
}
