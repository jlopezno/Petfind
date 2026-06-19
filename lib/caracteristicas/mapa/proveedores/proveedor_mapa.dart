// Gestiona publicaciones cercanas para el mapa.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../publicaciones/modelos/modelo_publicacion.dart';
import '../../publicaciones/proveedores/proveedor_publicacion.dart';

final proveedorMapa = AsyncNotifierProvider<ProveedorMapa, List<ModeloPublicacion>>(ProveedorMapa.new);

class ProveedorMapa extends AsyncNotifier<List<ModeloPublicacion>> {
  int radioMetros = 5000;
  TipoPublicacion? filtro;
  double latitud = -12.0464;
  double longitud = -77.0428;

  @override
  Future<List<ModeloPublicacion>> build() async => cargarPublicacionesCercanas(radioMetros);

  Future<List<ModeloPublicacion>> cargarPublicacionesCercanas(int radio) {
    radioMetros = radio;
    return ref.read(proveedorRepositorioPublicacion).cercanas(latitud, longitud, radioMetros, filtro: filtro);
  }

  Future<void> cambiarFiltro(TipoPublicacion? tipo) async {
    filtro = tipo;
    state = await AsyncValue.guard(() => cargarPublicacionesCercanas(radioMetros));
  }

  Future<void> actualizarUbicacion({double? nuevaLatitud, double? nuevaLongitud}) async {
    latitud = nuevaLatitud ?? latitud;
    longitud = nuevaLongitud ?? longitud;
    state = await AsyncValue.guard(() => cargarPublicacionesCercanas(radioMetros));
  }
}
