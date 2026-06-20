// Controla lista paginada de publicaciones.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/servicios/servicio_notificaciones_push.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../modelos/modelo_publicacion.dart';
import '../repositorios/repositorio_publicacion.dart';

final proveedorRepositorioPublicacion = Provider((ref) => const RepositorioPublicacion());
final proveedorPublicaciones = AsyncNotifierProvider<ProveedorPublicaciones, List<ModeloPublicacion>>(ProveedorPublicaciones.new);
final proveedorPublicacionesRevisionAdmin = FutureProvider<List<ModeloPublicacion>>((ref) {
  return ref.watch(proveedorRepositorioPublicacion).obtenerPendientesRevisionAdmin();
});
final proveedorAdopciones =
    AsyncNotifierProvider<ProveedorAdopciones, List<ModeloPublicacion>>(
  ProveedorAdopciones.new,
);

final proveedorDetallePublicacion = FutureProvider.family<ModeloPublicacion?, String>((ref, id) {
  return ref.watch(proveedorRepositorioPublicacion).obtenerPorId(id);
});

final proveedorSolicitudesAdopcion =
    FutureProvider.family<List<ModeloSolicitudAdopcion>, String>((ref, id) {
  return ref.watch(proveedorRepositorioPublicacion).obtenerSolicitudesAdopcion(id);
});

class ProveedorPublicaciones extends AsyncNotifier<List<ModeloPublicacion>> {
  TipoPublicacion? filtro;
  int _pagina = 0;

  @override
  Future<List<ModeloPublicacion>> build() async {
    await ref.watch(proveedorAutenticacion.future);
    return ref.read(proveedorRepositorioPublicacion).obtenerPublicaciones(filtro: filtro);
  }

  Future<void> cambiarFiltro(TipoPublicacion? nuevoFiltro) async {
    filtro = nuevoFiltro;
    await refrescar();
  }

  Future<void> refrescar() async {
    _pagina = 0;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(proveedorRepositorioPublicacion).obtenerPublicaciones(filtro: filtro));
  }

  Future<void> cargarMas() async {
    final actuales = state.valueOrNull ?? [];
    _pagina++;
    final nuevos = await ref.read(proveedorRepositorioPublicacion).obtenerPublicaciones(filtro: filtro, pagina: _pagina);
    state = AsyncData([...actuales, ...nuevos]);
  }

  Future<void> crearPublicacion(ModeloPublicacion publicacion) async {
    final publicacionCreada =
        await ref.read(proveedorRepositorioPublicacion).crearPublicacion(publicacion);
    await ServicioNotificacionesPush.instancia
        .notificarPublicacionCreada(publicacionCreada.id);
    state = AsyncData([publicacionCreada, ...state.valueOrNull ?? []]);
  }

  Future<void> actualizarPublicacion(ModeloPublicacion publicacion) async {
    await ref.read(proveedorRepositorioPublicacion).actualizarPublicacion(publicacion);
    state = AsyncData([
      for (final item in state.valueOrNull ?? <ModeloPublicacion>[])
        item.id == publicacion.id ? publicacion : item,
    ]);
    ref.invalidate(proveedorDetallePublicacion(publicacion.id));
    ref.invalidate(proveedorPublicacionesRevisionAdmin);
    await refrescar();
  }

  Future<void> cerrarPublicacion(String id, {bool resuelto = false}) async {
    await ref.read(proveedorRepositorioPublicacion).cerrarPublicacion(id, resuelto: resuelto);
    final estadoFinal = resuelto ? EstadoPublicacion.resuelto : EstadoPublicacion.cerrado;
    state = AsyncData([
      for (final publicacion in state.valueOrNull ?? <ModeloPublicacion>[])
        publicacion.id == id ? publicacion.copyWith(estado: estadoFinal) : publicacion,
    ]);
    await refrescar();
  }

  Future<void> aprobarPublicacion(String id) async {
    await ref.read(proveedorRepositorioPublicacion).aprobarPublicacion(id);
    ref.invalidate(proveedorPublicacionesRevisionAdmin);
    await refrescar();
  }

  Future<void> observarPublicacion(String id, String nota) async {
    await ref.read(proveedorRepositorioPublicacion).observarPublicacion(id, nota);
    ref.invalidate(proveedorPublicacionesRevisionAdmin);
    await refrescar();
  }

  Future<void> rechazarPublicacion(String id, String nota) async {
    await ref.read(proveedorRepositorioPublicacion).rechazarPublicacion(id, nota);
    ref.invalidate(proveedorPublicacionesRevisionAdmin);
    await refrescar();
  }
}

class ProveedorAdopciones extends AsyncNotifier<List<ModeloPublicacion>> {
  static const _tamanoPagina = 10;
  int _pagina = 0;
  bool _hayMas = true;
  bool _cargandoMas = false;

  @override
  Future<List<ModeloPublicacion>> build() async {
    await ref.watch(proveedorAutenticacion.future);
    return _cargarPrimeraPagina();
  }

  Future<List<ModeloPublicacion>> _cargarPrimeraPagina() async {
    _pagina = 0;
    _hayMas = true;
    final primeras = await ref
        .read(proveedorRepositorioPublicacion)
        .obtenerAdopciones(limite: _tamanoPagina);
    _hayMas = primeras.length == _tamanoPagina;
    return primeras;
  }

  Future<void> cargarMas() async {
    if (_cargandoMas || !_hayMas) return;
    _cargandoMas = true;
    try {
      final siguientes = await ref
          .read(proveedorRepositorioPublicacion)
          .obtenerAdopciones(pagina: _pagina + 1, limite: _tamanoPagina);
      _pagina++;
      _hayMas = siguientes.length == _tamanoPagina;
      if (siguientes.isNotEmpty) {
        state = AsyncData([...state.valueOrNull ?? [], ...siguientes]);
      }
    } finally {
      _cargandoMas = false;
    }
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_cargarPrimeraPagina);
  }
}
