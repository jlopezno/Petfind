// Modela solicitudes de adopcion.
enum EstadoAdopcion {
  pendiente,
  aprobado,
  rechazado,
  completado;

  static EstadoAdopcion fromString(String valor) => switch (valor) {
        'approved' => aprobado,
        'rejected' => rechazado,
        'completed' => completado,
        _ => pendiente,
      };

  String toJson() => switch (this) {
        pendiente => 'pending',
        aprobado => 'approved',
        rechazado => 'rejected',
        completado => 'completed',
      };
}

class ModeloAdopcion {
  const ModeloAdopcion({
    required this.id,
    required this.publicacionId,
    required this.solicitanteId,
    required this.refugioId,
    this.estado = EstadoAdopcion.pendiente,
    this.mensaje,
    this.notaRechazo,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final String publicacionId;
  final String solicitanteId;
  final String refugioId;
  final EstadoAdopcion estado;
  final String? mensaje;
  final String? notaRechazo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory ModeloAdopcion.fromJson(Map<String, dynamic> json) => ModeloAdopcion(
        id: json['id'] as String,
        publicacionId: json['post_id'] as String,
        solicitanteId: json['applicant_id'] as String,
        refugioId: json['shelter_id'] as String,
        estado: EstadoAdopcion.fromString(json['status'] as String? ?? 'pending'),
        mensaje: json['message'] as String?,
        notaRechazo: json['rejection_note'] as String?,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        actualizadoEn: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': publicacionId,
        'applicant_id': solicitanteId,
        'shelter_id': refugioId,
        'status': estado.toJson(),
        'message': mensaje,
        'rejection_note': notaRechazo,
        'created_at': creadoEn.toIso8601String(),
        'updated_at': actualizadoEn.toIso8601String(),
      };

  ModeloAdopcion copyWith({EstadoAdopcion? estado}) => ModeloAdopcion(
        id: id,
        publicacionId: publicacionId,
        solicitanteId: solicitanteId,
        refugioId: refugioId,
        estado: estado ?? this.estado,
        mensaje: mensaje,
        notaRechazo: notaRechazo,
        creadoEn: creadoEn,
        actualizadoEn: DateTime.now(),
      );
}
