// Maneja sesion y registro de usuarios.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../compartido/servicios/servicio_notificaciones_push.dart';
import '../../../compartido/servicios/servicio_supabase.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/supabase_constantes.dart';
import '../modelos/modelo_usuario.dart';

final proveedorAutenticacion =
    AsyncNotifierProvider<ProveedorAutenticacion, ModeloUsuario?>(
        ProveedorAutenticacion.new);

class ProveedorAutenticacion extends AsyncNotifier<ModeloUsuario?> {
  @override
  Future<ModeloUsuario?> build() async {
    if (usarMock || !credencialesSupabaseConfiguradas) {
      return null;
    }
    final usuario = ServicioSupabase.instancia.cliente.auth.currentUser;
    if (usuario == null) return null;
    final perfil = await ServicioSupabase.instancia.cliente
        .from('profiles')
        .select()
        .eq('id', usuario.id)
        .maybeSingle();
    if (perfil != null) {
      final usuarioPerfil = ModeloUsuario.fromJson(perfil);
      await ServicioNotificacionesPush.instancia
          .registrarTokenUsuario(usuarioPerfil.id);
      return usuarioPerfil;
    }

    final metadatos = usuario.userMetadata ?? <String, dynamic>{};
    final ahora = DateTime.now();
    final usuarioPerfil = ModeloUsuario(
      id: usuario.id,
      rol: RolUsuario.fromString(metadatos['role'] as String? ?? 'owner'),
      nombreCompleto:
          metadatos['full_name'] as String? ?? usuario.email ?? 'Usuario',
      nombreRefugio: metadatos['shelter_name'] as String?,
      rucRefugio: metadatos['shelter_ruc'] as String?,
      creadoEn: ahora,
      actualizadoEn: ahora,
    );
    await ServicioNotificacionesPush.instancia
        .registrarTokenUsuario(usuarioPerfil.id);
    return usuarioPerfil;
  }

  Future<void> iniciarSesion(String correo, String contrasenia) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (usarMock) {
        return usuariosMock.first;
      }
      if (!credencialesSupabaseConfiguradas) {
        throw const AuthException(
          'Configura SUPABASE_URL y SUPABASE_ANON_KEY para iniciar sesion.',
        );
      }
      await ServicioSupabase.instancia.cliente.auth
          .signInWithPassword(email: correo, password: contrasenia);
      return build();
    });
  }

  Future<void> registrar({
    required String nombreCompleto,
    required String correo,
    required String contrasenia,
    required RolUsuario rol,
    String? nombreRefugio,
    String? rucRefugio,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (usarMock) {
        return usuariosMock.first
            .copyWith(nombreCompleto: nombreCompleto, rol: rol);
      }
      if (!credencialesSupabaseConfiguradas) {
        throw const AuthException(
          'Configura SUPABASE_URL y SUPABASE_ANON_KEY para registrarte.',
        );
      }
      await ServicioSupabase.instancia.cliente.auth.signUp(
        email: correo,
        password: contrasenia,
        data: {
          'full_name': nombreCompleto,
          'role': rol.toJson(),
          'shelter_name': nombreRefugio,
          'shelter_ruc': rucRefugio
        },
      );
      return build();
    });
  }

  Future<void> cerrarSesion() async {
    if (!usarMock) {
      await ServicioSupabase.instancia.cliente.auth
          .signOut(scope: SignOutScope.local);
    }
    state = const AsyncData(null);
  }

  Future<void> actualizarAvatar({
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    final perfil = state.valueOrNull;
    if (perfil == null) {
      throw StateError('No se encontro el perfil del usuario.');
    }
    if (usarMock) return;

    final storage = ServicioSupabase.instancia.cliente.storage.from('avatares');
    final path = '${perfil.id}/avatar-${DateTime.now().millisecondsSinceEpoch}.$extension';
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        cacheControl: '3600',
        contentType: contentType,
      ),
    );
    final url = storage.getPublicUrl(path);
    await ServicioSupabase.instancia.cliente
        .from('profiles')
        .update({'avatar_url': url}).eq('id', perfil.id);
    state = AsyncData(
      perfil.copyWith(avatarUrl: url, actualizadoEn: DateTime.now()),
    );
  }
}
