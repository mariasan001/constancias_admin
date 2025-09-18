// lib/features/solicitudes/ui/submit_page.dart
import 'package:constancias_admin/data/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});
  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  bool _sending = false;
  String? _msg;

  Future<void> _enviar() async {
    setState(() {
      _sending = true;
      _msg = null;
    });

    try {
               // guarda folio en estado (opcional)

      setState(() {


      });
    } catch (e) {
      setState(() {
        _msg = 'Error al enviar: $e';
      });
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<FlowState>().solicitud;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar solicitud')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen muy breve (opcional)
            Card(
              child: ListTile(
                title: const Text('Resumen'),
                subtitle: Text(
                  'Trámite: ${s.tramite?.titulo ?? '-'}\n'
                  'Servidor: ${s.servidor?.nombre ?? '-'} (${s.servidor?.numero ?? '-'})\n'
                  'Docs: ${s.documentos.length} archivo(s)\n'
                  'Contacto: ${s.contacto.telefono ?? '-'} • ${s.contacto.email ?? '-'}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _sending ? null : _enviar,
              icon: const Icon(Icons.cloud_upload),
              label: Text(_sending ? 'Enviando…' : 'Enviar'),
            ),
            const SizedBox(height: 16),

            if (_sending) const LinearProgressIndicator(),
            if (_msg != null) ...[
              const SizedBox(height: 12),
              Text(_msg!),
            ],
          ],
        ),
      ),
    );
  }
}
