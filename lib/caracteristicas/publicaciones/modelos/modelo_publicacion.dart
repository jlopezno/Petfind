// Modela publicaciones del feed unificado con aprobacion y datos de mascota.
import 'dart:typed_data';

import '../../mascotas/modelos/modelo_mascota.dart';

enum TipoPublicacion {
  perdido,
  rescatado,
  adopcion;

  static TipoPublicacion fromString(String valor) => switch (valor) {
        'lost' => perdido,
        'rescued' => rescatado,
        'adoption' => adopcion,
        _ => perdido,
      };

  String toJson() => switch (this) {
        perdido => 'lost',
        rescatado => 'rescued',
        adopcion => 'adoption',
      };

  String get etiqueta => switch (this) {
        perdido => 'Mascota perdida',
        rescatado => 'Rescatado',
        adopcion => 'En adopcion',
      };
}

enum EstadoPublicacion {
  pendienteAprobacion,
  activo,
  observado,
  rechazado,
  resuelto,
  cerrado,
  eliminado;

  static EstadoPublicacion fromString(String valor) => switch (valor) {
        'active' => activo,
        'observed' => observado,
        'rejected' => rechazado,
        'resolved' => resuelto,
        'closed' => cerrado,
        'deleted' => eliminado,
        _ => pendienteAprobacion,
      };

  String toJson() => switch (this) {
        pendienteAprobacion => 'pending_approval',
        activo => 'active',
        observado => 'observed',
        rechazado => 'rejected',
        resuelto => 'resolved',
        cerrado => 'closed',
        eliminado => 'deleted',
      };

  String get etiqueta => switch (this) {
        pendienteAprobacion => 'En revision',
        activo => 'Activo',
        observado => 'Observado',
        rechazado => 'Rechazado',
        resuelto => 'Resuelto',
        cerrado => 'Cerrado',
        eliminado => 'Eliminado',
      };
}

enum GravedadCaso {
  leve,
  moderado,
  urgente;

  static GravedadCaso fromString(String valor) => switch (valor) {
        'moderate' => moderado,
        'urgent' => urgente,
        _ => leve,
      };

  String toJson() => switch (this) {
        leve => 'mild',
        moderado => 'moderate',
        urgente => 'urgent',
      };

  String get etiqueta => switch (this) {
        leve => 'Leve',
        moderado => 'Moderado',
        urgente => 'Urgente',
      };
}

class ModeloPublicacion {
  const ModeloPublicacion({
    required this.id,
    required this.autorId,
    this.mascotaId,
    required this.tipo,
    this.estado = EstadoPublicacion.pendienteAprobacion,
    required this.titulo,
    this.cuerpo,
    this.fotos = const [],
    this.latitud,
    this.longitud,
    this.direccion,
    this.distanciaMetros,
    this.nombreMascota,
    this.especieMascota,
    this.razaMascota,
    this.colorCaracteristicas,
    this.tamanioMascota,
    this.generoMascota,
    this.edadMascota,
    this.descripcionMascota,
    this.telefonoContacto,
    this.gravedad,
    this.metaApoyo,
    this.requisitosAdopcion,
    this.notaAdmin,
    this.revisadoEn,
    this.revisadoPor,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final String autorId;
  final String? mascotaId;
  final TipoPublicacion tipo;
  final EstadoPublicacion estado;
  final String titulo;
  final String? cuerpo;
  final List<String> fotos;
  final double? latitud;
  final double? longitud;
  final String? direccion;
  final double? distanciaMetros;
  final String? nombreMascota;
  final EspecieMascota? especieMascota;
  final String? razaMascota;
  final String? colorCaracteristicas;
  final TamanioMascota? tamanioMascota;
  final String? generoMascota;
  final String? edadMascota;
  final String? descripcionMascota;
  final String? telefonoContacto;
  final GravedadCaso? gravedad;
  final double? metaApoyo;
  final String? requisitosAdopcion;
  final String? notaAdmin;
  final DateTime? revisadoEn;
  final String? revisadoPor;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory ModeloPublicacion.fromJson(Map<String, dynamic> json) =>
      ModeloPublicacion(
        id: json['id'] as String,
        autorId: json['author_id'] as String,
        mascotaId: json['pet_id'] as String?,
        tipo: TipoPublicacion.fromString(json['type'] as String? ?? 'lost'),
        estado: EstadoPublicacion.fromString(
          json['status'] as String? ?? 'pending_approval',
        ),
        titulo: json['title'] as String? ?? '',
        cuerpo: json['body'] as String?,
        fotos: List<String>.from(json['photos'] as List? ?? const []),
        latitud: (json['lat'] as num?)?.toDouble() ??
            _latitudDesdeLocation(json['location']),
        longitud: (json['lon'] as num?)?.toDouble() ??
            _longitudDesdeLocation(json['location']),
        direccion: json['address_hint'] as String?,
        distanciaMetros: (json['distance_m'] as num?)?.toDouble(),
        nombreMascota: json['pet_name'] as String?,
        especieMascota:
            json['pet_species'] == null
                ? null
                : EspecieMascota.fromString(json['pet_species'] as String),
        razaMascota: json['pet_breed'] as String?,
        colorCaracteristicas: json['pet_color_features'] as String?,
        tamanioMascota:
            json['pet_size'] == null
                ? null
                : TamanioMascota.fromString(json['pet_size'] as String),
        generoMascota: _generoDesdeJson(json['pet_gender'] as String?),
        edadMascota: json['pet_age_text'] as String?,
        descripcionMascota: json['pet_description'] as String?,
        telefonoContacto: json['contact_phone'] as String?,
        gravedad:
            json['severity'] == null
                ? null
                : GravedadCaso.fromString(json['severity'] as String),
        metaApoyo: (json['sponsor_goal'] as num?)?.toDouble(),
        requisitosAdopcion: json['adoption_requirements'] as String?,
        notaAdmin: json['admin_note'] as String?,
        revisadoEn: DateTime.tryParse(json['reviewed_at'] as String? ?? ''),
        revisadoPor: json['reviewed_by'] as String?,
        creadoEn:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        actualizadoEn:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_id': autorId,
        'pet_id': mascotaId,
        'type': tipo.toJson(),
        'status': estado.toJson(),
        'title': titulo,
        'body': cuerpo,
        'photos': fotos,
        'location': latitud == null || longitud == null
            ? null
            : 'SRID=4326;POINT($longitud $latitud)',
        'address_hint': direccion,
        'pet_name': nombreMascota,
        'pet_species': especieMascota?.toJson(),
        'pet_breed': razaMascota,
        'pet_color_features': colorCaracteristicas,
        'pet_size': tamanioMascota?.toJson(),
        'pet_gender': _generoAJson(generoMascota),
        'pet_age_text': edadMascota,
        'pet_description': descripcionMascota,
        'contact_phone': telefonoContacto,
        'severity': gravedad?.toJson(),
        'sponsor_goal': metaApoyo,
        'adoption_requirements': requisitosAdopcion,
        'admin_note': notaAdmin,
        'reviewed_at': revisadoEn?.toIso8601String(),
        'reviewed_by': revisadoPor,
        'created_at': creadoEn.toIso8601String(),
        'updated_at': actualizadoEn.toIso8601String(),
      };

  static String? _generoDesdeJson(String? valor) => switch (valor) {
        'M' => 'macho',
        'F' => 'hembra',
        _ => valor,
      };

  static String? _generoAJson(String? valor) => switch (valor) {
        'macho' => 'M',
        'hembra' => 'F',
        'M' => 'M',
        'F' => 'F',
        _ => null,
      };

  static double? _latitudDesdeLocation(dynamic location) {
    final coordenadas = _coordenadasDesdeLocation(location);
    return coordenadas == null ? null : coordenadas.$2;
  }

  static double? _longitudDesdeLocation(dynamic location) {
    final coordenadas = _coordenadasDesdeLocation(location);
    return coordenadas == null ? null : coordenadas.$1;
  }

  static (double, double)? _coordenadasDesdeLocation(dynamic location) {
    if (location is Map && location['coordinates'] is List) {
      final coords = location['coordinates'] as List;
      if (coords.length >= 2) {
        return ((coords[0] as num).toDouble(), (coords[1] as num).toDouble());
      }
    }
    if (location is String) {
      final match = RegExp(r'POINT\s*\(([-0-9.]+)\s+([-0-9.]+)\)')
          .firstMatch(location);
      if (match != null) {
        return (double.parse(match.group(1)!), double.parse(match.group(2)!));
      }
      final wkb = _coordenadasDesdeWkb(location);
      if (wkb != null) return wkb;
    }
    return null;
  }

  static (double, double)? _coordenadasDesdeWkb(String hex) {
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex) || hex.length < 42) {
      return null;
    }
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final endian = data.getUint8(0) == 1 ? Endian.little : Endian.big;
    final tipo = data.getUint32(1, endian);
    var offset = 5;
    if ((tipo & 0x20000000) != 0) offset += 4;
    if (bytes.length < offset + 16) return null;
    return (data.getFloat64(offset, endian), data.getFloat64(offset + 8, endian));
  }

  ModeloPublicacion copyWith({
    EstadoPublicacion? estado,
    String? titulo,
    String? cuerpo,
    String? notaAdmin,
  }) =>
      ModeloPublicacion(
        id: id,
        autorId: autorId,
        mascotaId: mascotaId,
        tipo: tipo,
        estado: estado ?? this.estado,
        titulo: titulo ?? this.titulo,
        cuerpo: cuerpo ?? this.cuerpo,
        fotos: fotos,
        latitud: latitud,
        longitud: longitud,
        direccion: direccion,
        distanciaMetros: distanciaMetros,
        nombreMascota: nombreMascota,
        especieMascota: especieMascota,
        razaMascota: razaMascota,
        colorCaracteristicas: colorCaracteristicas,
        tamanioMascota: tamanioMascota,
        generoMascota: generoMascota,
        edadMascota: edadMascota,
        descripcionMascota: descripcionMascota,
        telefonoContacto: telefonoContacto,
        gravedad: gravedad,
        metaApoyo: metaApoyo,
        requisitosAdopcion: requisitosAdopcion,
        notaAdmin: notaAdmin ?? this.notaAdmin,
        revisadoEn: revisadoEn,
        revisadoPor: revisadoPor,
        creadoEn: creadoEn,
        actualizadoEn: DateTime.now(),
      );
}
