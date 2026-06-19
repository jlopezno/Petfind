// Formulario para crear publicaciones.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/rutas.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../../mascotas/modelos/modelo_mascota.dart';
import '../modelos/modelo_publicacion.dart';
import '../proveedores/proveedor_publicacion.dart';
import '../repositorios/repositorio_publicacion.dart';

class PantallaCrearPublicacion extends ConsumerStatefulWidget {
  const PantallaCrearPublicacion({super.key, this.publicacionId});

  final String? publicacionId;

  @override
  ConsumerState<PantallaCrearPublicacion> createState() => _PantallaCrearPublicacionState();
}

class _PantallaCrearPublicacionState extends ConsumerState<PantallaCrearPublicacion> {
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _nombreMascota = TextEditingController();
  final _razaMascota = TextEditingController();
  final _edadMascota = TextEditingController();
  final _colorCaracteristicas = TextEditingController();
  final _telefonoContacto = TextEditingController();
  final _metaApoyo = TextEditingController();
  final _requisitosAdopcion = TextEditingController();
  final _direccion = TextEditingController();
  final _tipo = ValueNotifier<TipoPublicacion>(TipoPublicacion.perdido);
  EspecieMascota _especie = EspecieMascota.perro;
  String _generoMascota = 'macho';
  GravedadCaso _gravedad = GravedadCaso.leve;
  int _pasoActual = 0;
  bool _tipoElegido = false;
  bool _datosPrecargados = false;
  bool _guardando = false;
  LatLng? _puntoPerdida;
  final _picker = ImagePicker();
  final _imagenesSeleccionadas = <XFile>[];

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _nombreMascota.dispose();
    _razaMascota.dispose();
    _edadMascota.dispose();
    _colorCaracteristicas.dispose();
    _telefonoContacto.dispose();
    _metaApoyo.dispose();
    _requisitosAdopcion.dispose();
    _direccion.dispose();
    _tipo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicacionId = widget.publicacionId;
    if (publicacionId != null) {
      final detalle = ref.watch(proveedorDetallePublicacion(publicacionId));
      return detalle.when(
        data: (publicacion) {
          if (publicacion == null) {
            return const Scaffold(
              body: Center(child: Text('Publicacion no encontrada')),
            );
          }
          final usuarioActual =
              ref.watch(proveedorAutenticacion).valueOrNull ?? usuariosMock.first;
          if (usuarioActual.id != publicacion.autorId) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editar publicacion')),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No puedes editar una publicacion que no te pertenece.'),
                ),
              ),
            );
          }
          _precargar(publicacion);
          return _construirFormulario(context, publicacionOriginal: publicacion);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          body: Center(child: Text('No se pudo cargar la publicacion: $error')),
        ),
      );
    }
    return _construirFormulario(context);
  }

  void _precargar(ModeloPublicacion publicacion) {
    if (_datosPrecargados) return;
    _titulo.text = publicacion.titulo;
    _descripcion.text = publicacion.cuerpo ?? '';
    _nombreMascota.text = publicacion.nombreMascota ?? '';
    _razaMascota.text = publicacion.razaMascota ?? '';
    _edadMascota.text = publicacion.edadMascota ?? '';
    _colorCaracteristicas.text = publicacion.colorCaracteristicas ?? '';
    _telefonoContacto.text = publicacion.telefonoContacto ?? '';
    _metaApoyo.text = publicacion.metaApoyo?.toString() ?? '';
    _requisitosAdopcion.text = publicacion.requisitosAdopcion ?? '';
    _direccion.text = publicacion.direccion ?? '';
    _tipo.value = publicacion.tipo;
    _especie = publicacion.especieMascota ?? EspecieMascota.perro;
    _generoMascota = publicacion.generoMascota ?? 'macho';
    _gravedad = publicacion.gravedad ?? GravedadCaso.leve;
    if (publicacion.latitud != null && publicacion.longitud != null) {
      _puntoPerdida = LatLng(publicacion.latitud!, publicacion.longitud!);
    }
    _tipoElegido = true;
    _datosPrecargados = true;
  }

  Widget _construirFormulario(BuildContext context, {ModeloPublicacion? publicacionOriginal}) {
    final esEdicion = publicacionOriginal != null;
    final fotosExistentes = publicacionOriginal?.fotos ?? const <String>[];
    if (!esEdicion && !_tipoElegido) {
      return _SelectorTipoPublicacion(
        onVolver: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Rutas.feed);
          }
        },
        onSeleccionar: (tipo) {
          setState(() {
            _tipo.value = tipo;
            _tipoElegido = true;
            _pasoActual = 0;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      appBar: AppBar(
        title: ValueListenableBuilder<TipoPublicacion>(
          valueListenable: _tipo,
          builder: (context, tipo, _) {
            return Text(
              esEdicion
                  ? 'Editar publicacion'
                  : 'Crear publicacion - ${_tituloTipo(tipo)}',
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          _IndicadorPasos(pasoActual: _pasoActual),
          const SizedBox(height: 26),
          ValueListenableBuilder<TipoPublicacion>(
            valueListenable: _tipo,
            builder: (context, tipo, _) => _contenidoPaso(
              tipo: tipo,
              fotosExistentes: fotosExistentes,
            ),
          ),
          const SizedBox(height: 30),
          _NavegacionPasos(
            pasoActual: _pasoActual,
            guardando: _guardando,
            esEdicion: esEdicion,
            onAtras: () {
              if (_pasoActual > 0) {
                setState(() => _pasoActual--);
              } else if (!esEdicion) {
                setState(() => _tipoElegido = false);
              } else {
                context.pop();
              }
            },
            onContinuar: () {
              if (_pasoActual < 2) {
                setState(() => _pasoActual++);
              } else {
                _guardarPublicacion(
                  context,
                  publicacionOriginal: publicacionOriginal,
                  fotosExistentes: fotosExistentes,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _contenidoPaso({
    required TipoPublicacion tipo,
    required List<String> fotosExistentes,
  }) {
    if (_pasoActual == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampoFormulario(
            etiqueta: 'Nombre',
            child: TextField(
              controller: _nombreMascota,
              decoration: _decoracionCampo(hint: 'Nombre de la mascota'),
            ),
          ),
          const SizedBox(height: 20),
          _CampoFormulario(
            etiqueta: 'Especie',
            child: DropdownButtonFormField<EspecieMascota>(
              initialValue: _especie,
              decoration: _decoracionCampo(),
              items: EspecieMascota.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (valor) => _especie = valor ?? EspecieMascota.perro,
            ),
          ),
          const SizedBox(height: 20),
          _CampoFormulario(
            etiqueta: 'Raza',
            child: TextField(
              controller: _razaMascota,
              decoration: _decoracionCampo(hint: 'Raza o cruce'),
            ),
          ),
          const SizedBox(height: 20),
          _SelectorGenero(
            valor: _generoMascota,
            onChanged: (valor) => setState(() => _generoMascota = valor),
          ),
          const SizedBox(height: 20),
          _CampoFormulario(
            etiqueta: 'Edad',
            child: TextField(
              controller: _edadMascota,
              decoration: _decoracionCampo(hint: 'Ingrese la edad'),
            ),
          ),
        ],
      );
    }

    if (_pasoActual == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampoFormulario(
            etiqueta: 'Titulo',
            child: TextField(
              controller: _titulo,
              decoration: _decoracionCampo(hint: 'Titulo de la publicacion'),
            ),
          ),
          const SizedBox(height: 20),
          _CampoFormulario(
            etiqueta: 'Descripcion',
            child: TextField(
              controller: _descripcion,
              maxLines: 4,
              decoration: _decoracionCampo(hint: _hintDescripcion(tipo)),
            ),
          ),
          const SizedBox(height: 20),
          _CampoFormulario(
            etiqueta: 'Color / caracteristicas',
            child: TextField(
              controller: _colorCaracteristicas,
              decoration: _decoracionCampo(hint: 'Color, marcas o detalles'),
            ),
          ),
          const SizedBox(height: 20),
          _SelectorFotosPublicacion(
            imagenesSeleccionadas: _imagenesSeleccionadas,
            fotosExistentes: fotosExistentes,
            onSeleccionar: _seleccionarFotos,
            onQuitarSeleccionada: (index) {
              setState(() => _imagenesSeleccionadas.removeAt(index));
            },
          ),
          const SizedBox(height: 16),
          if (tipo == TipoPublicacion.perdido)
            _SelectorUbicacionPerdida(
              direccion: _direccion,
              punto: _puntoPerdida,
              onSeleccionar: (punto) => setState(() => _puntoPerdida = punto),
            )
          else
            const ListTile(
              leading: Icon(Icons.my_location),
              title: Text('Ubicacion referencial'),
              subtitle: Text('Lima, Peru'),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CampoFormulario(
          etiqueta: 'Telefono de contacto',
          child: TextField(
            controller: _telefonoContacto,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: _decoracionCampo(hint: '9 digitos').copyWith(
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (tipo == TipoPublicacion.rescatado) ...[
          _CampoFormulario(
            etiqueta: 'Gravedad del caso',
            child: DropdownButtonFormField<GravedadCaso>(
              initialValue: _gravedad,
              decoration: _decoracionCampo(),
              items: GravedadCaso.values
                  .map((g) => DropdownMenuItem(value: g, child: Text(g.etiqueta)))
                  .toList(),
              onChanged: (valor) => _gravedad = valor ?? GravedadCaso.leve,
            ),
          ),
          const SizedBox(height: 20),
          _CampoFormulario(
            etiqueta: 'Meta de apoyo opcional',
            child: TextField(
              controller: _metaApoyo,
              keyboardType: TextInputType.number,
              decoration: _decoracionCampo(hint: 'Ej. 150'),
            ),
          ),
        ] else if (tipo == TipoPublicacion.adopcion) ...[
          _CampoFormulario(
            etiqueta: 'Requisitos del adoptante',
            child: TextField(
              controller: _requisitosAdopcion,
              maxLines: 4,
              decoration: _decoracionCampo(
                hint: 'Cuidados, espacio, compromiso o seguimiento',
              ),
            ),
          ),
        ] else ...[
          _CampoFormulario(
            etiqueta: 'Ultima vez visto',
            child: TextField(
              controller: _requisitosAdopcion,
              maxLines: 4,
              decoration: _decoracionCampo(
                hint: 'Lugar, hora, circunstancias o recompensa',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _guardarPublicacion(
    BuildContext context, {
    ModeloPublicacion? publicacionOriginal,
    required List<String> fotosExistentes,
  }) async {
    final usuario = ref.read(proveedorAutenticacion).valueOrNull;
    if (publicacionOriginal != null && usuario?.id != publicacionOriginal.autorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes editar esta publicacion.')),
      );
      return;
    }
    final tieneFotos =
        _imagenesSeleccionadas.isNotEmpty || fotosExistentes.isNotEmpty;
    if (!tieneFotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos 1 imagen.')),
      );
      return;
    }
    if (_imagenesSeleccionadas.length > 3 || fotosExistentes.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes agregar maximo 3 imagenes.')),
      );
      return;
    }
    final telefono = _telefonoContacto.text.trim();
    if (telefono.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El telefono debe tener exactamente 9 digitos.')),
      );
      return;
    }
    if (_tipo.value == TipoPublicacion.perdido) {
      if (_direccion.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa la direccion aproximada.')),
        );
        return;
      }
      if (_puntoPerdida == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona el punto en el mapa.')),
        );
        return;
      }
    }

    setState(() => _guardando = true);
    try {
      final nombreMascota = _nombreMascota.text.trim();
      final usuarioId =
          publicacionOriginal?.autorId ?? usuario?.id ?? usuariosMock.first.id;
      final fotosSubidas = await _subirFotosSeleccionadas(usuarioId);
      final fotos = fotosSubidas.isNotEmpty ? fotosSubidas : fotosExistentes;
      final descripcion = _descripcion.text.trim();
      final detalleBusqueda = _requisitosAdopcion.text.trim();
      final cuerpo = _tipo.value == TipoPublicacion.perdido &&
              detalleBusqueda.isNotEmpty
          ? descripcion.isEmpty
              ? detalleBusqueda
              : '$descripcion\n\nUltima vez visto: $detalleBusqueda'
          : descripcion;
      final publicacion = ModeloPublicacion(
        id: publicacionOriginal?.id ?? 'post-${DateTime.now().millisecondsSinceEpoch}',
        autorId: usuarioId,
        mascotaId: publicacionOriginal?.mascotaId,
        tipo: _tipo.value,
        estado: EstadoPublicacion.pendienteAprobacion,
        titulo: _titulo.text.isEmpty
            ? nombreMascota.isEmpty
                ? 'Nueva publicacion'
                : 'Publicacion de $nombreMascota'
            : _titulo.text,
        cuerpo: cuerpo,
        nombreMascota: nombreMascota.isEmpty ? null : nombreMascota,
        especieMascota: _especie,
        razaMascota: _razaMascota.text.trim(),
        colorCaracteristicas: _colorCaracteristicas.text.trim(),
        generoMascota: _generoMascota,
        edadMascota: _edadMascota.text.trim(),
        descripcionMascota: descripcion,
        telefonoContacto: telefono,
        gravedad: _tipo.value == TipoPublicacion.rescatado ? _gravedad : null,
        metaApoyo: _tipo.value == TipoPublicacion.rescatado
            ? double.tryParse(_metaApoyo.text)
            : null,
        requisitosAdopcion: _tipo.value == TipoPublicacion.adopcion
            ? _requisitosAdopcion.text.trim()
            : null,
        fotos: fotos,
        latitud: _tipo.value == TipoPublicacion.perdido
            ? _puntoPerdida?.latitude
            : publicacionOriginal?.latitud,
        longitud: _tipo.value == TipoPublicacion.perdido
            ? _puntoPerdida?.longitude
            : publicacionOriginal?.longitud,
        direccion: _tipo.value == TipoPublicacion.perdido
            ? _direccion.text.trim()
            : publicacionOriginal?.direccion ?? 'Lima, Peru',
        creadoEn: publicacionOriginal?.creadoEn ?? DateTime.now(),
        actualizadoEn: DateTime.now(),
      );
      if (publicacionOriginal != null) {
        await ref.read(proveedorPublicaciones.notifier).actualizarPublicacion(publicacion);
      } else {
        await ref.read(proveedorPublicaciones.notifier).crearPublicacion(publicacion);
      }
      if (context.mounted) {
        context.go('${Rutas.publicacionGuardada}/${_tipo.value.toJson()}');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la publicacion: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _tituloTipo(TipoPublicacion tipo) => switch (tipo) {
        TipoPublicacion.adopcion => 'Adopcion',
        TipoPublicacion.rescatado => 'Apoyo',
        TipoPublicacion.perdido => 'Busqueda',
      };

  String _hintDescripcion(TipoPublicacion tipo) => switch (tipo) {
        TipoPublicacion.adopcion => 'Cuenta como es la mascota y que hogar necesita',
        TipoPublicacion.rescatado => 'Explica que apoyo necesita y su estado actual',
        TipoPublicacion.perdido => 'Describe donde se perdio y como reconocerla',
      };

  InputDecoration _decoracionCampo({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFE9E9EA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Future<void> _seleccionarFotos() async {
    final imagenes = await _picker.pickMultiImage(imageQuality: 82);
    if (imagenes.isEmpty) return;
    if (imagenes.length > 3 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se tomaran las primeras 3 imagenes.')),
      );
    }
    setState(() {
      _imagenesSeleccionadas
        ..clear()
        ..addAll(imagenes.take(3));
    });
  }

  Future<List<String>> _subirFotosSeleccionadas(String usuarioId) async {
    if (_imagenesSeleccionadas.isEmpty) return const [];
    final fotos = <FotoPublicacionUpload>[];
    for (final imagen in _imagenesSeleccionadas) {
      final bytes = await imagen.readAsBytes();
      final extension = _extensionDesdeNombre(imagen.name);
      fotos.add(
        FotoPublicacionUpload(
          bytes: bytes,
          extension: extension,
          contentType: _contentType(extension),
        ),
      );
    }
    return ref.read(proveedorRepositorioPublicacion).subirFotosPublicacion(
          usuarioId: usuarioId,
          fotos: fotos,
        );
  }

  String _extensionDesdeNombre(String nombre) {
    final partes = nombre.split('.');
    if (partes.length < 2) return 'jpg';
    final extension = partes.last.toLowerCase();
    return extension == 'png' || extension == 'webp' || extension == 'jpeg'
        ? extension
        : 'jpg';
  }

  String _contentType(String extension) =>
      extension == 'jpg' || extension == 'jpeg' ? 'image/jpeg' : 'image/$extension';
}

class _SelectorTipoPublicacion extends StatelessWidget {
  const _SelectorTipoPublicacion({
    required this.onVolver,
    required this.onSeleccionar,
  });

  final VoidCallback onVolver;
  final ValueChanged<TipoPublicacion> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: onVolver,
          icon: const Icon(Icons.chevron_left),
        ),
        title: const Text('Crear publicacion'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        children: [
          Text(
            'De que trata su\npublicacion?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            'Selecciona el tipo publicacion que desea crear',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF929292),
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 48),
          _OpcionTipoPublicacion(
            titulo: 'ADOPCION',
            descripcion: 'Desea dar en adopcion a una mascota',
            icono: Icons.home_outlined,
            onTap: () => onSeleccionar(TipoPublicacion.adopcion),
          ),
          const SizedBox(height: 16),
          _OpcionTipoPublicacion(
            titulo: 'APOYO',
            descripcion: 'Desea apoyo para una mascota',
            icono: Icons.volunteer_activism,
            onTap: () => onSeleccionar(TipoPublicacion.rescatado),
          ),
          const SizedBox(height: 16),
          _OpcionTipoPublicacion(
            titulo: 'BUSQUEDA',
            descripcion: 'Esta buscando una mascota',
            icono: Icons.manage_search,
            onTap: () => onSeleccionar(TipoPublicacion.perdido),
          ),
        ],
      ),
    );
  }
}

class _OpcionTipoPublicacion extends StatelessWidget {
  const _OpcionTipoPublicacion({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.onTap,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF6C4DF6),
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF8F8F8F),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C4DF6).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icono, color: const Color(0xFF6C4DF6), size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicadorPasos extends StatelessWidget {
  const _IndicadorPasos({required this.pasoActual});

  final int pasoActual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++) ...[
          _CirculoPaso(numero: i + 1, activo: pasoActual == i),
          if (i < 2)
            Container(
              width: 48,
              height: 4,
              color: const Color(0xFFE1E1E1),
            ),
        ],
      ],
    );
  }
}

class _CirculoPaso extends StatelessWidget {
  const _CirculoPaso({required this.numero, required this.activo});

  final int numero;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: activo ? const Color(0xFFC9B8FF) : const Color(0xFFE9E9E9),
      ),
      child: Text(
        '$numero',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CampoFormulario extends StatelessWidget {
  const _CampoFormulario({required this.etiqueta, required this.child});

  final String etiqueta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF8F8F8F),
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SelectorGenero extends StatelessWidget {
  const _SelectorGenero({
    required this.valor,
    required this.onChanged,
  });

  final String valor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _CampoFormulario(
      etiqueta: 'Sexo',
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              value: 'macho',
              groupValue: valor,
              activeColor: const Color(0xFF6C4DF6),
              onChanged: (nuevo) => onChanged(nuevo ?? 'macho'),
              title: const Text('Macho'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              value: 'hembra',
              groupValue: valor,
              activeColor: const Color(0xFF6C4DF6),
              onChanged: (nuevo) => onChanged(nuevo ?? 'hembra'),
              title: const Text('Hembra'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavegacionPasos extends StatelessWidget {
  const _NavegacionPasos({
    required this.pasoActual,
    required this.guardando,
    required this.esEdicion,
    required this.onAtras,
    required this.onContinuar,
  });

  final int pasoActual;
  final bool guardando;
  final bool esEdicion;
  final VoidCallback onAtras;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    final esFinal = pasoActual == 2;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: guardando ? null : onAtras,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Atras'),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: guardando ? null : onContinuar,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C4DF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                guardando
                    ? 'Guardando...'
                    : esFinal
                        ? esEdicion
                            ? 'Guardar'
                            : 'Publicar'
                        : 'Continuar',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectorUbicacionPerdida extends StatelessWidget {
  const _SelectorUbicacionPerdida({
    required this.direccion,
    required this.punto,
    required this.onSeleccionar,
  });

  static const _centroLima = LatLng(-12.0464, -77.0428);

  final TextEditingController direccion;
  final LatLng? punto;
  final ValueChanged<LatLng> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final centro = punto ?? _centroLima;
    return _CampoFormulario(
      etiqueta: 'Direccion y punto aproximado',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: direccion,
            decoration: const InputDecoration(
              hintText: 'Ej. Parque central, Los Olivos',
              filled: true,
              fillColor: Color(0xFFE9E9EA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 230,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: centro,
                  initialZoom: 14,
                  onTap: (_, latLng) => onSeleccionar(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_application_1prueba',
                  ),
                  if (punto != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: punto!,
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF6C4DF6),
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            punto == null
                ? 'Toca el mapa para ubicar donde se perdio.'
                : 'Punto seleccionado: ${punto!.latitude.toStringAsFixed(5)}, ${punto!.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SelectorFotosPublicacion extends StatelessWidget {
  const _SelectorFotosPublicacion({
    required this.imagenesSeleccionadas,
    required this.fotosExistentes,
    required this.onSeleccionar,
    required this.onQuitarSeleccionada,
  });

  final List<XFile> imagenesSeleccionadas;
  final List<String> fotosExistentes;
  final VoidCallback onSeleccionar;
  final ValueChanged<int> onQuitarSeleccionada;

  @override
  Widget build(BuildContext context) {
    final usandoNuevas = imagenesSeleccionadas.isNotEmpty;
    final cantidad = usandoNuevas ? imagenesSeleccionadas.length : fotosExistentes.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fotos de la publicacion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('$cantidad/3'),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Agrega minimo 1 y maximo 3 imagenes.'),
            const SizedBox(height: 12),
            if (cantidad > 0)
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cantidad,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (usandoNuevas) {
                      return _MiniaturaLocal(
                        imagen: imagenesSeleccionadas[index],
                        onQuitar: () => onQuitarSeleccionada(index),
                      );
                    }
                    return _MiniaturaRemota(url: fotosExistentes[index]);
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onSeleccionar,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(cantidad == 0 ? 'Seleccionar imagenes' : 'Cambiar imagenes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniaturaLocal extends StatelessWidget {
  const _MiniaturaLocal({required this.imagen, required this.onQuitar});

  final XFile imagen;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagen.path),
            height: 110,
            width: 110,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            onPressed: onQuitar,
            icon: const Icon(Icons.close),
            iconSize: 16,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _MiniaturaRemota extends StatelessWidget {
  const _MiniaturaRemota({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: 110,
        width: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 110,
          width: 110,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}
