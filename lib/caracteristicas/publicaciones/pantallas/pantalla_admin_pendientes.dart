// Cola de revision de publicaciones para administradores.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/constantes/colores.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../modelos/modelo_publicacion.dart';
import '../proveedores/proveedor_publicacion.dart';

class PantallaAdminPendientes extends ConsumerWidget {
  const PantallaAdminPendientes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(proveedorAutenticacion).valueOrNull;
    final publicaciones = ref.watch(proveedorPublicacionesRevisionAdmin);

    if (usuario?.esAdmin != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Revision')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No tienes permisos de administrador.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pendientes de aprobar')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(proveedorPublicacionesRevisionAdmin),
        child: publicaciones.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.task_alt, size: 56, color: colorPrimario),
                  SizedBox(height: 12),
                  Center(child: Text('No hay publicaciones por revisar.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _TarjetaRevision(
                publicacion: items[index],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [Text('No se pudo cargar la revision: $error')],
          ),
        ),
      ),
    );
  }
}

class _TarjetaRevision extends ConsumerWidget {
  const _TarjetaRevision({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(publicacion.tipo.etiqueta),
                  backgroundColor: _colorTipo(publicacion.tipo).withValues(alpha: .12),
                  side: BorderSide.none,
                ),
                Chip(label: Text(publicacion.estado.etiqueta), side: BorderSide.none),
              ],
            ),
            const SizedBox(height: 6),
            Text(publicacion.titulo, style: Theme.of(context).textTheme.titleMedium),
            if ((publicacion.nombreMascota ?? '').isNotEmpty)
              Text('Mascota: ${publicacion.nombreMascota}'),
            if ((publicacion.cuerpo ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(publicacion.cuerpo!, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            if ((publicacion.notaAdmin ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Nota admin: ${publicacion.notaAdmin}'),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _aprobar(context, ref),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aprobar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pedirNota(
                    context,
                    titulo: 'Observar publicacion',
                    accion: (nota) => ref
                        .read(proveedorPublicaciones.notifier)
                        .observarPublicacion(publicacion.id, nota),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Observar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pedirNota(
                    context,
                    titulo: 'Rechazar publicacion',
                    accion: (nota) => ref
                        .read(proveedorPublicaciones.notifier)
                        .rechazarPublicacion(publicacion.id, nota),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Rechazar'),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/publicacion/${publicacion.id}'),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver detalle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _aprobar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(proveedorPublicaciones.notifier).aprobarPublicacion(publicacion.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicacion aprobada.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo aprobar: $error')),
        );
      }
    }
  }

  Future<void> _pedirNota(
    BuildContext context, {
    required String titulo,
    required Future<void> Function(String nota) accion,
  }) async {
    final controlador = TextEditingController();
    final nota = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Nota para el usuario',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controlador.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nota == null || nota.isEmpty) return;
    try {
      await accion(nota);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revision guardada.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: $error')),
        );
      }
    }
  }

  Color _colorTipo(TipoPublicacion tipo) => switch (tipo) {
        TipoPublicacion.perdido => colorPerdido,
        TipoPublicacion.rescatado => colorRescatado,
        TipoPublicacion.adopcion => colorAdopcion,
      };
}
