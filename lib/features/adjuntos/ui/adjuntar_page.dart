import 'dart:convert'; // 👈 para jsonEncode
import 'package:constancias_admin/features/adjuntos/ui/respuesta.dart';

import 'package:constancias_admin/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/flow_state.dart';
import '../../../data/models.dart'; // Tramite, DocumentoAdjunto, DocumentoTipo
import '../../../data/model_buscar_user/models.dart'; // UserModel
import '../../../services/dio.dart'; // ApiService
import '../../scanner/ui/scan_page.dart';
import '../widgets/documento_item.dart';

class AdjuntarPage extends StatelessWidget {
  const AdjuntarPage({super.key});

  Future<void> _scan(BuildContext context, DocumentoTipo tipo) async {
    final pathOrUri = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanPage(returnPath: true)),
    );
    if (pathOrUri == null) return;
    context.read<FlowState>().addDocumento(
      DocumentoAdjunto(tipo: tipo, uri: pathOrUri),
    );
  }

  Future<void> _enviarSolicitud(BuildContext context) async {
    final fs = context.read<FlowState>();
    final usuario = fs.usuario;
    final tramite = fs.tramite;
    final docs = fs.solicitud.documentos;

    if (usuario == null || tramite == null || docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Faltan datos para enviar la solicitud"),
        ),
      );
      return;
    }

    // ✅ payload
    final payload = {
      "tramiteTypeId": tramite.id,
      "userId": usuario.userId,
      "notes": "Solicitud desde app móvil",
    };

    try {
      final formData = FormData.fromMap({
        "payload": jsonEncode(payload),
        "files": [
          for (var d in docs)
            await MultipartFile.fromFile(
              d.uri,
              filename: d.uri.split('/').last,
              contentType: DioMediaType("application", "pdf"),
            ),
        ],
        "docTypeIds": [for (var d in docs) d.tipo.index + 1],
      });

      debugPrint("📤 Enviando solicitud...");
      debugPrint("Payload (string): ${jsonEncode(payload)}");
      debugPrint("Archivos: ${docs.map((d) => d.uri).toList()}");

      final resp = await ApiService.dio.post(
        "/api/tramites/create-with-docs",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      debugPrint("✅ Respuesta completa:");
      debugPrint("Status: ${resp.statusCode}");
      debugPrint("Data: ${resp.data}");

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;

        // ✅ Guarda el folio en FlowState
        fs.setFolio(data["folio"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Solicitud enviada con éxito")),
        );

        // 👉 Redirige a ResumenPage
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RespuestaPage()));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${resp.statusMessage}")));
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException:");
      debugPrint("Message: ${e.message}");
      debugPrint("Response: ${e.response}");
      debugPrint("Data: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar la solicitud (Dio)")),
      );
    } catch (e, st) {
      debugPrint("⚠️ Error inesperado: $e");
      debugPrint("Stack: $st");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error inesperado al enviar la solicitud"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();

    final ine = fs.getDoc(DocumentoTipo.ine)?.uri;
    final alta = fs.getDoc(DocumentoTipo.alta)?.uri;
    final baja = fs.getDoc(DocumentoTipo.baja)?.uri;

    final UserModel? usuario = fs.usuario;
    final Tramite? tramite = fs.tramite;

    return Scaffold(
      appBar: AppBar(title: const Text('Adjuntar documentación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tramite != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: ListTile(
                  leading: Icon(
                    tramite.icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    tramite.titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(tramite.descripcion),
                ),
              ),

            if (usuario != null)
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
                                  usuario.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  usuario.roles.isNotEmpty
                                      ? usuario.roles.first.description
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
                      const SizedBox(height: 12),
                      _infoRow(Icons.badge, "ID", usuario.userId),
                      _infoRow(Icons.email, "Correo", usuario.email),
                      _infoRow(
                        Icons.phone,
                        "Teléfono",
                        usuario.phone ?? "No registrado",
                      ),
                      if (usuario.workUnit != null)
                        _infoRow(Icons.work, "Unidad", usuario.workUnit!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
            const Text(
              '📑 Escanea tus documentos (PDF):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            DocumentoItem(
              icon: Icons.badge,
              title: 'INE (obligatorio)',
              value: ine,
              onScan: () => _scan(context, DocumentoTipo.ine),
              onRemove: ine == null
                  ? null
                  : () => context.read<FlowState>().removeDocumento(
                      DocumentoTipo.ine,
                    ),
            ),
            DocumentoItem(
              icon: Icons.file_open,
              title: 'Formato de ALTA',
              value: alta,
              onScan: () => _scan(context, DocumentoTipo.alta),
              onRemove: alta == null
                  ? null
                  : () => context.read<FlowState>().removeDocumento(
                      DocumentoTipo.alta,
                    ),
            ),
            DocumentoItem(
              icon: Icons.file_open_outlined,
              title: 'Formato de BAJA',
              value: baja,
              onScan: () => _scan(context, DocumentoTipo.baja),
              onRemove: baja == null
                  ? null
                  : () => context.read<FlowState>().removeDocumento(
                      DocumentoTipo.baja,
                    ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    value:
                        [
                          ine != null ? 1 : 0,
                          (alta != null || baja != null) ? 1 : 0,
                        ].where((e) => e == 1).length /
                        2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${[ine, alta, baja].where((e) => e != null).length}/3',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: fs.documentosValidos
                    ? () => _enviarSolicitud(context)
                    : null,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Enviar solicitud',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}
