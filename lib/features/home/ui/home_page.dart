import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';
import '../../../data/models.dart';
import 'widgets/tramite_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  IconData _iconFor(Tramite t) => switch (t) {
        Tramite.constanciaLaboral => Icons.work,
        Tramite.constanciaSueldo => Icons.payments,
        Tramite.constanciaAntiguedad => Icons.timer,
        Tramite.constanciaNoInhabilitacion => Icons.verified_user,
      };

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FlowState>();
    final tramites = Tramite.values;

    return Scaffold(
      appBar: AppBar(title: const Text('Constancias')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Elige el tipo de constancia que necesitas. Te tomará menos de 5 minutos.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            for (final t in tramites)
              TramiteCard(
                icon: _iconFor(t),
                title: t.titulo,
                subtitle: t.descripcion,
                onTap: () {
                  fs.setTramite(t);
                  context.go('/buscar');
                },
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/seguimiento'),
              icon: const Icon(Icons.track_changes),
              label: const Text('Consultar seguimiento por folio'),
            ),
          ],
        ),
      ),
    );
  }
}
