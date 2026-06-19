// Muestra informacion completa de una mascota.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/utilidades/ayudante_fecha.dart';
import '../proveedores/proveedor_mascota.dart';

class PantallaDetalleMascota extends ConsumerWidget {
  const PantallaDetalleMascota({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascota = mascotasMock.where((m) => m.id == id).firstOrNull;
    final vacunas = ref.watch(proveedorVacunasMascota(id));
    if (mascota == null) return const Scaffold(body: Center(child: Text('Mascota no encontrada')));
    return Scaffold(
      appBar: AppBar(title: Text(mascota.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (mascota.fotoPrincipal != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: mascota.fotoPrincipal!, height: 260, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          Text(mascota.nombre, style: Theme.of(context).textTheme.headlineSmall),
          Text('${mascota.especie.name} - ${mascota.raza ?? 'sin raza'} - ${mascota.color ?? 'sin color'}'),
          Text(mascota.descripcion ?? ''),
          const SizedBox(height: 16),
          Text('Vacunas', style: Theme.of(context).textTheme.titleLarge),
          vacunas.when(
            data: (items) => Column(
              children: [
                for (final vacuna in items)
                  ListTile(
                    leading: const Icon(Icons.vaccines),
                    title: Text(vacuna.nombre),
                    subtitle: Text('${AyudanteFecha.estadoVacuna(vacuna.proximaEn)} - proxima: ${vacuna.proximaEn == null ? 'sin fecha' : AyudanteFecha.fechaCorta(vacuna.proximaEn!)}'),
                  ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Sin vacunas'),
          ),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Agregar vacuna')),
          const SizedBox(height: 12),
          Text('Publicaciones activas', style: Theme.of(context).textTheme.titleLarge),
          for (final post in publicacionesMock.where((p) => p.mascotaId == id)) ListTile(leading: const Icon(Icons.article_outlined), title: Text(post.titulo)),
        ],
      ),
    );
  }
}
