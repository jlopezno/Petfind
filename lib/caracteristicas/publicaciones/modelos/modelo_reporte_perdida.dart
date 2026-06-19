// Modela datos especializados de reportes de perdida.
class ModeloReportePerdida {
  const ModeloReportePerdida({
    required this.id,
    required this.publicacionId,
    required this.vistoUltimaVezEn,
    this.latitud,
    this.longitud,
    this.direccionUltimaVez,
    this.circunstancias,
    this.recompensa,
    this.telefonoContacto,
    this.resuelto = false,
    this.resueltoEn,
    required this.creadoEn,
  });

  final String id;
  final String publicacionId;
  final DateTime vistoUltimaVezEn;
  final double? latitud;
  final double? longitud;
  final String? direccionUltimaVez;
  final String? circunstancias;
  final double? recompensa;
  final String? telefonoContacto;
  final bool resuelto;
  final DateTime? resueltoEn;
  final DateTime creadoEn;

  factory ModeloReportePerdida.fromJson(Map<String, dynamic> json) => ModeloReportePerdida(
        id: json['id'] as String,
        publicacionId: json['post_id'] as String,
        vistoUltimaVezEn: DateTime.tryParse(json['last_seen_at'] as String? ?? '') ?? DateTime.now(),
        latitud: (json['lat'] as num?)?.toDouble(),
        longitud: (json['lon'] as num?)?.toDouble(),
        direccionUltimaVez: json['last_seen_addr'] as String?,
        circunstancias: json['circumstances'] as String?,
        recompensa: (json['reward'] as num?)?.toDouble(),
        telefonoContacto: json['contact_phone'] as String?,
        resuelto: json['resolved'] as bool? ?? false,
        resueltoEn: DateTime.tryParse(json['resolved_at'] as String? ?? ''),
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': publicacionId,
        'last_seen_at': vistoUltimaVezEn.toIso8601String(),
        'last_seen_addr': direccionUltimaVez,
        'circumstances': circunstancias,
        'reward': recompensa,
        'contact_phone': telefonoContacto,
        'resolved': resuelto,
        'resolved_at': resueltoEn?.toIso8601String(),
        'created_at': creadoEn.toIso8601String(),
      };

  ModeloReportePerdida copyWith({bool? resuelto, DateTime? resueltoEn}) => ModeloReportePerdida(
        id: id,
        publicacionId: publicacionId,
        vistoUltimaVezEn: vistoUltimaVezEn,
        latitud: latitud,
        longitud: longitud,
        direccionUltimaVez: direccionUltimaVez,
        circunstancias: circunstancias,
        recompensa: recompensa,
        telefonoContacto: telefonoContacto,
        resuelto: resuelto ?? this.resuelto,
        resueltoEn: resueltoEn ?? this.resueltoEn,
        creadoEn: creadoEn,
      );
}
