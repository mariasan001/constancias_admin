import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';
import '../../../data/models.dart';
import '../../scanner/ui/scan_page.dart';
import '../widgets/documento_item.dart';

class AdjuntarPage extends StatelessWidget {
  const AdjuntarPage({super.key});

  Future<void> _scan(BuildContext context, DocumentoTipo tipo) async {
    final pathOrUri = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanPage(returnPath: true)),
    );
    if (pathOrUri == null) return;
    context.read<FlowState>().addDocumento(DocumentoAdjunto(tipo: tipo, uri: pathOrUri));
  }

  @override
    Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();
    final ine = fs.getDoc(DocumentoTipo.ine)?.uri;
    final alta = fs.getDoc(DocumentoTipo.alta)?.uri;
    final baja = fs.getDoc(DocumentoTipo.baja)?.uri;

    return Scaffold(
      appBar: AppBar(title: const Text('Adjuntar documentación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Escanea tus documentos en PDF. Se verán nítidos y listos para enviar.'),
            ),
            const SizedBox(height: 12),
            DocumentoItem(
              icon: Icons.badge,
              title: 'INE (obligatorio)',
              value: ine,
              onScan: () => _scan(context, DocumentoTipo.ine),
              onRemove: ine == null ? null : () => context.read<FlowState>().removeDocumento(DocumentoTipo.ine),
            ),
            DocumentoItem(
              icon: Icons.file_open,
              title: 'Formato de ALTA',
              value: alta,
              onScan: () => _scan(context, DocumentoTipo.alta),
              onRemove: alta == null ? null : () => context.read<FlowState>().removeDocumento(DocumentoTipo.alta),
            ),
            DocumentoItem(
              icon: Icons.file_open_outlined,
              title: 'Formato de BAJA',
              value: baja,
              onScan: () => _scan(context, DocumentoTipo.baja),
              onRemove: baja == null ? null : () => context.read<FlowState>().removeDocumento(DocumentoTipo.baja),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: [
                      ine != null ? 1 : 0,
                      (alta != null || baja != null) ? 1 : 0,
                    ].where((e) => e == 1).length / 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text('${[ine, alta, baja].where((e) => e != null).length}/3'),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: fs.documentosValidos ? () => Navigator.of(context).pushNamed('/contacto') : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar proceso de constancia'),
            ),
          ],
        ),
      ),
    );
  }
}
