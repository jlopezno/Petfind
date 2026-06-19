// Repositorio para publicaciones y consultas geograficas.
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../compartido/servicios/servicio_supabase.dart';
import '../../../nucleo/constantes/mock_data.dart';
import '../../../nucleo/constantes/supabase_constantes.dart';
import '../../autenticacion/modelos/modelo_usuario.dart';
import '../modelos/modelo_publicacion.dart';

class FotoPublicacionUpload {
  const FotoPublicacionUpload({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
}

class RepositorioPublicacion {
  const RepositorioPublicacion();

  Future<List<ModeloPublicacion>> obtenerPublicaciones({TipoPublicacion? filtro, int pagina = 0, int limite = 20}) async {
    if (usarMock) {
      final lista = publicacionesMock.where((p) => filtro == null || p.tipo == filtro).toList()
        ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
      return lista.skip(pagina * limite).take(limite).toList();
    }
    final usuarioId = ServicioSupabase.instancia.cliente.auth.currentUser?.id;
    if (usuarioId == null) {
      var consulta = ServicioSupabase.instancia.cliente.from('posts').select().eq('status', 'active');
      if (filtro != null) consulta = consulta.eq('type', filtro.toJson());
      final data = await consulta.order('created_at', ascending: false).range(pagina * limite, (pagina + 1) * limite - 1);
      return data.map<ModeloPublicacion>((json) => ModeloPublicacion.fromJson(json)).toList();
    }

    var consultaActivas = ServicioSupabase.instancia.cliente.from('posts').select().eq('status', 'active');
    var consultaPropias = ServicioSupabase.instancia.cliente.from('posts').select().eq('author_id', usuarioId).neq('status', 'active');
    if (filtro != null) {
      consultaActivas = consultaActivas.eq('type', filtro.toJson());
      consultaPropias = consultaPropias.eq('type', filtro.toJson());
    }

    final activas = await consultaActivas.order('created_at', ascending: false).range(pagina * limite, (pagina + 1) * limite - 1);
    final propias = pagina == 0 ? await consultaPropias.order('created_at', ascending: false) : <Map<String, dynamic>>[];
    final porId = <String, ModeloPublicacion>{};
    for (final json in [...activas, ...propias]) {
      final publicacion = ModeloPublicacion.fromJson(Map<String, dynamic>.from(json as Map));
      porId[publicacion.id] = publicacion;
    }
    final lista = porId.values.toList()
      ..sort((a, b) {
        final prioridadA = a.autorId == usuarioId && a.estado != EstadoPublicacion.activo ? 0 : 1;
        final prioridadB = b.autorId == usuarioId && b.estado != EstadoPublicacion.activo ? 0 : 1;
        if (prioridadA != prioridadB) return prioridadA.compareTo(prioridadB);
        return b.creadoEn.compareTo(a.creadoEn);
      });
    return lista;
  }

  Future<List<ModeloPublicacion>> cercanas(double latitud, double longitud, int radio, {TipoPublicacion? filtro}) async {
    if (usarMock) return obtenerPublicaciones(filtro: filtro);
    final data = await ServicioSupabase.instancia.cliente.rpc('posts_near_location', params: {
      'lon': longitud,
      'lat': latitud,
      'radius_m': radio,
      'filter_type': filtro?.toJson(),
    });
    return (data as List).map((json) => ModeloPublicacion.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<ModeloPublicacion?> obtenerPorId(String id) async {
    if (usarMock) return publicacionesMock.where((p) => p.id == id).firstOrNull;
    final data = await ServicioSupabase.instancia.cliente.from('posts').select().eq('id', id).maybeSingle();
    return data == null ? null : ModeloPublicacion.fromJson(data);
  }

  Future<List<ModeloPublicacion>> obtenerPendientesRevisionAdmin() async {
    const estadosRevision = [
      'pending_approval',
      'observed',
      'rejected',
    ];
    if (usarMock) {
      return publicacionesMock
          .where((p) => estadosRevision.contains(p.estado.toJson()))
          .toList()
        ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
    }
    final data = await ServicioSupabase.instancia.cliente
        .from('posts')
        .select()
        .or('status.eq.pending_approval,status.eq.observed,status.eq.rejected')
        .order('created_at', ascending: false);
    return data.map<ModeloPublicacion>((json) => ModeloPublicacion.fromJson(json)).toList();
  }

  Future<ModeloPublicacion> crearPublicacion(ModeloPublicacion publicacion) async {
    if (usarMock) return publicacion;
    final datos = publicacion.toJson()..remove('id');
    final data = await ServicioSupabase.instancia.cliente
        .from('posts')
        .insert(datos)
        .select()
        .single();
    return ModeloPublicacion.fromJson(data);
  }

  Future<List<String>> subirFotosPublicacion({
    required String usuarioId,
    required List<FotoPublicacionUpload> fotos,
  }) async {
    if (usarMock || fotos.isEmpty) return const [];

    final storage = ServicioSupabase.instancia.cliente.storage.from('fotos-publicaciones');
    final urls = <String>[];
    final marcaTiempo = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < fotos.length; i++) {
      final foto = fotos[i];
      final path = '$usuarioId/$marcaTiempo-$i.${foto.extension}';
      await storage.uploadBinary(
        path,
        foto.bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          contentType: foto.contentType,
          upsert: false,
        ),
      );
      urls.add(storage.getPublicUrl(path));
    }

    return urls;
  }

  Future<void> actualizarPublicacion(ModeloPublicacion publicacion) async {
    if (usarMock) return;
    final datos = publicacion.toJson()
      ..remove('id')
      ..remove('author_id')
      ..remove('created_at');
    await ServicioSupabase.instancia.cliente
        .from('posts')
        .update(datos)
        .eq('id', publicacion.id);
  }

  Future<void> cerrarPublicacion(String id, {bool resuelto = false}) async {
    if (usarMock) return;
    if (resuelto) {
      await ServicioSupabase.instancia.cliente.rpc('resolve_own_post', params: {'post_id': id});
      return;
    }
    await ServicioSupabase.instancia.cliente.rpc('close_own_post', params: {'post_id': id});
  }

  Future<void> aprobarPublicacion(String id) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.rpc('approve_post', params: {'post_id': id});
  }

  Future<void> observarPublicacion(String id, String nota) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.rpc('observe_post', params: {'post_id': id, 'note': nota});
  }

  Future<void> rechazarPublicacion(String id, String nota) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.rpc('reject_post', params: {'post_id': id, 'note': nota});
  }

  Future<void> crearSolicitudAdopcion(String publicacionId, {String? mensaje}) async {
    if (usarMock) return;
    await ServicioSupabase.instancia.cliente.rpc(
      'create_adoption_request',
      params: {
        'post_id': publicacionId,
        'message': mensaje,
      },
    );
  }

  Future<List<ModeloSolicitudAdopcion>> obtenerSolicitudesAdopcion(String publicacionId) async {
    if (usarMock) return const [];
    final solicitudes = await ServicioSupabase.instancia.cliente
        .from('adoptions')
        .select()
        .eq('post_id', publicacionId)
        .order('created_at', ascending: false);
    final ids = solicitudes
        .map<String>((json) => json['applicant_id'] as String)
        .toSet()
        .toList();
    if (ids.isEmpty) return const [];

    final perfiles = await ServicioSupabase.instancia.cliente
        .from('profiles')
        .select()
        .inFilter('id', ids);
    final perfilesPorId = {
      for (final perfil in perfiles)
        perfil['id'] as String: ModeloUsuario.fromJson(perfil),
    };

    return solicitudes
        .map<ModeloSolicitudAdopcion>(
          (json) => ModeloSolicitudAdopcion(
            id: json['id'] as String,
            estado: json['status'] as String? ?? 'pending',
            mensaje: json['message'] as String?,
            creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
            solicitante: perfilesPorId[json['applicant_id'] as String],
          ),
        )
        .where((solicitud) => solicitud.solicitante != null)
        .toList();
  }
}

class ModeloSolicitudAdopcion {
  const ModeloSolicitudAdopcion({
    required this.id,
    required this.estado,
    required this.creadoEn,
    this.mensaje,
    this.solicitante,
  });

  final String id;
  final String estado;
  final DateTime creadoEn;
  final String? mensaje;
  final ModeloUsuario? solicitante;
}
