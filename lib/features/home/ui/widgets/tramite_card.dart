import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TramiteCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Índice para alternar la flor: 0,1,2,0,1,2...
  final int variantIndex;
  /// Si quieres forzar un asset específico.
  final String? overrideAsset;

  const TramiteCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.variantIndex = 0,
    this.overrideAsset,
  });

  static const int kFlowerVariants = 3;

  @override
  State<TramiteCard> createState() => _TramiteCardState();
}

class _TramiteCardState extends State<TramiteCard> {
  bool _hover = false;

  String get _flowerAsset {
    if (widget.overrideAsset != null && widget.overrideAsset!.isNotEmpty) {
      return widget.overrideAsset!;
    }
    final mod = widget.variantIndex % TramiteCard.kFlowerVariants; // 0,1,2,0,1,2…
    return mod == 0 ? 'assets/brand/flower.png' : 'assets/brand/flower-${mod + 1}.png';
  }

  @override
  Widget build(BuildContext context) {
    // Colores de diseño
    const cardBg   = Color(0xFFF1F1F1);
    const circleBg = Color(0xFFFFFFFF);
    const iconCol  = Color(0xFF7D5C0F);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Breakpoints simples por ancho de la tarjeta
        final bool isMobile = w < 480;
        final bool isTablet = w >= 480 && w < 900;
        // final bool isDesktop = w >= 900; // por si lo necesitas

        // Tamaños responsivos
        final double padH        = isMobile ? 16 : (isTablet ? 18 : 20);
        final double padV        = isMobile ? 16 : (isTablet ? 18 : 22);
        final double circleSize  = isMobile ? 48 : (isTablet ? 56 : 64);
        final double iconSize    = isMobile ? 22 : (isTablet ? 24 : 28);
        final double titleSize   = isMobile ? 16 : (isTablet ? 17 : 18);
        final double subtitleSz  = isMobile ? 12.5 : (isTablet ? 13.0 : 14.0);
        final double ctaSize     = isMobile ? 13 : 14;
        final double ctaIconSize = isMobile ? 16 : 18;
        final double flowerSize  = isMobile ? 72 : (isTablet ? 84 : 92);
        final double flowerTop   = isMobile ? -20 : -28;
        final double flowerLeft  = isMobile ? -18 : -26;

        final card = Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF595959).withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(padH, padV, padH, padV - 2),
              // 👇 Sin minHeight: deja que la grilla (mainAxisExtent) mande
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Círculo + icono dentro
                  SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: const BoxDecoration(
                            color: circleBg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(widget.icon, size: iconSize, color: iconCol),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: titleSize,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                          fontSize: subtitleSz,
                          color: Colors.black.withOpacity(0.60),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Iniciar Proceso',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: ctaSize,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.north_east, size: ctaIconSize),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        // Hover solo en web/desktop para evitar “brincos” en móvil
        final child = (kIsWeb || Theme.of(context).platform == TargetPlatform.macOS || Theme.of(context).platform == TargetPlatform.windows || Theme.of(context).platform == TargetPlatform.linux)
            ? MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: AnimatedScale(
                  scale: _hover ? 1.01 : 1.0,
                  duration: const Duration(milliseconds: 140),
                  child: card,
                ),
              )
            : card;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Flor detrás, rotada -55°, sobresaliendo un poco (también responsive)
              Positioned(
                top: flowerTop,
                left: flowerLeft,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: -55 * math.pi / 180,
                    child: Opacity(
                      opacity: 0.95,
                      child: Image.asset(
                        _flowerAsset,
                        width: flowerSize,
                        height: flowerSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}
