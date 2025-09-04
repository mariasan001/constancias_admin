import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}
