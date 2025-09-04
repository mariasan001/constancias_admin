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
    final year     = DateFormat('y', 'es_MX').format(now);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final compact = w < 600;
        final titleSize = w >= 1100 ? 18.0 : (w >= 700 ? 17.0 : 12.5);
        final dateSize  = w >= 1100 ? 13.0 : (w >= 700 ? 12.3 : 11.6);
        final logoH     = w >= 1100 ? 34.0 : (w >= 700 ? 30.0 : 24.0);

        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: Colors.black87,
                    height: 1.05,
                  ),
            ),
            const SizedBox(height: 2),
            RichText(
              maxLines: 1,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: dateSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.85),
                      height: 1.0,
                    ),
                children: [
                  TextSpan(text: dayMonth),
                  TextSpan(text: year, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        );

        final right = Image.asset(logoAsset, height: logoH, fit: BoxFit.contain);

        return Container(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 6 : 8, // más compacto
              ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black.withOpacity(0.12), width: 1),
            ),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    left,
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: right),
                  ],
                )
              : Row(
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
