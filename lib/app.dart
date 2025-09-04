import 'package:flutter/material.dart';
import 'core/router.dart';
import 'core/theme.dart';

class ConstanciasApp extends StatelessWidget {
  const ConstanciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Constancias',
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
