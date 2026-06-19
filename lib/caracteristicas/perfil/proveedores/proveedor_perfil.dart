// Carga y actualiza perfiles de usuario.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/supabase_constantes.dart';
import '../../../compartido/servicios/servicio_supabase.dart';
import '../../autenticacion/modelos/modelo_usuario.dart';
import '../../autenticacion/proveedores/proveedor_autenticacion.dart';

final proveedorPerfil = AsyncNotifierProvider<ProveedorPerfil, ModeloUsuario?>(ProveedorPerfil.new);

class ProveedorPerfil extends AsyncNotifier<ModeloUsuario?> {
  @override
  Future<ModeloUsuario?> build() async => ref.watch(proveedorAutenticacion).valueOrNull;

  Future<void> cargarPerfil(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (usarMock) return usuariosMock.where((u) => u.id == id).firstOrNull;
      final data = await ServicioSupabase.instancia.cliente.from('profiles').select().eq('id', id).maybeSingle();
      return data == null ? null : ModeloUsuario.fromJson(data);
    });
  }

  Future<void> actualizarPerfil(ModeloUsuario perfil) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (!usarMock) await ServicioSupabase.instancia.cliente.from('profiles').update(perfil.toJson()).eq('id', perfil.id);
      return perfil;
    });
  }

  Future<String> subirAvatar() async => 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400';
}
