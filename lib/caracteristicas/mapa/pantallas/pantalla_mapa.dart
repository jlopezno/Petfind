// Pantalla de mapa con publicaciones cercanas.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../publicaciones/modelos/modelo_publicacion.dart';
import '../proveedores/proveedor_mapa.dart';

class PantallaMapa extends ConsumerWidget {
  const PantallaMapa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(proveedorMapa);
    final controlador = ref.read(proveedorMapa.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Stack(
        children: [
          estado.when(
            data: (publicaciones) => GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(controlador.latitud, controlador.longitud), zoom: 13),
              myLocationButtonEnabled: true,
              markers: {
                for (final publicacion in publicaciones)
                  if (publicacion.latitud != null && publicacion.longitud != null)
                    Marker(
                      markerId: MarkerId(publicacion.id),
                      position: LatLng(publicacion.latitud!, publicacion.longitud!),
                      icon: BitmapDescriptor.defaultMarkerWithHue(_tono(publicacion.tipo)),
                      onTap: () => _mostrarResumen(context, publicacion),
                    ),
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('No se pudo cargar el mapa: $error')),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1000, label: Text('1 km')),
                ButtonSegment(value: 5000, label: Text('5 km')),
                ButtonSegment(value: 10000, label: Text('10 km')),
                ButtonSegment(value: 20000, label: Text('20 km')),
              ],
              selected: {controlador.radioMetros},
              onSelectionChanged: (valor) async {
                final radio = valor.first;
                ref.read(proveedorMapa.notifier).radioMetros = radio;
                ref.invalidate(proveedorMapa);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarResumen(BuildContext context, ModeloPublicacion publicacion) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(publicacion.titulo, style: Theme.of(context).textTheme.titleLarge),
            Text(publicacion.direccion ?? 'Ubicacion referencial'),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () => context.go('/publicacion/${publicacion.id}'), icon: const Icon(Icons.open_in_new), label: const Text('Ver detalle')),
          ],
        ),
      ),
    );
  }

  double _tono(TipoPublicacion tipo) => switch (tipo) {
        TipoPublicacion.perdido => BitmapDescriptor.hueRed,
        TipoPublicacion.rescatado => BitmapDescriptor.hueOrange,
        TipoPublicacion.adopcion => BitmapDescriptor.hueAzure,
      };
}
