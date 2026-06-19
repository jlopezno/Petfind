// Widget de calificacion con pulgares arriba y abajo.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proveedores/proveedor_calificacion.dart';

class WidgetCalificacion extends ConsumerWidget {
  const WidgetCalificacion({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calificaciones = ref.watch(proveedorCalificacion(usuarioId));
    return calificaciones.when(
      data: (items) {
        final positivas = items.where((c) => c.valor == 1).length;
        final negativas = items.where((c) => c.valor == -1).length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined), tooltip: 'Calificar positivo'),
            Text('$positivas'),
            const SizedBox(width: 8),
            IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.thumb_down_alt_outlined), tooltip: 'Calificar negativo'),
            Text('$negativas'),
          ],
        );
      },
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const Text('Sin rating'),
    );
  }
}
