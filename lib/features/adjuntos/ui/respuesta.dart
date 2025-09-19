import 'package:constancias_admin/features/home/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';

class RespuestaPage extends StatelessWidget {
  const RespuestaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();
    final solicitud = fs.solicitud;

    return Scaffold(
      appBar: AppBar(title: const Text("Resumen de la solicitud")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 12),
                const Text(
                  "✅ Solicitud enviada con éxito",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "📑 Folio generado:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  solicitud.folio ?? "No disponible",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const HomePage()));
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Regresar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
