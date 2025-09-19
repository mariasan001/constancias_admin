// lib/features/seguimiento/ui/seguimiento_page.dart
import 'package:constancias_admin/features/seguimiento/ui/seguimiento_service.dart';
import 'package:constancias_admin/features/seguimiento/ui/tramite_full.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta institucional
const _negro  = Color(0xFF1A1A1A);
const _vino   = Color(0xFF9F2141);
const _cafe   = Color(0xFF7D5C0F);
const _marfil = Color(0xFFFAF7F2);

class SeguimientoPage extends StatefulWidget {
  const SeguimientoPage({super.key});

  @override
  State<SeguimientoPage> createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  final _folioCtrl = TextEditingController();
  final _focus = FocusNode();

  TramiteFull? tramite;
  String? errorMsg;
  bool loading = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _folioCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _consultarTramite() async {
    final folio = _folioCtrl.text.trim();
    if (folio.isEmpty) {
      setState(() => errorMsg = "⚠️ Ingresa un folio válido");
      return;
    }

    setState(() {
      loading = true;
      tramite = null;
      errorMsg = null;
    });

    try {
      final result = await SeguimientoService.getTramiteByFolio(folio);
      if (!mounted) return;
      if (result != null) {
        setState(() => tramite = result);
      } else {
        setState(() => errorMsg = "❌ Trámite no encontrado");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => errorMsg = "⚠️ Ocurrió un error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _marfil,
      appBar: AppBar(
        backgroundColor: _marfil,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Seguimiento por folio",
          style: TextStyle(fontWeight: FontWeight.w800, color: _negro),
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
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 18),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 760 : 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Spotlight search
                    _SpotlightSearch(
                      controller: _folioCtrl,
                      focusNode: _focus,
                      focused: _focused,
                      loading: loading,
                      onSearch: _consultarTramite,
                    ),
                    const SizedBox(height: 12),

                    // Ayuda / Paste rápido
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HintChip(label: 'Ej. 2025-ABC-000123', onTap: () => _folioCtrl.text = '2025-ABC-000123'),
                          _HintChip(
                            label: 'Pegar',
                            icon: Icons.content_paste_rounded,
                            onTap: () async {
                              final data = await Clipboard.getData('text/plain');
                              if (data?.text != null) {
                                setState(() => _folioCtrl.text = data!.text!.trim());
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (loading)
                      const LinearProgressIndicator(minHeight: 3),

                    if (errorMsg != null && !loading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMsg!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Resultado
                    if (tramite != null) ...[
                      _SummaryCard(data: tramite!),
                      const SizedBox(height: 16),
                      _TimelineCard(data: tramite!),
                    ],

                    // Estado vacío
                    if (tramite == null && errorMsg == null && !loading) ...[
                      const SizedBox(height: 24),
                      _EmptyState(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// =======================
/// Widgets de la pantalla
/// =======================

class _SpotlightSearch extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool loading;
  final VoidCallback onSearch;

  const _SpotlightSearch({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.loading,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? _cafe.withOpacity(0.40) : Colors.black.withOpacity(0.06),
          width: focused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(focused ? 0.08 : 0.04),
            blurRadius: focused ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _cafe.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.confirmation_number_outlined, color: _cafe, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => loading ? null : onSearch(),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "Ingresa tu folio de trámite",
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.35),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _negro,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: loading
                ? const SizedBox(
                    key: ValueKey('ld'),
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : FilledButton.icon(
                    key: const ValueKey('btn'),
                    onPressed: onSearch,
                    icon: const Icon(Icons.search),
                    label: const Text("Consultar"),
                    style: FilledButton.styleFrom(
                      backgroundColor: _cafe,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TramiteFull data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
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
                  color: _vino.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: _vino),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Resumen del trámite",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _negro,
                      ),
                ),
              ),
              _StatusBadge(text: data.currentStatus),
            ],
          ),

          const SizedBox(height: 14),
          _InfoRow(icon: Icons.confirmation_number_outlined, label: "Folio", value: data.folio),
          _InfoRow(icon: Icons.description_outlined, label: "Tipo", value: data.tramiteType),
          _InfoRow(icon: Icons.person_outline, label: "Usuario", value: "${data.userName} (${data.userId})"),
          _InfoRow(icon: Icons.schedule_outlined, label: "Creado", value: data.createdAt),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final TramiteFull data;

  const _TimelineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _cafe.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timeline_rounded, color: _cafe),
              ),
              const SizedBox(width: 10),
              Text(
                "Historial de movimientos",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _negro,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (data.history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("Sin historial todavía."),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final h = data.history[i];
                final isLast = i == data.history.length - 1;
                return _TimelineItem(
                  from: h.fromStatus,
                  to: h.toStatus,
                  by: h.changedBy,
                  at: h.changedAt,
                  comment: h.comment,
                  isLast: isLast,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// =======================
/// Pequeños componentes UI
/// =======================

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black.withOpacity(0.65)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w800, color: _negro),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black.withOpacity(0.80)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  const _StatusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    // tono: vino para resaltar estado
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _vino.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _vino.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flag_rounded, size: 14, color: _vino),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _vino,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String from;
  final String to;
  final String by;
  final String at;
  final String comment;
  final bool isLast;

  const _TimelineItem({
    required this.from,
    required this.to,
    required this.by,
    required this.at,
    required this.comment,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicador + línea
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _cafe,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _cafe.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black.withOpacity(0.08),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Contenido
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _marfil,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Línea de estado
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$from  ➝  $to",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _negro,
                        ),
                      ),
                    ),
                    Text(
                      at,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text("Por: $by", style: TextStyle(color: Colors.black.withOpacity(0.75))),
                if (comment.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.black.withOpacity(0.55)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          comment,
                          style: TextStyle(color: Colors.black.withOpacity(0.85)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HintChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _HintChip({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: _cafe),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _vino.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.manage_search_rounded, size: 34, color: _vino),
          ),
          const SizedBox(height: 10),
          Text(
            "Consulta el estado de tu trámite",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: _negro,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            "Ingresa tu folio y te mostraremos el resumen y el historial de movimientos.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withOpacity(0.70)),
          ),
        ],
      ),
    );
  }
}
