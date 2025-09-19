import 'package:constancias_admin/features/home/ui/widgets/footer_strip.dart';
import 'package:constancias_admin/features/home/ui/widgets/header_strip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';
import '../../../data/models.dart';
import 'widgets/tramite_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FlowState>();
    final tramites = Tramite.values;

    // 🎨 Nueva base visual
    const solidBg = Color(0xFFFAF7F2); // marfil cálido
    const ink = Color(0xFF1F1D1B);      // casi negro
    const muted = Color(0xFF5E5A55);    // texto secundario
    const brand = Color(0xFF7D5C0F);    // café acento

    return Container(
      constraints: const BoxConstraints.expand(),
      color: solidBg, // ✅ Fondo sólido
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: solidBg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 0,
          bottom: PreferredSize(
            // 👇 Restamos 1px para evitar overflow
            preferredSize: Size.fromHeight(_headerHeight(context) - 1),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: _headerHeight(context) - 1,
                child: const HeaderStrip(
                  title: 'Trámite de constancias',
                  logoAsset: 'assets/brand/escudo.png',
                ),
              ),
            ),
          ),
        ),

        body: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final double scale =
                MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.25) as double;
            final isMobile = w < 700;
            final isDesktop = w >= 1100;
            final isXL = w >= 1400;

            final cols = isXL ? 4 : (isDesktop ? 3 : (isMobile ? 1 : 2));
            final mainExtent = isXL
                ? 240.0
                : (isDesktop ? 240.0 : (isMobile ? 270.0 : 250.0));

            final maxContentW = isXL ? 1400.0 : 1200.0;
            final gridGap = isMobile ? 12.0 : 16.0;
            final outerHPad = isMobile ? 12.0 : 20.0;
            final vSpaceXS = (isMobile ? 8.0 : 10.0) * scale;
            final vSpaceSM = (isMobile ? 14.0 : 18.0) * scale;
            final vSpaceMD = (isMobile ? 24.0 : 28.0) * scale;
            final vSpaceLG = (isMobile ? 32.0 : 42.0) * scale;

            final titleFS = (isMobile ? 26.0 : (isDesktop ? 32.0 : 28.0)) * scale;
            final leadFS = (isMobile ? 15.0 : (isDesktop ? 18.0 : 16.0)) * scale;
            final ctaFS = (isMobile ? 15.0 : 17.0) * scale;
            final ctaIcon = isMobile ? 20.0 : 22.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: outerHPad),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentW),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: vSpaceSM),

                        // ✅ Eyebrow chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.black.withOpacity(0.06)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_outlined, size: 16, color: brand),
                              const SizedBox(width: 6),
                              Text(
                                'Rápido • Seguro • Oficial',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: vSpaceXS),

                        // ✅ Título llamativo
                        Text(
                          '¿QUÉ TRÁMITE DESEAS HACER HOY?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: titleFS,
                                letterSpacing: 1.2,
                                color: ink,
                                height: 1.1,
                              ),
                        ),

                        SizedBox(height: vSpaceXS),

                        // ✅ Lead más grande
                        Text(
                          'Consulta y gestiona tus constancias de forma rápida, segura y sin complicaciones.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: muted,
                                fontSize: leadFS,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                        ),

                        SizedBox(height: vSpaceMD),

                        // ✅ CTA más atractivo
                        ElevatedButton.icon(
                          onPressed: () => context.go('/seguimiento'),
                          icon: Icon(Icons.track_changes, size: ctaIcon),
                          label: Text(
                            'Consultar seguimiento por folio',
                            style: TextStyle(
                              fontSize: ctaFS,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: brand.withOpacity(0.4),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 22 : 28,
                              vertical: isMobile ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        SizedBox(height: vSpaceLG),

                        // ✅ Grilla responsive
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tramites.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: gridGap,
                            mainAxisSpacing: gridGap,
                            mainAxisExtent: mainExtent,
                          ),
                          itemBuilder: (_, i) {
                            final t = tramites[i];
                            return TramiteCard(
                              icon: t.icon,
                              title: t.titulo,
                              subtitle: t.descripcion,
                              onTap: () {
                                fs.setTramite(t);
                                context.go('/buscar');
                              },
                            );
                          },
                        ),

                        SizedBox(height: vSpaceLG),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const FooterStrip(
          orgText: 'Dirección de Desarrollo Tecnológico',
        ),
      ),
    );
  }

  double _headerHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final double scale =
        MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.25) as double;
    final compact = w < 600;
    final base = compact ? 76.0 : 66.0;
    return base * scale;
  }
}
