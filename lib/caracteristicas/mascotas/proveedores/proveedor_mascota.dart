// Expone el CRUD de mascotas del usuario actual.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../autenticacion/proveedores/proveedor_autenticacion.dart';
import '../modelos/modelo_mascota.dart';
import '../modelos/modelo_vacuna.dart';
import '../repositorios/repositorio_mascota.dart';

final proveedorRepositorioMascota = Provider((ref) => const RepositorioMascota());
final proveedorMascotas = AsyncNotifierProvider<ProveedorMascota, List<ModeloMascota>>(ProveedorMascota.new);

final proveedorVacunasMascota = FutureProvider.family<List<ModeloVacuna>, String>((ref, mascotaId) {
  return ref.watch(proveedorRepositorioMascota).obtenerVacunas(mascotaId);
});

class ProveedorMascota extends AsyncNotifier<List<ModeloMascota>> {
  @override
  Future<List<ModeloMascota>> build() async => obtenerMascotas();

  Future<List<ModeloMascota>> obtenerMascotas() async {
    final usuario = ref.watch(proveedorAutenticacion).valueOrNull;
    if (usuario == null) return [];
    return ref.read(proveedorRepositorioMascota).obtenerMascotas(usuario.id);
  }

  Future<void> agregarMascota(ModeloMascota mascota) async {
    await ref.read(proveedorRepositorioMascota).agregarMascota(mascota);
    state = AsyncData([...state.valueOrNull ?? [], mascota]);
  }

  Future<void> actualizarMascota(ModeloMascota mascota) async {
    await ref.read(proveedorRepositorioMascota).actualizarMascota(mascota);
    state = AsyncData([for (final item in state.valueOrNull ?? <ModeloMascota>[]) item.id == mascota.id ? mascota : item]);
  }

  Future<void> eliminarMascota(String id) async {
    await ref.read(proveedorRepositorioMascota).eliminarMascota(id);
    state = AsyncData((state.valueOrNull ?? []).where((m) => m.id != id).toList());
  }
}
