// Modela reportes de avistamiento vinculados a publicaciones.
class ModeloAvistamiento {
  const ModeloAvistamiento({
    required this.id,
    required this.publicacionId,
    required this.reportanteId,
    required this.vistoEn,
    required this.latitud,
    required this.longitud,
    this.direccion,
    this.fotoUrl,
    this.notas,
    this.verificado = false,
    required this.creadoEn,
  });

  final String id;
  final String publicacionId;
  final String reportanteId;
  final DateTime vistoEn;
  final double latitud;
  final double longitud;
  final String? direccion;
  final String? fotoUrl;
  final String? notas;
  final bool verificado;
  final DateTime creadoEn;

  factory ModeloAvistamiento.fromJson(Map<String, dynamic> json) => ModeloAvistamiento(
        id: json['id'] as String,
        publicacionId: json['post_id'] as String,
        reportanteId: json['reporter_id'] as String,
        vistoEn: DateTime.tryParse(json['seen_at'] as String? ?? '') ?? DateTime.now(),
        latitud: (json['lat'] as num? ?? 0).toDouble(),
        longitud: (json['lon'] as num? ?? 0).toDouble(),
        direccion: json['address_hint'] as String?,
        fotoUrl: json['photo_url'] as String?,
        notas: json['notes'] as String?,
        verificado: json['verified'] as bool? ?? false,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': publicacionId,
        'reporter_id': reportanteId,
        'seen_at': vistoEn.toIso8601String(),
        'address_hint': direccion,
        'photo_url': fotoUrl,
        'notes': notas,
        'verified': verificado,
        'created_at': creadoEn.toIso8601String(),
      };

  ModeloAvistamiento copyWith({String? notas, bool? verificado}) => ModeloAvistamiento(
        id: id,
        publicacionId: publicacionId,
        reportanteId: reportanteId,
        vistoEn: vistoEn,
        latitud: latitud,
        longitud: longitud,
        direccion: direccion,
        fotoUrl: fotoUrl,
        notas: notas ?? this.notas,
        verificado: verificado ?? this.verificado,
        creadoEn: creadoEn,
      );
}
