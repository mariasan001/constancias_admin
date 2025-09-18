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

    return Container(
      // Fondo a pantalla completa
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F7FB), Color(0xFFFFFFFF)],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/brand/fondo.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          colorFilter: ColorFilter.mode(
            Color.fromARGB(132, 255, 255, 255),
            BlendMode.colorDodge,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_headerHeight(context)),
            child: SizedBox(
              height: _headerHeight(context),
              child: const HeaderStrip(
                title: 'Trámite de constancias',
                logoAsset: 'assets/brand/escudo.png',
              ),
            ),
          ),
        ),

        body: LayoutBuilder(
          builder: (context, c) {
            // ====== Breakpoints & tokens responsivos ======
            final w = c.maxWidth;
            final double scale =
                MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.25) as double;
            final isMobile = w < 700;
            final isDesktop = w >= 1100;
            final isXL = w >= 1400;

            // Columnas de la grilla
            final cols = isXL ? 4 : (isDesktop ? 3 : (isMobile ? 1 : 2));

            // Alto de cada tarjeta en la grilla
            final mainExtent =
                isXL ? 240.0 : (isDesktop ? 240.0 : (isMobile ? 270.0 : 250.0));

            // Gaps y paddings
            final maxContentW = isXL ? 1400.0 : 1200.0;
            final gridGap = isMobile ? 12.0 : 16.0;
            final outerHPad = isMobile ? 12.0 : 16.0;
            final vSpaceXS = (isMobile ? 6.0 : 8.0) * scale;
            final vSpaceMD = (isMobile ? 24.0 : 28.0) * scale;
            final vSpaceLG = (isMobile ? 32.0 : 40.0) * scale;

            // Tipografías
            final titleFS =
                (isMobile ? 20.0 : (isDesktop ? 26.0 : 24.0)) * scale;
            final leadFS =
                (isMobile ? 13.0 : (isDesktop ? 16.0 : 14.0)) * scale;
            final ctaFS = (isMobile ? 14.0 : 15.0) * scale;
            final ctaIcon = isMobile ? 18.0 : 20.0;

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
                        SizedBox(height: vSpaceXS),

                        // Título y texto acompañante (centrados)
                        Text(
                          '¿QUÉ TRÁMITE DESEAS HACER HOY?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: titleFS,
                              ),
                        ),
                        SizedBox(height: vSpaceXS),
                        Text(
                          'Consulta y gestiona tus constancias de forma rápida, segura y sin complicaciones.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.black.withOpacity(0.70),
                                fontSize: leadFS,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                        ),

                        SizedBox(height: vSpaceMD),

                        // Botón café (centrado)
                        ElevatedButton.icon(
                          onPressed: () => context.go('/seguimiento'),
                          icon: Icon(Icons.track_changes, size: ctaIcon),
                          label: Text(
                            'Consultar seguimiento por folio',
                            style: TextStyle(fontSize: ctaFS),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7D5C0F),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 18 : 22,
                              vertical: isMobile ? 12 : 14,
                            ),
                            shape: const StadiumBorder(),
                            elevation: 1,
                          ),
                        ),

                        SizedBox(height: vSpaceLG),

                        // Grilla responsive
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tramites.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: gridGap,
                            mainAxisSpacing: gridGap,
                            mainAxisExtent: mainExtent,
                          ),
                          itemBuilder: (_, i) {
                            final t = tramites[i];
                            return TramiteCard(
                              variantIndex: i, // alterna flower 0,1,2…
                              icon: t.icon,                 // del models.dart
                              title: t.titulo,              // del models.dart
                              subtitle: t.descripcion,      // del models.dart
                              onTap: () {
                                fs.setTramite(t);           // guarda selección
                                context.go('/buscar');      // sigue el flujo
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
          // logoAsset: 'assets/brand/escudo.png',
        ),
      ),
    );
  }

  // altura dinámica del header para que no desborde en móvil/escala grande
  double _headerHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final double scale =
        MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.25) as double;
    final compact = w < 600;
    final base = compact ? 76.0 : 66.0;
    return base * scale;
  }
}
