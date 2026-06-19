// Repositorio para ratings thumbs up y thumbs down.
import '../../../compartido/servicios/servicio_supabase.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/supabase_constantes.dart';
import '../modelos/modelo_calificacion.dart';

class RepositorioCalificacion {
  const RepositorioCalificacion();

  Future<List<ModeloCalificacion>> obtenerCalificaciones(String objetivoId) async {
    if (usarMock) return calificacionesMock.where((c) => c.objetivoId == objetivoId).toList();
    final data = await ServicioSupabase.instancia.cliente.from('ratings').select().eq('target_id', objetivoId);
    return data.map<ModeloCalificacion>((json) => ModeloCalificacion.fromJson(json)).toList();
  }

  Future<void> calificar(ModeloCalificacion calificacion) async {
    if (calificacion.evaluadorId == calificacion.objetivoId) {
      throw StateError('No puedes calificarte a ti mismo');
    }
    if (calificacion.valor != 1 && calificacion.valor != -1) {
      throw StateError('La calificacion debe ser positiva o negativa');
    }
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.from('ratings').insert(calificacion.toJson());
  }
}
