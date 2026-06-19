// Repositorio para reportes de avistamientos.
import '../../../compartido/servicios/servicio_supabase.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/supabase_constantes.dart';
import '../../publicaciones/modelos/modelo_publicacion.dart';
import '../modelos/modelo_avistamiento.dart';

class RepositorioAvistamiento {
  const RepositorioAvistamiento();

  Future<List<ModeloAvistamiento>> obtenerPorPublicacion(String publicacionId) async {
    if (usarMock) return avistamientosMock.where((a) => a.publicacionId == publicacionId).toList();
    final data = await ServicioSupabase.instancia.cliente.from('sightings').select().eq('post_id', publicacionId);
    return data.map<ModeloAvistamiento>((json) => ModeloAvistamiento.fromJson(json)).toList();
  }

  Future<void> reportarAvistamiento(ModeloPublicacion publicacion, ModeloAvistamiento avistamiento) async {
    if (publicacion.tipo != TipoPublicacion.perdido || publicacion.estado != EstadoPublicacion.activo) {
      throw StateError('Solo se pueden reportar avistamientos en publicaciones perdidas activas');
    }
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.from('sightings').insert(avistamiento.toJson());
  }
}
