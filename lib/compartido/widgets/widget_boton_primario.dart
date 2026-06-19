// Boton principal reutilizable de PetFindr.
import 'package:flutter/material.dart';

class WidgetBotonPrimario extends StatelessWidget {
  const WidgetBotonPrimario({super.key, required this.texto, required this.onPressed, this.icono});

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final hijo = Text(texto, overflow: TextOverflow.ellipsis);
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icono ?? Icons.check),
      label: hijo,
    );
  }
}
