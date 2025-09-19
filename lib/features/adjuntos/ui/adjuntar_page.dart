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
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RespuestaPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${resp.statusMessage}")),
        );
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

    // 🎨 Tokens (consistentes con tu línea)
    const bg = Color(0xFFFAF7F2); // marfil cálido
    const brand = Color(0xFF7D5C0F); // café acento
    const ink = Color(0xFF1F1D1B); // casi negro
    final muted = Colors.black.withOpacity(0.70);

    // progreso (obligatorio: INE; opcional: ALTA o BAJA)
    final docsCargados = [ine, alta, baja].where((e) => e != null).length;
    final pasos = 2; // 1: INE, 2: (ALTA o BAJA)
    final progreso = ( (ine != null ? 1 : 0) + ((alta != null || baja != null) ? 1 : 0) ) / pasos;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Adjuntar documentación',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black.withOpacity(0.08)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final isMobile = w < 720;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ====== Banner del trámite (si existe) ======
                if (tramite != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? 760 : 980),
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 14 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: brand.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tramite.icon, color: brand),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tramite.titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                        color: ink,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tramite.descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black.withOpacity(0.65)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ====== Tarjeta de usuario (si existe) ======
                if (usuario != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? 760 : 980),
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 14 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Encabezado
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
                                            height: 1.1,
                                          ),
                                    ),
                                    Text(
                                      usuario.roles.isNotEmpty
                                          ? usuario.roles.first.description
                                          : "Sin rol",
                                      style: TextStyle(color: muted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _infoRow(Icons.badge, "ID", usuario.userId),
                          _infoRow(Icons.email_outlined, "Correo", usuario.email),
                          _infoRow(Icons.phone_outlined, "Teléfono", usuario.phone ?? "No registrado"),
                          if (usuario.workUnit != null)
                            _infoRow(Icons.work_outline, "Unidad", usuario.workUnit!),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // ====== Sección de documentos ======
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 760 : 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado de sección
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf_outlined, size: 16, color: brand),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "PDF requeridos",
                                      style: TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${docsCargados}/3",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Items (tu widget DocumentoItem mantiene la lógica)
                      DocumentoItem(
                        icon: Icons.badge,
                        title: 'INE (obligatorio)',
                        value: ine,
                        onScan: () => _scan(context, DocumentoTipo.ine),
                        onRemove: ine == null
                            ? null
                            : () => context.read<FlowState>().removeDocumento(DocumentoTipo.ine),
                      ),
                      DocumentoItem(
                        icon: Icons.file_open,
                        title: 'Formato de ALTA',
                        value: alta,
                        onScan: () => _scan(context, DocumentoTipo.alta),
                        onRemove: alta == null
                            ? null
                            : () => context.read<FlowState>().removeDocumento(DocumentoTipo.alta),
                      ),
                      DocumentoItem(
                        icon: Icons.file_open_outlined,
                        title: 'Formato de BAJA',
                        value: baja,
                        onScan: () => _scan(context, DocumentoTipo.baja),
                        onRemove: baja == null
                            ? null
                            : () => context.read<FlowState>().removeDocumento(DocumentoTipo.baja),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ====== Progreso ======
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 760 : 980),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: progreso,
                            backgroundColor: Colors.black.withOpacity(0.06),
                            color: brand,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${(progreso * 100).round()}%",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ====== CTA Enviar ======
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 760 : 980),
                  child: SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: FilledButton.icon(
                        key: ValueKey<bool>(fs.documentosValidos),
                        onPressed: fs.documentosValidos ? () => _enviarSolicitud(context) : null,
                        icon: const Icon(Icons.send_rounded),
                        label: Text(
                          fs.documentosValidos ? 'Enviar solicitud' : 'Adjunta los documentos para continuar',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black.withOpacity(0.65)),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w700)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
