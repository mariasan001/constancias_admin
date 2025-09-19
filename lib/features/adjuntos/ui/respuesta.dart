import 'package:constancias_admin/features/home/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';

/// Paleta institucional
const _negro  = Color(0xFF1A1A1A);
const _vino   = Color(0xFF9F2141);
const _cafe   = Color(0xFF7D5C0F);
const _marfil = Color(0xFFFAF7F2);

class RespuestaPage extends StatefulWidget {
  const RespuestaPage({super.key});

  @override
  State<RespuestaPage> createState() => _RespuestaPageState();
}

class _RespuestaPageState extends State<RespuestaPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scaleIn;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _scaleIn = CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack);
    _fadeIn  = CurvedAnimation(parent: _ctl, curve: Curves.easeOut);
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FlowState>();
    final folio = fs.solicitud.folio ?? "No disponible";

    return Scaffold(
      backgroundColor: _marfil,
      appBar: AppBar(
        backgroundColor: _marfil,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Resumen de la solicitud",
          style: TextStyle(fontWeight: FontWeight.w800, color: _negro),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black.withOpacity(0.08)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: FadeTransition(
                opacity: _fadeIn,
                child: _ReceiptCard(
                  folio: folio,
                  scaleIn: _scaleIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String folio;
  final Animation<double> scaleIn;

  const _ReceiptCard({required this.folio, required this.scaleIn});

  @override
  Widget build(BuildContext context) {
    final isOk = folio.isNotEmpty && folio != "No disponible";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Medallón de éxito
            ScaleTransition(
              scale: scaleIn,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _vino.withOpacity(0.95),
                      _vino.withOpacity(0.80),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _vino.withOpacity(0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            // Título
            Text(
              "Solicitud enviada con éxito",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: _negro,
                    height: 1.1,
                  ),
            ),

            const SizedBox(height: 8),
            Text(
              "Hemos recibido tu información. Guarda tu folio para seguimiento.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black.withOpacity(0.70),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 18),

            // Folio destacado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _marfil,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _cafe.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.confirmation_number_outlined, color: _cafe),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Folio generado",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _negro,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          folio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: _negro,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Copiar folio',
                    child: OutlinedButton.icon(
                      onPressed: isOk
                          ? () async {
                              await Clipboard.setData(ClipboardData(text: folio));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("📋 Folio copiado")),
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.copy_rounded, size: 18, color: _negro),
                      label: const Text(
                        "Copiar",
                        style: TextStyle(color: _negro, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black.withOpacity(0.16)),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Acciones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    icon: const Icon(Icons.home_outlined, color: _negro),
                    label: const Text(
                      "Ir al inicio",
                      style: TextStyle(color: _negro, fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black.withOpacity(0.18), width: 1.2),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // si tienes una ruta de seguimiento por folio, podrías hacer context.go('/seguimiento?folio=$folio')
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    icon: const Icon(Icons.track_changes_rounded),
                    label: const Text(
                      "Seguir trámite",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _cafe,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _vino.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _vino.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _vino),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: _vino,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
