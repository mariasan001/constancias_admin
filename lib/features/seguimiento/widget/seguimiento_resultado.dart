import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard

class SeguimientoResultado extends StatelessWidget {
  final String? estado; // p.ej. "En revisión (estimado: 3 días hábiles)"
  final String folio; // para copiar al portapapeles
  final Color brandColor; // color institucional (café)
  final bool dense; // opción para compactar aún más

  const SeguimientoResultado({
    super.key,
    required this.estado,
    required this.folio,
    this.brandColor = const Color(0xFF7D5C0F),
    this.dense = false,
  });

  // ===== Helpers =====
  int _stageFromEstado(String s) {
    final lc = s.toLowerCase();
    if (lc.contains('final') || lc.contains('entrega') || lc.contains('listo'))
      return 2;
    if (lc.contains('revisión') || lc.contains('revision')) return 1;
    if (lc.contains('recib') || lc.contains('ingres')) return 0;
    return 1;
  }

  String _labelFromEstado(String s) {
    final m = RegExp(r'^[^(\n]+').firstMatch(s);
    return (m?.group(0) ?? s).trim();
  }

  String? _etaFromEstado(String s) {
    final m = RegExp(r'\((.*?)\)').firstMatch(s);
    return m != null ? m.group(1) : null;
  }

  Color _colorForStep(int step, int current) {
    if (step <= current) return brandColor;
    return Colors.black.withOpacity(0.25);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: estado == null
          ? const SizedBox.shrink()
          : LayoutBuilder(
              key: ValueKey(estado),
              builder: (context, c) {
                final w = c.maxWidth;
                final scale = MediaQuery.textScaleFactorOf(
                  context,
                ).clamp(1.0, 1.25);
                final isMobile = w < 700;

                final stage = _stageFromEstado(estado!);
                final label = _labelFromEstado(estado!);
                final eta = _etaFromEstado(estado!);

                // tokens responsivos
                final titleFS = (isMobile ? 16.0 : 18.0) * scale;
                final bodyFS = (isMobile ? 13.0 : 14.0) * scale;
                final chipFS = (isMobile ? 11.0 : 12.0) * scale;
                final dot = isMobile ? 12.0 : 14.0;
                final lineH = 2.0;

                Widget buildDot(int i) => Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: _colorForStep(i, stage),
                    shape: BoxShape.circle,
                  ),
                );

                Widget buildLine(int i) => Expanded(
                  child: Container(
                    height: lineH,
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: _colorForStep(
                        i,
                        stage,
                      ).withOpacity(i <= stage - 1 ? 1 : 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );

                final chip = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: brandColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stage == 2 ? Icons.check_circle : Icons.timelapse,
                        size: isMobile ? 16 : 18,
                        color: brandColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: chipFS,
                          fontWeight: FontWeight.w700,
                          color: brandColor,
                        ),
                      ),
                    ],
                  ),
                );

                final actions = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: folio.trim().toUpperCase()),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Folio copiado')),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar folio'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente: notificaciones'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Recibir notificaciones'),
                    ),
                  ],
                );

                return Card(
                  color: Colors.white, // 👈 fondo blanco
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isMobile ? (dense ? 10 : 14) : (dense ? 12 : 16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // encabezado
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: isMobile ? 36 : 40,
                              height: isMobile ? 36 : 40,
                              decoration: BoxDecoration(
                                color: brandColor.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                stage == 2
                                    ? Icons.verified_outlined
                                    : Icons.info_outline,
                                color: brandColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Estado de tu trámite',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: titleFS,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      chip,
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (eta != null)
                                    Text(
                                      eta,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: bodyFS,
                                            color: Colors.black.withOpacity(
                                              0.70,
                                            ),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            if (!isMobile) actions,
                          ],
                        ),

                        if (isMobile) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: actions,
                          ),
                        ],

                        const SizedBox(height: 14),

                        // timeline
                        Column(
                          children: [
                            Row(
                              children: [
                                buildDot(0),
                                buildLine(0),
                                buildDot(1),
                                buildLine(1),
                                buildDot(2),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recibido',
                                  style: TextStyle(
                                    fontSize: bodyFS,
                                    color: _colorForStep(0, stage),
                                  ),
                                ),
                                Text(
                                  'En revisión',
                                  style: TextStyle(
                                    fontSize: bodyFS,
                                    color: _colorForStep(1, stage),
                                  ),
                                ),
                                Text(
                                  'Finalizado',
                                  style: TextStyle(
                                    fontSize: bodyFS,
                                    color: _colorForStep(2, stage),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // progreso
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOut,
                          tween: Tween(begin: 0, end: (stage + 1) / 3),
                          builder: (context, value, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: isMobile ? 6 : 8,
                                color: brandColor,
                                backgroundColor: Colors.black.withOpacity(0.10),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
