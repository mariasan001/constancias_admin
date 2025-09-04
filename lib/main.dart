import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'data/flow_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Intl en español (México)
  Intl.defaultLocale = 'es_MX';
  await initializeDateFormatting('es_MX', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => FlowState(),
      child: const ConstanciasApp(),
    ),
  );
}
