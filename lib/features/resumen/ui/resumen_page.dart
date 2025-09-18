import 'package:constancias_admin/data/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';

class ResumenPage extends StatefulWidget {
  const ResumenPage({super.key});

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {

  bool _sending = false;
  String? _folio;

  Future<void> _enviar() async {
    final fs = context.read<FlowState>();
    if (!fs.solicitud.consentimiento) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar el aviso de privacidad.')),
      );
      return;
    }
    setState(() => _sending = true);


  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();
    final s = fs.solicitud;

    return Scaffold(
      appBar: AppBar(title: const Text('Revisa y envía tu solicitud')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Trámite'),
                subtitle: Text(s.tramite?.titulo ?? '-'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Servidor público'),
                subtitle: Text(
                  s.servidor == null
                      ? '-'
                      : '${s.servidor!.nombre}\n${s.servidor!.dependencia}  •  Nº ${s.servidor!.numero}',
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Documentos'),
                subtitle: Text(
                  s.documentos.isEmpty ? '-' : s.documentos.map((d) => '${d.tipo.titulo}: ${d.uri}').join('\n'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Contacto'),
                subtitle: Text(
                  '${s.contacto.telefono ?? '-'}  •  ${s.contacto.email ?? '-'}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: s.consentimiento,
              onChanged: (v) => fs.setConsentimiento(v ?? false),
              title: const Text('Acepto el aviso de privacidad.'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _sending ? null : _enviar,
              icon: const Icon(Icons.cloud_upload),
              label: Text(_sending ? 'Enviando…' : 'Enviar solicitud'),
            ),
            if (_folio != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green[50],
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Solicitud enviada. Folio: $_folio'),
                  subtitle: const Text('Usa tu folio para dar seguimiento.'),
                  trailing: FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed('/seguimiento'),
                    child: const Text('Ir a seguimiento'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
