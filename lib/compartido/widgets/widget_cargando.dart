// Muestra un indicador de carga centrado.
import 'package:flutter/material.dart';

class WidgetCargando extends StatelessWidget {
  const WidgetCargando({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
