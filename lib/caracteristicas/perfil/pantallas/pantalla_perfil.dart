// Pantalla de perfil propio o publico de usuario.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/rutas.dart';
import '../../autenticacion/modelos/modelo_usuario.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../../calificaciones/widgets/widget_calificacion.dart';
import '../../publicaciones/modelos/modelo_publicacion.dart';
import '../../publicaciones/proveedores/proveedor_publicacion.dart';
import '../proveedores/proveedor_perfil.dart';

class PantallaPerfil extends ConsumerStatefulWidget {
  const PantallaPerfil({super.key, this.usuarioId});

  final String? usuarioId;

  @override
  ConsumerState<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends ConsumerState<PantallaPerfil> {
  final _selectorImagen = ImagePicker();
  bool _cambiandoAvatar = false;

  Future<void> _cambiarAvatar() async {
    final foto = await _selectorImagen.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (foto == null || !mounted) return;

    setState(() => _cambiandoAvatar = true);
    try {
      final extension = _extensionFoto(foto.name);
      await ref.read(proveedorAutenticacion.notifier).actualizarAvatar(
            bytes: await foto.readAsBytes(),
            extension: extension,
            contentType: _tipoContenido(extension),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar la foto. Intentalo de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cambiandoAvatar = false);
    }
  }

  String _extensionFoto(String nombre) {
    final extension = nombre.split('.').last.toLowerCase();
    return switch (extension) {
      'png' || 'webp' => extension,
      _ => 'jpg',
    };
  }

  String _tipoContenido(String extension) => switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

  @override
  Widget build(BuildContext context) {
    final usuarioAutenticado = ref.watch(proveedorAutenticacion).valueOrNull;
    final esPerfilPropio = widget.usuarioId == null;
    final perfilExterno = esPerfilPropio
        ? null
        : ref.watch(proveedorPerfilPorId(widget.usuarioId!));
    if (!esPerfilPropio && perfilExterno!.isLoading) {
      return const _PantallaPerfilCargando();
    }
    if (!esPerfilPropio && perfilExterno!.hasError) {
      return _PantallaPerfilNoDisponible(
        mensaje: 'No se pudo cargar este perfil.',
      );
    }
    final perfil = esPerfilPropio
        ? usuarioAutenticado ?? usuariosMock.first
        : perfilExterno!.valueOrNull;
    if (perfil == null) {
      return const _PantallaPerfilNoDisponible(
        mensaje: 'Este perfil ya no esta disponible.',
      );
    }
    final publicacionesAsync = ref.watch(proveedorPublicaciones);
    final positivas = calificacionesMock
        .where((c) => c.objetivoId == perfil.id && c.valor == 1)
        .length;
    final negativas = calificacionesMock
        .where((c) => c.objetivoId == perfil.id && c.valor == -1)
        .length;
    final porcentaje = positivas + negativas == 0
        ? 0
        : (positivas / (positivas + negativas) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F7),
        surfaceTintColor: Colors.transparent,
        leading: widget.usuarioId == null
            ? null
            : IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }
                  context.go(Rutas.feed);
                },
                icon: const Icon(Icons.chevron_left, size: 30),
                tooltip: 'Volver',
              ),
        title: Text(esPerfilPropio ? 'Mi perfil' : 'Perfil'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
        actions: [
          if (esPerfilPropio)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _EncabezadoPerfil(
            perfil: perfil,
            permiteCambiarFoto: esPerfilPropio,
            cambiandoAvatar: _cambiandoAvatar,
            onCambiarFoto: _cambiarAvatar,
          ),
          if (esPerfilPropio) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(proveedorAutenticacion.notifier).cerrarSesion();
                if (context.mounted) context.go(Rutas.inicioSesion);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6C4DF6),
                side: const BorderSide(color: Color(0xFF6C4DF6)),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout_outlined),
              label: const Text(
                'Cerrar sesion',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
          if (perfil.nombreRefugio != null) ...[
            const SizedBox(height: 16),
            _SeccionRefugio(perfil: perfil),
          ],
          const SizedBox(height: 16),
          _SeccionConfianza(
            porcentaje: porcentaje,
            positivas: positivas,
            negativas: negativas,
            usuarioId: perfil.id,
          ),
          const SizedBox(height: 28),
          Text(
            esPerfilPropio ? 'Tus publicaciones' : 'Publicaciones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            esPerfilPropio
                ? 'Gestiona las mascotas y avisos que compartiste.'
                : 'Avisos publicados por esta persona.',
            style: const TextStyle(
              color: Color(0xFF949494),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          publicacionesAsync.when(
            data: (items) {
              final publicaciones =
                  items.where((p) => p.autorId == perfil.id).toList();
              if (publicaciones.isEmpty) {
                return const _SinPublicaciones();
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: publicaciones.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .72,
                ),
                itemBuilder: (context, index) => _TarjetaPerfilPublicacion(
                  publicacion: publicaciones[index],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _EstadoError(mensaje: '$error'),
          ),
        ],
      ),
    );
  }
}

class _PantallaPerfilCargando extends StatelessWidget {
  const _PantallaPerfilCargando();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F6F7),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PantallaPerfilNoDisponible extends StatelessWidget {
  const _PantallaPerfilNoDisponible({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F7),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Rutas.feed);
            }
          },
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF949494),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EncabezadoPerfil extends StatelessWidget {
  const _EncabezadoPerfil({
    required this.perfil,
    required this.permiteCambiarFoto,
    required this.cambiandoAvatar,
    required this.onCambiarFoto,
  });

  final ModeloUsuario perfil;
  final bool permiteCambiarFoto;
  final bool cambiandoAvatar;
  final VoidCallback onCambiarFoto;

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFF6C4DF6);
    final subtitulo = perfil.ciudad ?? 'Miembro de PetFindr';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarPerfil(
            perfil: perfil,
            permiteCambiarFoto: permiteCambiarFoto,
            cambiando: cambiandoAvatar,
            onCambiarFoto: onCambiarFoto,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfil.nombreCompleto,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InsigniaRol(
                    texto: perfil.rol == RolUsuario.refugio
                        ? 'Refugio'
                        : 'Cuidador',
                    icono: perfil.rol == RolUsuario.refugio
                        ? Icons.home_work_outlined
                        : Icons.pets_outlined,
                  ),
                  if (perfil.verificado) ...[
                    const SizedBox(height: 8),
                    const _InsigniaRol(
                      texto: 'Perfil verificado',
                      icono: Icons.verified_outlined,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPerfil extends StatelessWidget {
  const _AvatarPerfil({
    required this.perfil,
    required this.permiteCambiarFoto,
    required this.cambiando,
    required this.onCambiarFoto,
  });

  final ModeloUsuario perfil;
  final bool permiteCambiarFoto;
  final bool cambiando;
  final VoidCallback onCambiarFoto;

  @override
  Widget build(BuildContext context) {
    const morado = Color(0xFF6C4DF6);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration:
              const BoxDecoration(color: morado, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 41,
            backgroundColor: const Color(0xFFEDE9FF),
            backgroundImage: perfil.avatarUrl == null
                ? null
                : CachedNetworkImageProvider(perfil.avatarUrl!),
            child: perfil.avatarUrl == null
                ? const Icon(Icons.person_outline_rounded,
                    color: morado, size: 42)
                : null,
          ),
        ),
        if (permiteCambiarFoto)
          Positioned(
            right: -2,
            bottom: -3,
            child: Tooltip(
              message: 'Cambiar foto de perfil',
              child: Material(
                color: morado,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: cambiando ? null : onCambiarFoto,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: cambiando
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InsigniaRol extends StatelessWidget {
  const _InsigniaRol({required this.texto, required this.icono});

  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: const Color(0xFF6C4DF6)),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              color: Color(0xFF6C4DF6),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionRefugio extends StatelessWidget {
  const _SeccionRefugio({required this.perfil});

  final ModeloUsuario perfil;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.volunteer_activism_outlined,
              color: Color(0xFFC0821F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perfil.nombreRefugio!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if ((perfil.bioRefugio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    perfil.bioRefugio!,
                    style: const TextStyle(
                      color: Color(0xFF807768),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionConfianza extends StatelessWidget {
  const _SeccionConfianza({
    required this.porcentaje,
    required this.positivas,
    required this.negativas,
    required this.usuarioId,
  });

  final int porcentaje;
  final int positivas;
  final int negativas;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  color: Color(0xFF6C4DF6)),
              SizedBox(width: 8),
              Text(
                'Confianza de la comunidad',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$porcentaje%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF6C4DF6),
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$positivas valoraciones positivas y $negativas negativas.',
                  style: const TextStyle(
                    color: Color(0xFF949494),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 6),
          WidgetCalificacion(usuarioId: usuarioId),
        ],
      ),
    );
  }
}

class _SinPublicaciones extends StatelessWidget {
  const _SinPublicaciones();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Icon(Icons.pets_outlined, size: 42, color: Color(0xFF6C4DF6)),
          SizedBox(height: 12),
          Text(
            'Aun no hay publicaciones.',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 4),
          Text(
            'Cuando haya un aviso, aparecera aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF949494)),
          ),
        ],
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  const _EstadoError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('No se pudieron cargar publicaciones: $mensaje'),
    );
  }
}

class _TarjetaPerfilPublicacion extends StatelessWidget {
  const _TarjetaPerfilPublicacion({required this.publicacion});

  final ModeloPublicacion publicacion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
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
                      errorWidget: (_, __, ___) => _ImagenSinFoto(),
                    )
                  else
                    _ImagenSinFoto(),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _EtiquetaPerfil(texto: publicacion.estado.etiqueta),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.tipo.etiqueta.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6C4DF6),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    publicacion.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
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

class _ImagenSinFoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDE9FF),
      alignment: Alignment.center,
      child: const Icon(Icons.pets_outlined,
          size: 42, color: Color(0xFF6C4DF6)),
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
        color: Colors.black.withValues(alpha: .66),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
