// Tarjeta compacta para mascotas.
import 'package:flutter/material.dart';

import '../../caracteristicas/mascotas/modelos/modelo_mascota.dart';
import 'widget_avatar_mascota.dart';

class WidgetTarjetaMascota extends StatelessWidget {
  const WidgetTarjetaMascota({super.key, required this.mascota, this.onTap});

  final ModeloMascota mascota;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WidgetAvatarMascota(url: mascota.fotoPrincipal, radio: 38),
                const SizedBox(height: 8),
                Text(mascota.nombre, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                Text(mascota.especie.name, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
