// Define el tema visual Material 3 de PetFindr.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../nucleo/constantes/colores.dart';

final temaPetFindr = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: colorPrimario,
    primary: colorPrimario,
    secondary: colorSecundario,
    error: colorError,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: colorFondo,
  textTheme: GoogleFonts.poppinsTextTheme(),
  primaryTextTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
);
