// Muestra el detalle de una publicacion y sus acciones segun negocio.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../../../compartido/servicios/servicio_notificaciones_push.dart';
import '../../../nucleo/constantes/colores.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/rutas.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../../avistamientos/proveedores/proveedor_avistamiento.dart';
import '../../calificaciones/widgets/widget_calificacion.dart';
import '../modelos/modelo_publicacion.dart';
import '../proveedores/proveedor_publicacion.dart';
import '../repositorios/repositorio_publicacion.dart';

class PantallaDetallePublicacion extends ConsumerWidget {
  const PantallaDetallePublicacion({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(proveedorDetallePublicacion(id));
    final usuarioActual = ref.watch(proveedorAutenticacion).valueOrNull;
    final publicacionActual = detalle.valueOrNull;
    final esAutorActual = publicacionActual != null &&
        (usuarioActual?.id ?? usuariosMock.first.id) == publicacionActual.autorId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F9),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/inicio/feed');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver al menu principal',
        ),
        title: Text(_tituloDetalle(publicacionActual?.tipo)),
        actions: [
          if (esAutorActual)
            IconButton(
              onPressed: () =>
                  context.go('/publicacion/editar/${publicacionActual.id}'),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar publicacion',
            ),
          IconButton(
            onPressed: publicacionActual == null
                ? null
                : () => _compartirPublicacion(publicacionActual),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: detalle.when(
        data: (publicacion) {
          if (publicacion == null) {
            return const Center(child: Text('Publicacion no encontrada'));
          }

          final esAutor = (usuarioActual?.id ?? usuariosMock.first.id) == publicacion.autorId;
          final avistamientos = ref.watch(proveedorAvistamientos(publicacion.id));
          final solicitudesAdopcion = ref.watch(proveedorSolicitudesAdopcion(publicacion.id));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _CarruselPublicacion(publicacion: publicacion),
              const SizedBox(height: 20),
              _EncabezadoPublicacion(publicacion: publicacion),
              if (publicacion.estado == EstadoPublicacion.observado && publicacion.notaAdmin != null)
                Card(
                  color: colorError.withValues(alpha: .06),
                  child: ListTile(
                    leading: const Icon(Icons.report_problem_outlined, color: colorError),
                    title: const Text('Observacion del administrador'),
                    subtitle: Text(publicacion.notaAdmin!),
                  ),
                ),
              const SizedBox(height: 18),
              if (publicacion.cuerpo != null && publicacion.cuerpo!.isNotEmpty)
                Text(
                  publicacion.cuerpo!,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                      ),
                ),
              const SizedBox(height: 12),
              _ChipsDetalle(publicacion: publicacion),
              const SizedBox(height: 18),
              _SeccionDetalle(
                titulo: 'Mis datos',
                icono: Icons.assignment_outlined,
                children: [
                  _DatoDetalle(etiqueta: 'Especie', valor: publicacion.especieMascota?.name),
                  _DatoDetalle(etiqueta: 'Raza', valor: publicacion.razaMascota),
                  _DatoDetalle(etiqueta: 'Sexo', valor: publicacion.generoMascota),
                  _DatoDetalle(etiqueta: 'Edad', valor: publicacion.edadMascota),
                  _DatoDetalle(etiqueta: 'Tamanio', valor: publicacion.tamanioMascota?.name),
                  _DatoDetalle(etiqueta: 'Color', valor: publicacion.colorCaracteristicas),
                ],
              ),
              const SizedBox(height: 12),
              _SeccionDetalle(
                titulo: publicacion.tipo == TipoPublicacion.adopcion
                    ? 'Me entregan'
                    : 'Contacto y ubicacion',
                icono: Icons.contact_page_outlined,
                children: [
                  _DatoDetalle(etiqueta: 'Direccion', valor: publicacion.direccion ?? 'Ubicacion referencial'),
                  _DatoDetalle(etiqueta: 'Telefono', valor: publicacion.telefonoContacto),
                  if (publicacion.requisitosAdopcion != null && publicacion.requisitosAdopcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(publicacion.requisitosAdopcion!),
                    ),
                ],
              ),
              if (publicacion.descripcionMascota != null && publicacion.descripcionMascota!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SeccionDetalle(
                  titulo: 'Mas informacion',
                  icono: Icons.description_outlined,
                  children: [
                    Text(publicacion.descripcionMascota!),
                  ],
                ),
              ],
              if (publicacion.tipo == TipoPublicacion.perdido) ...[
                const SizedBox(height: 12),
                _MapaProximaMejora(publicacion: publicacion),
              ],
              const SizedBox(height: 18),
              ..._accionesPorTipo(context, ref, publicacion, esAutor),
              if (esAutor && publicacion.tipo == TipoPublicacion.adopcion) ...[
                const SizedBox(height: 16),
                _SolicitantesAdopcion(solicitudes: solicitudesAdopcion),
              ],
              if (publicacion.estado == EstadoPublicacion.resuelto) ...[
                const SizedBox(height: 12),
                WidgetCalificacion(usuarioId: publicacion.autorId),
              ],
              if (publicacion.tipo == TipoPublicacion.perdido) ...[
                const SizedBox(height: 16),
                Text('Avistamientos', style: Theme.of(context).textTheme.titleLarge),
                avistamientos.when(
                  data: (items) => Column(
                    children: [
                      for (final item in items)
                        ListTile(leading: const Icon(Icons.place_outlined), title: Text(item.direccion ?? 'Sin direccion'), subtitle: Text(item.notas ?? 'Sin notas')),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('No se pudieron cargar avistamientos'),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  List<Widget> _accionesPorTipo(BuildContext context, WidgetRef ref, ModeloPublicacion publicacion, bool esAutor) {
    final activo = publicacion.estado == EstadoPublicacion.activo;

    if (publicacion.tipo == TipoPublicacion.perdido) {
      return [
        if (activo && !esAutor)
          _BotonAccionDetalle(
            icono: Icons.add_location_alt_outlined,
            texto: 'Reportar avistamiento',
            onPressed: () => context.go('/avistamiento/${publicacion.id}'),
          ),
        if (activo && esAutor)
          _BotonAccionDetalle(
            onPressed: () => ref.read(proveedorPublicaciones.notifier).cerrarPublicacion(publicacion.id, resuelto: true),
            icono: Icons.check_circle_outline,
            texto: 'Mascota encontrada',
          ),
      ];
    }

    if (publicacion.tipo == TipoPublicacion.rescatado) {
      final meta = publicacion.metaApoyo;
      return [
        if (meta != null) ...[
          const Text('Apoyo economico acumulado'),
          const LinearProgressIndicator(value: .35),
          const SizedBox(height: 8),
          Text('S/. ${(meta * .35).toStringAsFixed(0)} de S/. ${meta.toStringAsFixed(0)}'),
        ],
        if (activo && !esAutor)
          _BotonAccionDetalle(
            onPressed: () async {
              final resultado = await ServicioNotificacionesPush.instancia
                  .notificarInteresApoyo(publicacion.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      resultado.ok
                          ? 'Se aviso al duenio de la publicacion.'
                          : 'No se pudo enviar la notificacion: ${resultado.mensaje}',
                    ),
                  ),
                );
              }
            },
            icono: Icons.volunteer_activism,
            texto: 'Ser padrino',
          ),
        if (activo && esAutor)
          _BotonAccionDetalle(
            onPressed: () => ref.read(proveedorPublicaciones.notifier).cerrarPublicacion(publicacion.id, resuelto: true),
            icono: Icons.check_circle_outline,
            texto: 'Caso resuelto',
          ),
      ];
    }

    return [
      if (activo && !esAutor)
        _BotonAccionDetalle(
            onPressed: () async {
              try {
                await ref
                    .read(proveedorRepositorioPublicacion)
                    .crearSolicitudAdopcion(publicacion.id);
                ref.invalidate(proveedorSolicitudesAdopcion(publicacion.id));
                final resultado = await ServicioNotificacionesPush.instancia
                    .notificarInteresAdopcion(publicacion.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        resultado.ok
                            ? 'Solicitud registrada y duenio notificado.'
                            : 'Solicitud registrada. No se pudo enviar la notificacion: ${resultado.mensaje}',
                      ),
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo registrar la solicitud: $error')),
                  );
                }
              }
            },
            icono: Icons.favorite_border,
            texto: 'Solicitar adopcion'),
      if (activo && esAutor)
        _BotonAccionDetalle(
          onPressed: () => ref.read(proveedorPublicaciones.notifier).cerrarPublicacion(publicacion.id, resuelto: true),
          icono: Icons.check_circle_outline,
          texto: 'Marcar como adoptado',
        ),
    ];
  }

  String _tituloDetalle(TipoPublicacion? tipo) => switch (tipo) {
        TipoPublicacion.perdido => 'Caso de busqueda',
        TipoPublicacion.rescatado => 'Caso de apoyo',
        TipoPublicacion.adopcion => 'Caso de adopcion',
        null => 'Detalle',
      };
}

Future<void> _compartirPublicacion(ModeloPublicacion publicacion) async {
  final nombre = publicacion.nombreMascota?.trim().isNotEmpty == true
      ? publicacion.nombreMascota!.trim()
      : publicacion.titulo.trim().isNotEmpty
          ? publicacion.titulo.trim()
          : 'Esta mascota';
  final ubicacion = publicacion.direccion?.trim();
  final enlace = 'https://${Rutas.dominioEnlaces}/p/${publicacion.id}';
  final lineas = <String>[
    '🐾 $nombre',
    '',
    'Estado: ${publicacion.tipo.etiqueta}',
    if (ubicacion != null && ubicacion.isNotEmpty) 'Ubicacion: $ubicacion',
    '',
    'Conoce esta publicacion y ayuda a compartirla.',
    enlace,
    '',
    'Compartido desde PetFindr.',
  ];
  await SharePlus.instance.share(ShareParams(text: lineas.join('\n')));
}

class _CarruselPublicacion extends StatefulWidget {
  const _CarruselPublicacion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  State<_CarruselPublicacion> createState() => _CarruselPublicacionState();
}

class _CarruselPublicacionState extends State<_CarruselPublicacion> {
  late final PageController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = PageController(viewportFraction: .94);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fotos = widget.publicacion.fotos;
    return SizedBox(
      height: 292,
      child: PageView.builder(
        padEnds: false,
        controller: _controlador,
        itemCount: fotos.isEmpty ? 3 : fotos.length,
        itemBuilder: (context, index) {
          if (fotos.isEmpty) {
            return _FotoVacia(indice: index + 1);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: fotos[index],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) => const _FotoVacia(indice: 1),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FotoVacia extends StatelessWidget {
  const _FotoVacia({required this.indice});

  final int indice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6C4DF6).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF6C4DF6).withValues(alpha: .16)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 72, color: const Color(0xFF6C4DF6).withValues(alpha: .7)),
            const SizedBox(height: 12),
            Text(
              '$indice',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF6C4DF6),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncabezadoPublicacion extends StatelessWidget {
  const _EncabezadoPublicacion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final nombre = publicacion.nombreMascota?.trim().isNotEmpty == true
        ? publicacion.nombreMascota!.trim()
        : publicacion.titulo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                nombre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Guardar favorito',
            ),
          ],
        ),
        Text(
          publicacion.titulo,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _ChipsDetalle extends StatelessWidget {
  const _ChipsDetalle({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      publicacion.tipo.etiqueta,
      publicacion.estado.etiqueta,
      if (publicacion.gravedad != null) publicacion.gravedad!.etiqueta,
      if ((publicacion.colorCaracteristicas ?? '').isNotEmpty)
        publicacion.colorCaracteristicas!,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(chip),
                backgroundColor: const Color(0xFF6C4DF6),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                side: BorderSide.none,
              ),
            ),
        ],
      ),
    );
  }
}

class _SeccionDetalle extends StatelessWidget {
  const _SeccionDetalle({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          leading: Icon(icono, color: Colors.black),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          title: Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6C4DF6),
                  fontWeight: FontWeight.w900,
                ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatoDetalle extends StatelessWidget {
  const _DatoDetalle({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String? valor;

  @override
  Widget build(BuildContext context) {
    final texto = valor == null || valor!.trim().isEmpty
        ? 'No especificado'
        : _capitalizar(valor!.trim());
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              texto,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizar(String valor) {
    if (valor.isEmpty) return valor;
    return '${valor[0].toUpperCase()}${valor.substring(1)}';
  }
}

class _MapaProximaMejora extends StatelessWidget {
  const _MapaProximaMejora({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final punto = publicacion.latitud == null || publicacion.longitud == null
        ? null
        : LatLng(publicacion.latitud!, publicacion.longitud!);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map_outlined, color: Color(0xFF6C4DF6)),
                const SizedBox(width: 8),
                Text(
                  'Zona de busqueda',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF6C4DF6),
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: punto == null
                    ? _MapaSinCoordenadas(direccion: publicacion.direccion)
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: punto,
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.drag |
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.doubleTapZoom,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.flutter_application_1prueba',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: punto,
                                width: 64,
                                height: 72,
                                child: const _MarcadorBusqueda(),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              publicacion.direccion ?? 'Ubicacion referencial',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (punto != null)
              Text(
                '${punto.latitude.toStringAsFixed(5)}, ${punto.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapaSinCoordenadas extends StatelessWidget {
  const _MapaSinCoordenadas({required this.direccion});

  final String? direccion;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6C4DF6).withValues(alpha: .08),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF6C4DF6),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            direccion ?? 'Ubicacion referencial',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MarcadorBusqueda extends StatelessWidget {
  const _MarcadorBusqueda();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6C4DF6), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.location_on,
            color: Color(0xFF6C4DF6),
            size: 42,
          ),
        ],
      ),
    );
  }
}

class _BotonAccionDetalle extends StatelessWidget {
  const _BotonAccionDetalle({
    required this.icono,
    required this.texto,
    required this.onPressed,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icono),
        label: Text(texto),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6C4DF6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SolicitantesAdopcion extends StatelessWidget {
  const _SolicitantesAdopcion({required this.solicitudes});

  final AsyncValue<List<ModeloSolicitudAdopcion>> solicitudes;

  @override
  Widget build(BuildContext context) {
    return _SeccionDetalle(
      titulo: 'Personas interesadas',
      icono: Icons.group_outlined,
      children: [
        solicitudes.when(
          data: (items) {
            if (items.isEmpty) {
              return const Text('Aun nadie solicito adoptar esta mascota.');
            }
            return Column(
              children: [
                for (final solicitud in items)
                  _TarjetaSolicitanteAdopcion(solicitud: solicitud),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('No se pudieron cargar solicitantes: $error'),
        ),
      ],
    );
  }
}

class _TarjetaSolicitanteAdopcion extends StatelessWidget {
  const _TarjetaSolicitanteAdopcion({required this.solicitud});

  final ModeloSolicitudAdopcion solicitud;

  @override
  Widget build(BuildContext context) {
    final perfil = solicitud.solicitante;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                perfil?.avatarUrl == null ? null : CachedNetworkImageProvider(perfil!.avatarUrl!),
            child: perfil?.avatarUrl == null ? const Icon(Icons.person_outline) : null,
          ),
          title: Text(perfil?.nombreCompleto ?? 'Usuario'),
          subtitle: Text([
            perfil?.telefono,
            perfil?.ciudad,
            'Estado: ${solicitud.estado}',
            if ((solicitud.mensaje ?? '').isNotEmpty) solicitud.mensaje,
          ].whereType<String>().where((texto) => texto.trim().isNotEmpty).join(' - ')),
          trailing: IconButton(
            onPressed: perfil == null ? null : () => context.push('/perfil/${perfil.id}'),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Ver perfil',
          ),
        ),
      ),
    );
  }
}
