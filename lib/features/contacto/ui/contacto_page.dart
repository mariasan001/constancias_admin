import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';

class ContactoPage extends StatefulWidget {
  const ContactoPage({super.key});

  @override
  State<ContactoPage> createState() => _ContactoPageState();
}

class _ContactoPageState extends State<ContactoPage> {
  final _tel = TextEditingController();
  final _mail = TextEditingController();

  @override
  void dispose() {
    _tel.dispose();
    _mail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();
    return Scaffold(
      appBar: AppBar(title: const Text('¿Cómo te notificamos?')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (10 dígitos)',
                hintText: '55XXXXXXXX',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'tucorreo@dominio.com',
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                context.read<FlowState>().setContacto(
                      tel: _tel.text.trim().isEmpty ? null : _tel.text.trim(),
                      email: _mail.text.trim().isEmpty ? null : _mail.text.trim(),
                    );
                if (!fs.contactoValido) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Captura al menos un medio válido (teléfono o correo).')),
                  );
                  return;
                }
                Navigator.of(context).pushNamed('/resumen');
              },
              icon: const Icon(Icons.check),
              label: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
