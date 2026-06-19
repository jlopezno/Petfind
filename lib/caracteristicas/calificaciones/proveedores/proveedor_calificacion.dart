// Coordina calificaciones de usuarios.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/modelo_calificacion.dart';
import '../repositorios/repositorio_calificacion.dart';

final proveedorRepositorioCalificacion = Provider((ref) => const RepositorioCalificacion());

final proveedorCalificacion = AsyncNotifierProvider.family<ProveedorCalificacion, List<ModeloCalificacion>, String>(ProveedorCalificacion.new);

class ProveedorCalificacion extends FamilyAsyncNotifier<List<ModeloCalificacion>, String> {
  @override
  Future<List<ModeloCalificacion>> build(String arg) => obtenerCalificacion(arg);

  Future<List<ModeloCalificacion>> obtenerCalificacion(String objetivoId) {
    return ref.read(proveedorRepositorioCalificacion).obtenerCalificaciones(objetivoId);
  }

  Future<void> calificar(ModeloCalificacion calificacion) async {
    final duplicado = (state.valueOrNull ?? []).any((c) =>
        c.evaluadorId == calificacion.evaluadorId &&
        c.objetivoId == calificacion.objetivoId &&
        c.tipoObjetivo == calificacion.tipoObjetivo &&
        c.contextoId == calificacion.contextoId);
    if (duplicado) throw StateError('Ya calificaste este contexto');
    await ref.read(proveedorRepositorioCalificacion).calificar(calificacion);
    state = AsyncData([calificacion, ...state.valueOrNull ?? []]);
  }
}
