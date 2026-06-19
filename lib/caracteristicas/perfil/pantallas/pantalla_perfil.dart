// Pantalla de perfil propio o publico de usuario.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/rutas.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../../calificaciones/widgets/widget_calificacion.dart';
import '../../publicaciones/modelos/modelo_publicacion.dart';
import '../../publicaciones/proveedores/proveedor_publicacion.dart';

class PantallaPerfil extends ConsumerWidget {
  const PantallaPerfil({super.key, this.usuarioId});

  final String? usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAutenticado = ref.watch(proveedorAutenticacion).valueOrNull;
    final perfil =
        usuarioId == null && usuarioAutenticado != null
            ? usuarioAutenticado
            : usuariosMock
                    .where((u) => u.id == (usuarioId ?? usuariosMock.first.id))
                    .firstOrNull ??
                usuariosMock.first;
    final publicacionesAsync = ref.watch(proveedorPublicaciones);
    final positivas =
        calificacionesMock
            .where((c) => c.objetivoId == perfil.id && c.valor == 1)
            .length;
    final negativas =
        calificacionesMock
            .where((c) => c.objetivoId == perfil.id && c.valor == -1)
            .length;
    final porcentaje =
        positivas + negativas == 0
            ? 0
            : (positivas / (positivas + negativas) * 100).round();
    final esPerfilPropio = usuarioId == null;

    return Scaffold(
      appBar: AppBar(
        leading: usuarioId == null
            ? null
            : IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }
                  context.go(Rutas.feed);
                },
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Volver',
              ),
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 42, backgroundImage: perfil.avatarUrl == null ? null : CachedNetworkImageProvider(perfil.avatarUrl!)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(perfil.nombreCompleto, style: Theme.of(context).textTheme.titleLarge),
                    Text('${perfil.ciudad ?? 'Peru'} - ${perfil.rol.name}'),
                    if (perfil.verificado) const Chip(label: Text('Refugio verificado'), avatar: Icon(Icons.verified, size: 18)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined), tooltip: 'Editar'),
            ],
          ),
          if (esPerfilPropio) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(proveedorAutenticacion.notifier).cerrarSesion();
                if (context.mounted) {
                  context.go(Rutas.inicioSesion);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesion'),
            ),
          ],
          if (perfil.nombreRefugio != null) ListTile(title: Text(perfil.nombreRefugio!), subtitle: Text(perfil.bioRefugio ?? '')),
          const SizedBox(height: 12),
          Card(child: ListTile(leading: const Icon(Icons.thumb_up_alt_outlined), title: Text('$porcentaje% positivo'), subtitle: Text('$positivas positivos, $negativas negativos'))),
          WidgetCalificacion(usuarioId: perfil.id),
          const SizedBox(height: 16),
          Text('Publicaciones activas', style: Theme.of(context).textTheme.titleLarge),
          publicacionesAsync.when(
            data: (items) {
              final publicaciones =
                  items.where((p) => p.autorId == perfil.id).toList();
              if (publicaciones.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aun no tienes publicaciones.'),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: publicaciones.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemBuilder: (context, index) => _TarjetaPerfilPublicacion(
                  publicacion: publicaciones[index],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('No se pudieron cargar publicaciones: $error'),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPerfilPublicacion extends StatelessWidget {
  const _TarjetaPerfilPublicacion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: InkWell(
        onTap: () => context.push('/publicacion/${publicacion.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (publicacion.fotos.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: publicacion.fotos.first,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: Icon(Icons.pets, size: 42, color: Theme.of(context).colorScheme.primary),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _EtiquetaPerfil(texto: publicacion.estado.etiqueta),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.tipo.etiqueta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    publicacion.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaPerfil extends StatelessWidget {
  const _EtiquetaPerfil({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
