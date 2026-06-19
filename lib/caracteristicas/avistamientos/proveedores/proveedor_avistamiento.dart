// Expone avistamientos por publicacion.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../publicaciones/modelos/modelo_publicacion.dart';
import '../modelos/modelo_avistamiento.dart';
import '../repositorios/repositorio_avistamiento.dart';

final proveedorRepositorioAvistamiento = Provider((ref) => const RepositorioAvistamiento());

final proveedorAvistamientos = AsyncNotifierProvider.family<ProveedorAvistamiento, List<ModeloAvistamiento>, String>(ProveedorAvistamiento.new);

class ProveedorAvistamiento extends FamilyAsyncNotifier<List<ModeloAvistamiento>, String> {
  @override
  Future<List<ModeloAvistamiento>> build(String arg) => cargarAvistamientos(arg);

  Future<List<ModeloAvistamiento>> cargarAvistamientos(String postId) {
    return ref.read(proveedorRepositorioAvistamiento).obtenerPorPublicacion(postId);
  }

  Future<void> reportarAvistamiento(ModeloPublicacion publicacion, ModeloAvistamiento avistamiento) async {
    await ref.read(proveedorRepositorioAvistamiento).reportarAvistamiento(publicacion, avistamiento);
    state = AsyncData([avistamiento, ...state.valueOrNull ?? []]);
  }
}
