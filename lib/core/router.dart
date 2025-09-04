import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/ui/home_page.dart';
import '../features/lookup/ui/buscar_servidor_page.dart';
import '../features/adjuntos/ui/adjuntar_page.dart';
import '../features/contacto/ui/contacto_page.dart';
import '../features/resumen/ui/resumen_page.dart';
import '../features/seguimiento/ui/seguimiento_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage(), routes: [
      GoRoute(path: 'buscar', builder: (_, __) => const BuscarServidorPage()),
      GoRoute(path: 'adjuntos', builder: (_, __) => const AdjuntarPage()),
      GoRoute(path: 'contacto', builder: (_, __) => const ContactoPage()),
      GoRoute(path: 'resumen', builder: (_, __) => const ResumenPage()),
      GoRoute(path: 'seguimiento', builder: (_, __) => const SeguimientoPage()),
    ]),
  ],
);
