import 'package:constancias_admin/data/model_buscar_user/models.dart'
    show UserModel;
import 'package:constancias_admin/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/flow_state.dart';

/// =====================
///  Servicio de usuario
/// =====================
class UserService {
  static Future<UserModel> getUserById(String userId) async {
    final resp = await ApiService.dio.get('/api/users/$userId');
    return UserModel.fromJson(resp.data);
  }

  static Future<UserModel> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final resp = await ApiService.dio.put('/api/users/$userId', data: data);
    return UserModel.fromJson(resp.data);
  }
}

/// ==========================
///  Página: Buscar Servidor
/// ==========================
class BuscarServidorPage extends StatefulWidget {
  const BuscarServidorPage({super.key});

  @override
  State<BuscarServidorPage> createState() => _BuscarServidorPageState();
}

class _BuscarServidorPageState extends State<BuscarServidorPage> {
  final _controller = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _focus = FocusNode();

  bool _loading = false;
  String? _error;
  UserModel? _usuario;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _correoCtrl.dispose();
    _telCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final numero = _controller.text.trim();

    // Validación básica (sin cambiar tu regla)
    final isValid = RegExp(r'^\d{5,12}$').hasMatch(numero);
    if (!isValid) {
      setState(() {
        _error = "Ingresa de 5 a 12 dígitos (ej. 210000884)";
        _usuario = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _usuario = null;
    });

    try {
      final user = await UserService.getUserById(numero);
      if (!mounted) return;

      setState(() {
        _usuario = user;
        _correoCtrl.text = user.email;
        _telCtrl.text = user.phone ?? "";
        _loading = false;
      });

      context.read<FlowState>().setUsuario(user);
    } on DioException {
      if (!mounted) return;
      setState(() {
        _error = "No encontrado. Verifica el número o consulta con RH.";
        _loading = false;
        _usuario = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Ocurrió un error inesperado";
        _loading = false;
        _usuario = null;
      });
    }
  }

  Future<void> _guardar() async {
    if (_usuario == null) return;

    setState(() => _loading = true);
    try {
      final actualizado = await UserService.updateUser(_usuario!.userId, {
        "name": _usuario!.name,
        "email": _correoCtrl.text.trim(),
        "phone": _telCtrl.text.trim(),
      });
      if (!mounted) return;

      context.read<FlowState>().setUsuario(actualizado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Información actualizada")),
      );
      context.push('/adjuntos');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error al actualizar: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Tokens visuales (match con tu línea)
    const bg = Color(0xFFFAF7F2); // marfil cálido
    const brand = Color(0xFF7D5C0F); // café acento
    const ink = Color(0xFF1F1D1B); // casi negro
    final muted = Colors.black.withOpacity(0.65);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Buscar servidor público',
          style: TextStyle(fontWeight: FontWeight.w800),
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
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =============================
                //  Spotlight Search "WOW"
                // =============================
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 720 : 840),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.all(isMobile ? 14 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _focused
                            ? brand.withOpacity(0.40)
                            : Colors.black.withOpacity(0.06),
                        width: _focused ? 1.6 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            _focused ? 0.08 : 0.04,
                          ),
                          blurRadius: _focused ? 22 : 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icono grande de identidad del campo
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: brand.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: brand,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Campo de texto flexible
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _loading ? null : _buscar(),
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: ink,
                              letterSpacing: 0.2,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Número de servidor público (5–12 dígitos)',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.35),
                                fontSize: isMobile ? 15 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Suffix: limpiar o buscar / loading
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: _loading
                              ? const SizedBox(
                                  key: ValueKey('ld'),
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : Row(
                                  key: const ValueKey('icons'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_controller.text.isNotEmpty)
                                      IconButton(
                                        tooltip: 'Limpiar',
                                        onPressed: () {
                                          setState(() {
                                            _controller.clear();
                                            _usuario = null;
                                            _error = null;
                                          });
                                        },
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                    const SizedBox(width: 4),
                                    FilledButton.icon(
                                      onPressed: _loading ? null : _buscar,
                                      icon: const Icon(Icons.search),
                                      label: Text(
                                        isMobile ? 'Buscar' : 'Buscar usuario',
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: brand,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 14 : 18,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Chips de ayuda/sugerencia (solo UI)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 720 : 840),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HintChip(
                          label: 'Ej. 210000884',
                          onTap: () => _controller.text = '210000884',
                        ),
                        _HintChip(
                          label: 'Ej. 210048331',
                          onTap: () => _controller.text = '210048331',
                        ),
                        _HintChip(
                          label: 'Pegar',
                          icon: Icons.content_paste_rounded,
                          onTap: () async {
                            // UI helper simple (sin lógica extra)
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null)
                              setState(
                                () => _controller.text = data!.text!.trim(),
                              );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (_loading)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? 720 : 840),
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),

                if (_error != null && !_loading) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? 720 : 840),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // =============================
                //  Resultado / Edición de datos
                // =============================
                if (_usuario != null && !_loading)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? 720 : 840),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado usuario
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: brand.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: brand,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _usuario!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                            ),
                                      ),
                                      Text(
                                        "Rol: ${_usuario!.roles.isNotEmpty ? _usuario!.roles.first.description : 'Sin rol'}",
                                        style: TextStyle(color: muted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Campos editables
                            _LabeledField(
                              label: "Correo electrónico",
                              child: TextField(
                                controller: _correoCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  hintText: "tu@correo.mx",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: "Teléfono",
                              child: TextField(
                                controller: _telCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  hintText: "55 0000 0000",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Acciones
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _loading ? null : _guardar,
                                    icon: const Icon(Icons.save_outlined),
                                    label: const Text("Guardar y continuar"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: brand,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.push('/adjuntos'),
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 20,
                                      color: ink,
                                    ),
                                    label: const Text(
                                      "Es correcto, continuar",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                        color: Colors
                                            .black87, // texto negro elegante
                                      ),
                                    ),
                                    style:
                                        OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: Colors.black87,
                                            width: 1.4,
                                          ),
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                        ).copyWith(
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.black.withOpacity(0.06),
                                          ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =====================
///  Widgets utilitarios
/// =====================
class _HintChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _HintChip({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final brand = const Color(0xFF7D5C0F);
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
              Icon(icon, size: 16, color: brand),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final muted = Colors.black.withOpacity(0.70);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: muted,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
