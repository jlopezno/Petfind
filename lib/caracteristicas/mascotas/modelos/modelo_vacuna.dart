// Modela vacunas y recordatorios de una mascota.
class ModeloVacuna {
  const ModeloVacuna({
    required this.id,
    required this.mascotaId,
    required this.nombre,
    required this.administradaEn,
    this.proximaEn,
    this.veterinario,
    this.clinica,
    this.notas,
    this.certificadoUrl,
    required this.creadoEn,
  });

  final String id;
  final String mascotaId;
  final String nombre;
  final DateTime administradaEn;
  final DateTime? proximaEn;
  final String? veterinario;
  final String? clinica;
  final String? notas;
  final String? certificadoUrl;
  final DateTime creadoEn;

  factory ModeloVacuna.fromJson(Map<String, dynamic> json) => ModeloVacuna(
        id: json['id'] as String,
        mascotaId: json['pet_id'] as String,
        nombre: json['name'] as String? ?? '',
        administradaEn: DateTime.tryParse(json['administered_at'] as String? ?? '') ?? DateTime.now(),
        proximaEn: DateTime.tryParse(json['next_due_at'] as String? ?? ''),
        veterinario: json['veterinarian'] as String?,
        clinica: json['clinic'] as String?,
        notas: json['notes'] as String?,
        certificadoUrl: json['certificate_url'] as String?,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pet_id': mascotaId,
        'name': nombre,
        'administered_at': administradaEn.toIso8601String(),
        'next_due_at': proximaEn?.toIso8601String(),
        'veterinarian': veterinario,
        'clinic': clinica,
        'notes': notas,
        'certificate_url': certificadoUrl,
        'created_at': creadoEn.toIso8601String(),
      };

  ModeloVacuna copyWith({
    String? id,
    String? mascotaId,
    String? nombre,
    DateTime? administradaEn,
    DateTime? proximaEn,
    String? veterinario,
    String? clinica,
    String? notas,
    String? certificadoUrl,
    DateTime? creadoEn,
  }) =>
      ModeloVacuna(
        id: id ?? this.id,
        mascotaId: mascotaId ?? this.mascotaId,
        nombre: nombre ?? this.nombre,
        administradaEn: administradaEn ?? this.administradaEn,
        proximaEn: proximaEn ?? this.proximaEn,
        veterinario: veterinario ?? this.veterinario,
        clinica: clinica ?? this.clinica,
        notas: notas ?? this.notas,
        certificadoUrl: certificadoUrl ?? this.certificadoUrl,
        creadoEn: creadoEn ?? this.creadoEn,
      );
}
