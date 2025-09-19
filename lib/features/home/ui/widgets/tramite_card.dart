import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TramiteCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const TramiteCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<TramiteCard> createState() => _TramiteCardState();
}

class _TramiteCardState extends State<TramiteCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    // 🎨 Paleta
    const cardBg = Colors.white; // fondo blanco
    const iconBg = Color(0xFF8B5E3C); // café oscuro
    const titleCol = Color(0xFF2C1B12);
    const subtitleCol = Color(0xFF4B3A2E);
    const accentCol = Color(0xFF7D2131); // vino

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bool isMobile = w < 480;
        final bool isTablet = w >= 480 && w < 900;

        final double padH = isMobile ? 16 : (isTablet ? 20 : 24);
        final double padV = isMobile ? 16 : (isTablet ? 20 : 26);
        final double circleSize = isMobile ? 64 : (isTablet ? 72 : 80);
        final double iconSize = isMobile ? 28 : 34;
        final double titleSize = isMobile ? 18 : (isTablet ? 20 : 22);
        final double subtitleSize = isMobile ? 14 : 15;

        final card = Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contenido
                  Padding(
                    padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
                    child: Column(
                      children: [
                        // 🎯 Icono centrado
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            color: iconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.icon,
                              size: iconSize, color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // 📝 Título centrado
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: titleSize,
                            color: titleCol,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 📝 Subtítulo centrado
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: subtitleSize,
                            color: subtitleCol,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón integrado abajo a la derecha
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Material(
                        color: accentCol,
                        child: InkWell(
                          onTap: widget.onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "Iniciar Proceso",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Hover con efecto suave (solo desktop/web)
        final child = (kIsWeb ||
                Theme.of(context).platform == TargetPlatform.macOS ||
                Theme.of(context).platform == TargetPlatform.windows ||
                Theme.of(context).platform == TargetPlatform.linux)
            ? MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: AnimatedScale(
                  scale: _hover ? 1.02 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: card,
                ),
              )
            : card;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: child,
        );
      },
    );
  }
}
