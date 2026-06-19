// Modela calificaciones positivas o negativas entre usuarios.
enum TipoCalificacion {
  publicador,
  refugio,
  reportante,
  adoptante;

  static TipoCalificacion fromString(String valor) => switch (valor) {
        'shelter' => refugio,
        'reporter' => reportante,
        'adopter' => adoptante,
        _ => publicador,
      };

  String toJson() => switch (this) {
        publicador => 'publisher',
        refugio => 'shelter',
        reportante => 'reporter',
        adoptante => 'adopter',
      };
}

class ModeloCalificacion {
  const ModeloCalificacion({
    required this.id,
    required this.evaluadorId,
    required this.objetivoId,
    required this.tipoObjetivo,
    required this.valor,
    this.comentario,
    this.contextoId,
    required this.creadoEn,
  });

  final String id;
  final String evaluadorId;
  final String objetivoId;
  final TipoCalificacion tipoObjetivo;
  final int valor;
  final String? comentario;
  final String? contextoId;
  final DateTime creadoEn;

  factory ModeloCalificacion.fromJson(Map<String, dynamic> json) => ModeloCalificacion(
        id: json['id'] as String,
        evaluadorId: json['reviewer_id'] as String,
        objetivoId: json['target_id'] as String,
        tipoObjetivo: TipoCalificacion.fromString(json['target_type'] as String? ?? 'publisher'),
        valor: json['value'] as int? ?? 1,
        comentario: json['comment'] as String?,
        contextoId: json['context_id'] as String?,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reviewer_id': evaluadorId,
        'target_id': objetivoId,
        'target_type': tipoObjetivo.toJson(),
        'value': valor,
        'comment': comentario,
        'context_id': contextoId,
        'created_at': creadoEn.toIso8601String(),
      };

  ModeloCalificacion copyWith({int? valor, String? comentario}) => ModeloCalificacion(
        id: id,
        evaluadorId: evaluadorId,
        objetivoId: objetivoId,
        tipoObjetivo: tipoObjetivo,
        valor: valor ?? this.valor,
        comentario: comentario ?? this.comentario,
        contextoId: contextoId,
        creadoEn: creadoEn,
      );
}
