import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../home/ui/widgets/header_strip.dart';
import '../../home/ui/widgets/footer_strip.dart';
import '../../../data/flow_state.dart';

class SeguimientoPage extends StatefulWidget {
  const SeguimientoPage({super.key});

  @override
  State<SeguimientoPage> createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  final _folioCtrl = TextEditingController();
  final _folioFocus = FocusNode();

  String? _estado;
  String? _error;
  bool _loading = false;

  final _reFolio = RegExp(r'^[A-Z]{3}-\d{4}-\d{5,6}$'); // Ej. CON-2025-000123

  Future<void> _consultar() async {
    final folio = _folioCtrl.text.trim().toUpperCase();

    setState(() {
      _error = null;
      _estado = null;
    });

    if (folio.isEmpty || !_reFolio.hasMatch(folio)) {
      setState(() => _error = 'Formato inválido. Ejemplo: CON-2025-000123');
      return;
    }

    setState(() => _loading = true);

    // DEMO: simula una búsqueda real
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _loading = false;
      _estado = 'En revisión (estimado: 3 días hábiles)';
    });
  }

  @override
  void dispose() {
    _folioCtrl.dispose();
    _folioFocus.dispose();
    super.dispose();
  }

  double _headerHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final scale = MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.25);
    final compact = w < 600;
    final base = compact ? 76.0 : 66.0;
    return base * scale;
  }

  // Mapea el string de estado a un paso: 0 Recibido, 1 En revisión, 2 Finalizado
  int _stageFromEstado(String s) {
    final lc = s.toLowerCase();
    if (lc.contains('final') ||
        lc.contains('listo') ||
        lc.contains('listo para entrega'))
      return 2;
    if (lc.contains('revisión') || lc.contains('revision')) return 1;
    if (lc.contains('recib') || lc.contains('ingres')) return 0;
    // por defecto: en revisión si no coincide
    return 1;
  }

  String _labelFromEstado(String s) {
    final m = RegExp(r'^[^(\n]+').firstMatch(s);
    return (m?.group(0) ?? s).trim();
  }

  String? _etaFromEstado(String s) {
    final m = RegExp(r'\((.*?)\)').firstMatch(s);
    return m != null ? m.group(1) : null; // ej: "estimado: 3 días hábiles"
  }

  Color get _brandCafe => const Color(0xFF7D5C0F);
  Color get _doneGreen => const Color(0xFF2E7D32);
  Color get _neutralGray => Colors.black.withOpacity(0.12);

  // Color del paso (activo / completado / pendiente)
  Color _colorForStep(int step, int current) {
    if (step < current) return _brandCafe; // completado
    if (step == current) return _brandCafe; // activo
    return Colors.black.withOpacity(0.25); // pendiente
  }

  @override
  Widget build(BuildContext context) {
    // Si necesitas el estado global:
    context.watch<FlowState>();

    return Container(
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
                title: 'Seguimiento de constancias',
                logoAsset: 'assets/brand/escudo.png',
              ),
            ),
          ),
        ),

        body: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final scale = MediaQuery.textScaleFactorOf(
              context,
            ).clamp(1.0, 1.25);

            final isMobile = w < 700;
            final isXL = w >= 1400;

            // Tokens responsivos
            final maxContentW = isXL ? 1200.0 : 1000.0;
            final outerHPad = isMobile ? 12.0 : 16.0;
            final vSpaceXS = (isMobile ? 6.0 : 8.0) * scale;
            final vSpaceSM = (isMobile ? 14.0 : 16.0) * scale;
            final vSpaceMD = (isMobile ? 22.0 : 26.0) * scale;
            final vSpaceLG = (isMobile ? 28.0 : 36.0) * scale;

            final titleFS = (isMobile ? 20.0 : 24.0) * scale;
            final leadFS = (isMobile ? 13.0 : 15.0) * scale;

            // Buscador: layout horizontal en desktop, vertical en móvil
            final inputBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
            );

            final searchField = Expanded(
              child: TextField(
                controller: _folioCtrl,
                focusNode: _folioFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _consultar(),
                decoration: InputDecoration(
                  labelText: 'Folio',
                  hintText: 'Ej. CON-2025-000123',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: const BorderSide(
                      color: Color(0xFF7D5C0F),
                      width: 1.2,
                    ),
                  ),
                  errorText: _error,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            );

            final searchButton = SizedBox(
              height: isMobile ? 48 : 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _consultar,
                icon: const Icon(Icons.search),
                label: Text(_loading ? 'Consultando…' : 'Consultar estado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D5C0F),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 12 : 14,
                  ),
                  shape: const StadiumBorder(),
                  elevation: 1,
                ),
              ),
            );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: outerHPad),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: vSpaceXS),

                        // Título + lead
                        Text(
                          'Consulta el estado de tu trámite',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: titleFS,
                              ),
                        ),
                        SizedBox(height: vSpaceXS),
                        Text(
                          'Ingresa el folio que recibiste al iniciar tu trámite para ver su avance y tiempos estimados.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.black.withOpacity(0.70),
                                fontSize: leadFS,
                                height: 1.35,
                              ),
                        ),

                        SizedBox(height: vSpaceMD),

                        // Card del buscador
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isMobile
                              ? Column(
                                  children: [
                                    searchField,
                                    SizedBox(height: vSpaceSM),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: searchButton,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    searchField,
                                    const SizedBox(width: 12),
                                    searchButton,
                                  ],
                                ),
                        ),

                        SizedBox(height: vSpaceLG),

                        // Resultado (animado)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _estado == null
                              ? const SizedBox.shrink()
                              : LayoutBuilder(
                                  key: ValueKey(_estado),
                                  builder: (context, c) {
                                    final w = c.maxWidth;
                                    final scale = MediaQuery.textScaleFactorOf(
                                      context,
                                    ).clamp(1.0, 1.25);
                                    final isMobile = w < 700;

                                    final stage = _stageFromEstado(_estado!);
                                    final label = _labelFromEstado(_estado!);
                                    final eta = _etaFromEstado(_estado!);

                                    final titleFS =
                                        (isMobile ? 16.0 : 18.0) * scale;
                                    final bodyFS =
                                        (isMobile ? 13.0 : 14.0) * scale;
                                    final chipFS =
                                        (isMobile ? 11.0 : 12.0) * scale;
                                    final dot = isMobile ? 12.0 : 14.0;
                                    final lineH = 2.0;

                                    Widget buildDot(int i) => Container(
                                      width: dot,
                                      height: dot,
                                      decoration: BoxDecoration(
                                        color: _colorForStep(i, stage),
                                        shape: BoxShape.circle,
                                      ),
                                    );

                                    Widget buildLine(int i) => Expanded(
                                      child: Container(
                                        height: lineH,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 6 : 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _colorForStep(i, stage)
                                              .withOpacity(
                                                i <= stage - 1 ? 1 : 0.35,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    );

                                    // chip de estado
                                    final chip = Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _brandCafe.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: _brandCafe.withOpacity(0.25),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            stage == 2
                                                ? Icons.check_circle
                                                : Icons.timelapse,
                                            size: isMobile ? 16 : 18,
                                            color: _brandCafe,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: chipFS,
                                              fontWeight: FontWeight.w700,
                                              color: _brandCafe,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    // acciones
                                    final actions = Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            final folio = (_folioCtrl.text)
                                                .trim()
                                                .toUpperCase();
                                            Clipboard.setData(
                                              ClipboardData(text: folio),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Folio copiado'),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.copy),
                                          label: const Text('Copiar folio'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            // aquí podrías abrir un modal para suscribirse a notificaciones
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Próximamente: notificaciones',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.notifications_active_outlined,
                                          ),
                                          label: const Text(
                                            'Recibir notificaciones',
                                          ),
                                        ),
                                      ],
                                    );

                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          isMobile ? 14 : 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Encabezado: icono + textos + chip
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: isMobile ? 36 : 40,
                                                  height: isMobile ? 36 : 40,
                                                  decoration: BoxDecoration(
                                                    color: _brandCafe
                                                        .withOpacity(0.10),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    stage == 2
                                                        ? Icons
                                                              .verified_outlined
                                                        : Icons.info_outline,
                                                    color: _brandCafe,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Estado de tu trámite',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      titleFS,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          chip,
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      if (eta != null)
                                                        Text(
                                                          eta,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontSize:
                                                                    bodyFS,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.70,
                                                                    ),
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (!isMobile) actions,
                                              ],
                                            ),

                                            if (isMobile) ...[
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: actions,
                                              ),
                                            ],

                                            const SizedBox(height: 14),

                                            // Timeline bonito (3 pasos)
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    buildDot(0),
                                                    buildLine(0),
                                                    buildDot(1),
                                                    buildLine(1),
                                                    buildDot(2),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Recibido',
                                                      style: TextStyle(
                                                        fontSize: bodyFS,
                                                        color: _colorForStep(
                                                          0,
                                                          stage,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'En revisión',
                                                      style: TextStyle(
                                                        fontSize: bodyFS,
                                                        color: _colorForStep(
                                                          1,
                                                          stage,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Finalizado',
                                                      style: TextStyle(
                                                        fontSize: bodyFS,
                                                        color: _colorForStep(
                                                          2,
                                                          stage,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 14),

                                            // Barra de progreso animada
                                            TweenAnimationBuilder<double>(
                                              duration: const Duration(
                                                milliseconds: 320,
                                              ),
                                              curve: Curves.easeOut,
                                              tween: Tween(
                                                begin: 0,
                                                end: (stage + 1) / 3,
                                              ),
                                              builder: (context, value, _) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child:
                                                      LinearProgressIndicator(
                                                        value: value,
                                                        minHeight: isMobile
                                                            ? 6
                                                            : 8,
                                                        color: _brandCafe,
                                                        backgroundColor:
                                                            _neutralGray
                                                                .withOpacity(
                                                                  0.25,
                                                                ),
                                                      ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
}
