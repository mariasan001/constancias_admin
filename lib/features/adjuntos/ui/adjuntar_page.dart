import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';
import '../../../data/models.dart'; // Tramite, DocumentoAdjunto, DocumentoTipo
import '../../scanner/ui/scan_page.dart';
import '../widgets/documento_item.dart';
import '../../../data/model_buscar_user/models.dart'; // UserModel

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

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();

    // Documentos ya cargados
    final ine = fs.getDoc(DocumentoTipo.ine)?.uri;
    final alta = fs.getDoc(DocumentoTipo.alta)?.uri;
    final baja = fs.getDoc(DocumentoTipo.baja)?.uri;

    // Usuario obtenido en la búsqueda
    final UserModel? usuario = fs.usuario;

    // Trámite seleccionado en HomePage
    final Tramite? tramite = fs.tramite;

    return Scaffold(
      appBar: AppBar(title: const Text('Adjuntar documentación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Trámite seleccionado
            if (tramite != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: ListTile(
                  leading: Icon(tramite.icon,
                      size: 32, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    tramite.titulo,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(tramite.descripcion),
                ),
              ),

            // 🔹 Tarjeta con la info del usuario
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  usuario.roles.isNotEmpty
                                      ? usuario.roles.first.description
                                      : "Sin rol",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
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
                      _infoRow(Icons.phone, "Teléfono",
                          usuario.phone ?? "No registrado"),
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

            // 🔹 Documentos
            DocumentoItem(
              icon: Icons.badge,
              title: 'INE (obligatorio)',
              value: ine,
              onScan: () => _scan(context, DocumentoTipo.ine),
              onRemove: ine == null
                  ? null
                  : () =>
                      context.read<FlowState>().removeDocumento(DocumentoTipo.ine),
            ),
            DocumentoItem(
              icon: Icons.file_open,
              title: 'Formato de ALTA',
              value: alta,
              onScan: () => _scan(context, DocumentoTipo.alta),
              onRemove: alta == null
                  ? null
                  : () =>
                      context.read<FlowState>().removeDocumento(DocumentoTipo.alta),
            ),
            DocumentoItem(
              icon: Icons.file_open_outlined,
              title: 'Formato de BAJA',
              value: baja,
              onScan: () => _scan(context, DocumentoTipo.baja),
              onRemove: baja == null
                  ? null
                  : () =>
                      context.read<FlowState>().removeDocumento(DocumentoTipo.baja),
            ),

            const SizedBox(height: 20),

            // 🔹 Barra de progreso
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    value: [
                      ine != null ? 1 : 0,
                      (alta != null || baja != null) ? 1 : 0,
                    ].where((e) => e == 1).length / 2,
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

            // 🔹 Botón final
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: fs.documentosValidos
                    ? () => Navigator.of(context).pushNamed('/contacto')
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Iniciar proceso de constancia',
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
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
