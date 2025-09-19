import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderStrip extends StatelessWidget {
  final String title;
  final String logoAsset;
  final DateTime? date;
  final EdgeInsets? padding;

  const HeaderStrip({
    super.key,
    required this.title,
    required this.logoAsset,
    this.date,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final now = date ?? DateTime.now();
    final dayMonth = DateFormat("dd 'de' MMMM 'del' ", 'es_MX').format(now);
    final year = DateFormat('y', 'es_MX').format(now);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        // Responsividad
        final titleSize = w >= 1100 ? 20.0 : (w >= 700 ? 18.0 : 14.0);
        final dateSize = w >= 1100 ? 14.0 : (w >= 700 ? 13.0 : 11.8);
        final logoH = w >= 1100 ? 38.0 : (w >= 700 ? 32.0 : 26.0);

        // Columna izquierda (título + fecha)
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8, // tracking
                    color: Colors.black87,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 3),
            RichText(
              maxLines: 1,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: dateSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.65),
                      height: 1.2,
                    ),
                children: [
                  TextSpan(text: dayMonth),
                  TextSpan(
                    text: year,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7D5C0F), // acento café
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        // Logo a la derecha
        final right = Image.asset(
          logoAsset,
          height: logoH,
          fit: BoxFit.contain,
        );

        return Container(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: w < 600 ? 12 : 20,
                vertical: w < 600 ? 6 : 10,
              ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFAF7F2), Color(0xFFFFFFFF)],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: left),
              right,
            ],
          ),
        );
      },
    );
  }
}
