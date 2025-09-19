import 'package:flutter/material.dart';

/// Colores institucionales (ajústalos si ya los tienes centralizados)
const _negro = Color(0xFF1A1A1A);
const _vino  = Color(0xFF9F2141);
const _cafe  = Color(0xFF7D5C0F);
const _marfil= Color(0xFFFAF7F2);

class DocumentoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value; // uri/path si ya está cargado
  final VoidCallback onScan;
  final VoidCallback? onRemove;

  const DocumentoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onScan,
    this.onRemove,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cargado = value != null && value!.isNotEmpty;

    // Colores por estado (sin usar verde: solo institucionales)
    final estadoColor = cargado ? _vino : _negro.withOpacity(0.28);
    final chipBg      = cargado ? _vino.withOpacity(0.10) : Colors.black.withOpacity(0.05);
    final chipFg      = cargado ? _vino : _negro.withOpacity(0.70);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onScan, // tap rápido = acción principal
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Franja de estado a la izquierda (vino si cargado)
              Positioned.fill(
                left: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: estadoColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícono con aura
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (cargado ? _vino : _cafe).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: cargado ? _vino : _cafe,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Texto (título + path/estado)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título + chip
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: _negro,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Chip de estado
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: chipBg,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: chipFg.withOpacity(0.25)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cargado ? Icons.check_circle : Icons.hourglass_bottom_rounded,
                                      size: 14,
                                      color: chipFg,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cargado ? 'Listo' : 'Pendiente',
                                      style: TextStyle(
                                        color: chipFg,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Ruta/uri
                          Text(
                            cargado ? value! : 'Aún no adjuntado (PDF)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: _negro.withOpacity(0.65),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Acciones
                    Wrap(
                      spacing: 6,
                      children: [
                        if (cargado && onRemove != null)
                          _GhostIconButton(
                            tooltip: 'Eliminar',
                            icon: Icons.delete_outline,
                            fg: _negro.withOpacity(0.85),
                            onPressed: onRemove!,
                          ),
                        _FilledActionButton(
                          onPressed: onScan,
                          icon: cargado ? Icons.edit : Icons.document_scanner,
                          label: cargado ? 'Reemplazar' : 'Escanear',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón secundario “fantasma” (borde suave, icono oscuro)
class _GhostIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color fg;
  final VoidCallback onPressed;

  const _GhostIconButton({
    required this.tooltip,
    required this.icon,
    required this.fg,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black.withOpacity(0.10)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }
}

/// Botón principal del item (café lleno, tipografía fuerte)
class _FilledActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _FilledActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _cafe,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
