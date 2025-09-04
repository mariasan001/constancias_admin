import 'package:flutter/material.dart';

class FooterStrip extends StatelessWidget {
  /// Texto de la entidad responsable.
  final String orgText; // Ej: "la Dirección General de Desarrollo Tecnológico"
  /// (Opcional) Logo/escudo a la derecha (desktop) o arriba (móvil).
  final String? logoAsset;
  /// (Opcional) Padding custom.
  final EdgeInsets? padding;

  const FooterStrip({
    super.key,
    required this.orgText,
    this.logoAsset,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(206, 235, 235, 235),
      child: SafeArea( // respeta notch/bottom en móviles
        top: false,
        child: Container(
    
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final compact = w < 600; // móvil

              final text = Text(
                'Desarrollado por $orgText • © ${DateTime.now().year}',
                textAlign: compact ? TextAlign.center : TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
              );

              final logo = (logoAsset == null)
                  ? null
                  : Image.asset(logoAsset!, height: 20, fit: BoxFit.contain);

              if (compact) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (logo != null) Padding(padding: const EdgeInsets.only(bottom: 6), child: logo),
                    text,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: text),
                  if (logo != null) logo,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
