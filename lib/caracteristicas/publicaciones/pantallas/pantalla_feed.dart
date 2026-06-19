// Muestra el feed de publicaciones con filtros y refresco.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/constantes/colores.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/rutas.dart';
import '../../../nucleo/utilidades/ayudante_fecha.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../modelos/modelo_publicacion.dart';
import '../proveedores/proveedor_publicacion.dart';

class PantallaFeed extends ConsumerWidget {
  const PantallaFeed({super.key, this.filtroInicial});

  final TipoPublicacion? filtroInicial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicaciones = ref.watch(proveedorPublicaciones);
    final usuario = ref.watch(proveedorAutenticacion).valueOrNull ?? usuariosMock.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(proveedorPublicaciones.notifier).refrescar(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            children: [
            _EncabezadoSocial(nombre: usuario.nombreCompleto),
            const SizedBox(height: 22),
            _EntradaPublicar(onTap: () => context.go(Rutas.crearPublicacion)),
            const SizedBox(height: 18),
            const _BannerAnuncio(),
            const SizedBox(height: 18),
            _AlertaPerdidos(publicaciones: publicaciones.valueOrNull ?? []),
            const SizedBox(height: 12),
            Text(
              'Publicaciones recientes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 8),
            _Filtros(filtroInicial: filtroInicial),
            const SizedBox(height: 14),
            publicaciones.when(
              data: (items) {
                final visibles = (filtroInicial == null
                        ? items.where((p) => !_esPublicacionPropiaEnRevision(p, usuario.id))
                        : items.where((p) => p.tipo == filtroInicial))
                    .toList();
                return Column(
                  children: [
                    if (filtroInicial == null)
                      _MisPublicacionesEnRevision(
                        publicaciones: items,
                        usuarioId: usuario.id,
                      ),
                    if (visibles.isEmpty)
                      const _TarjetaSinPublicaciones()
                    else ...[
                      for (final publicacion in visibles)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TarjetaPublicacion(publicacion: publicacion),
                        ),
                      TextButton.icon(
                        onPressed: () => ref.read(proveedorPublicaciones.notifier).cargarMas(),
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Cargar mas'),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Ocurrio un error: $error'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EncabezadoSocial extends StatelessWidget {
  const _EncabezadoSocial({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    final primerNombre = nombre.split(' ').where((p) => p.isNotEmpty).firstOrNull ?? 'Hola';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PetFindr',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '${AyudanteFecha.saludo(DateTime.now())}, $primerNombre',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.info_outline),
          tooltip: 'Informacion',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notificaciones',
        ),
      ],
    );
  }
}

class _EntradaPublicar extends StatelessWidget {
  const _EntradaPublicar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF6C4DF6).withValues(alpha: .12),
            child: const Icon(Icons.pets, color: Color(0xFF6C4DF6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Deseas publicar?',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerAnuncio extends StatelessWidget {
  const _BannerAnuncio();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6D45F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'ANUNCIA\nAQUI!!!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: .92,
                  ),
            ),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, size: 54, color: Color(0xFF6C4DF6)),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSinPublicaciones extends StatelessWidget {
  const _TarjetaSinPublicaciones();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
        child: Column(
          children: [
            Icon(Icons.pets, size: 64, color: colorPrimario.withValues(alpha: .75)),
            const SizedBox(height: 12),
            Text(
              'No hay publicaciones',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

bool _esPublicacionPropiaEnRevision(ModeloPublicacion publicacion, String usuarioId) =>
    publicacion.autorId == usuarioId &&
    publicacion.estado != EstadoPublicacion.activo &&
    publicacion.estado != EstadoPublicacion.resuelto &&
    publicacion.estado != EstadoPublicacion.cerrado &&
    publicacion.estado != EstadoPublicacion.eliminado;

class _MisPublicacionesEnRevision extends StatelessWidget {
  const _MisPublicacionesEnRevision({
    required this.publicaciones,
    required this.usuarioId,
  });

  final List<ModeloPublicacion> publicaciones;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    final propias = publicaciones
        .where((p) => _esPublicacionPropiaEnRevision(p, usuarioId))
        .toList();

    if (propias.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mis publicaciones en revision', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final publicacion in propias)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TarjetaPublicacion(publicacion: publicacion),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _AlertaPerdidos extends StatelessWidget {
  const _AlertaPerdidos({required this.publicaciones});

  final List<ModeloPublicacion> publicaciones;

  @override
  Widget build(BuildContext context) {
    final perdidos = publicaciones.where((p) => p.tipo == TipoPublicacion.perdido && (p.distanciaMetros ?? 99999) <= 5000).length;
    if (perdidos == 0) return const SizedBox.shrink();
    return Material(
      color: colorPerdido.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: colorPerdido),
        title: Text('$perdidos mascotas perdidas cerca'),
        subtitle: const Text('Revisa el mapa y reporta si viste alguna.'),
      ),
    );
  }
}

class _Filtros extends ConsumerWidget {
  const _Filtros({this.filtroInicial});

  final TipoPublicacion? filtroInicial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroActual =
        ref.watch(proveedorPublicaciones.notifier).filtro ?? filtroInicial;
    final filtros = <(String, TipoPublicacion?)>[
      ('Todos', null),
      ('Perdidos', TipoPublicacion.perdido),
      ('Rescatados', TipoPublicacion.rescatado),
      ('En adopcion', TipoPublicacion.adopcion),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filtro in filtros)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: filtro.$2 == filtroActual,
                selectedColor: _colorFiltro(filtro.$2).withValues(alpha: .18),
                backgroundColor: Colors.grey.shade100,
                checkmarkColor: _colorFiltro(filtro.$2),
                side: BorderSide(
                  color: filtro.$2 == filtroActual
                      ? _colorFiltro(filtro.$2)
                      : Colors.grey.shade300,
                  width: filtro.$2 == filtroActual ? 1.4 : 1,
                ),
                label: Text(filtro.$1),
                labelStyle: TextStyle(
                  color: filtro.$2 == filtroActual
                      ? _colorFiltro(filtro.$2)
                      : Colors.grey.shade700,
                  fontWeight: filtro.$2 == filtroActual
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                onSelected: (_) => ref.read(proveedorPublicaciones.notifier).cambiarFiltro(filtro.$2),
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFiltro(TipoPublicacion? tipo) => switch (tipo) {
        TipoPublicacion.perdido => colorPerdido,
        TipoPublicacion.rescatado => colorRescatado,
        TipoPublicacion.adopcion => colorAdopcion,
        null => colorPrimario,
      };
}

class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final colorTipo = _colorTipo(publicacion.tipo);
    final textoCta = publicacion.tipo == TipoPublicacion.perdido
        ? 'Reportar avistamiento'
        : 'Conocelo mas';
    final iconoCta = publicacion.tipo == TipoPublicacion.perdido
        ? Icons.add_location_alt_outlined
        : Icons.arrow_forward;
    final rutaCta = publicacion.tipo == TipoPublicacion.perdido
        ? '/avistamiento/${publicacion.id}'
        : '/publicacion/${publicacion.id}';

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: .08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => context.push('/publicacion/${publicacion.id}'),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: colorTipo.withValues(alpha: .12),
                    child: Icon(Icons.pets, color: colorTipo),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publicacion.nombreMascota?.isNotEmpty == true ? publicacion.nombreMascota! : 'PetFindr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${publicacion.tipo.etiqueta} - ${publicacion.estado.etiqueta}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.grey.shade600),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if ((publicacion.cuerpo ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      publicacion.cuerpo!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  if (publicacion.estado == EstadoPublicacion.observado && (publicacion.notaAdmin ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorError.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Observacion: ${publicacion.notaAdmin!}'),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    _ImagenPublicacion(publicacion: publicacion),
                    const Positioned(
                      left: 12,
                      top: 12,
                      child: _AccionesFuturasPost(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Etiqueta(
                    texto: publicacion.tipo.etiqueta,
                    color: _colorTipo(publicacion.tipo),
                  ),
                  _Etiqueta(
                    texto: publicacion.estado.etiqueta,
                    color: Colors.blueGrey,
                  ),
                  if (publicacion.tipo == TipoPublicacion.rescatado && publicacion.gravedad != null)
                    _Etiqueta(
                      texto: publicacion.gravedad!.etiqueta,
                      color: colorRescatado,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => context.push(rutaCta),
                  icon: Icon(iconoCta),
                  label: Text(textoCta),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C4DF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorTipo(TipoPublicacion tipo) => switch (tipo) {
        TipoPublicacion.perdido => colorPerdido,
        TipoPublicacion.rescatado => colorRescatado,
        TipoPublicacion.adopcion => colorAdopcion,
  };
}

class _AccionesFuturasPost extends StatelessWidget {
  const _AccionesFuturasPost();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Icon(Icons.favorite_border, color: Colors.white),
            SizedBox(height: 2),
            Text('0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            SizedBox(height: 2),
            Text('0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ImagenPublicacion extends StatelessWidget {
  const _ImagenPublicacion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    if (publicacion.fotos.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const FlutterLogo(size: 92),
      );
    }

    return CachedNetworkImage(
      imageUrl: publicacion.fotos.first,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 220,
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      errorWidget: (_, __, ___) => Container(
        height: 220,
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const FlutterLogo(size: 92),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
