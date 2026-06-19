// Repositorio para CRUD de mascotas y vacunas.
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/supabase_constantes.dart';
import '../../../compartido/servicios/servicio_supabase.dart';
import '../modelos/modelo_mascota.dart';
import '../modelos/modelo_vacuna.dart';

class RepositorioMascota {
  const RepositorioMascota();

  Future<List<ModeloMascota>> obtenerMascotas(String usuarioId) async {
    if (usarMock) return mascotasMock.where((m) => m.duenoId == usuarioId).toList();
    final data = await ServicioSupabase.instancia.cliente.from('pets').select().eq('owner_id', usuarioId);
    return data.map<ModeloMascota>((json) => ModeloMascota.fromJson(json)).toList();
  }

  Future<ModeloMascota?> obtenerPorId(String id) async {
    if (usarMock) return mascotasMock.where((m) => m.id == id).firstOrNull;
    final data = await ServicioSupabase.instancia.cliente.from('pets').select().eq('id', id).maybeSingle();
    return data == null ? null : ModeloMascota.fromJson(data);
  }

  Future<List<ModeloVacuna>> obtenerVacunas(String mascotaId) async {
    if (usarMock) return vacunasMock.where((v) => v.mascotaId == mascotaId).toList();
    final data = await ServicioSupabase.instancia.cliente.from('vaccines').select().eq('pet_id', mascotaId);
    return data.map<ModeloVacuna>((json) => ModeloVacuna.fromJson(json)).toList();
  }

  Future<void> agregarMascota(ModeloMascota mascota) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.from('pets').insert(mascota.toJson());
  }

  Future<void> actualizarMascota(ModeloMascota mascota) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.from('pets').update(mascota.toJson()).eq('id', mascota.id);
  }

  Future<void> eliminarMascota(String id) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.from('pets').delete().eq('id', id);
  }
}
