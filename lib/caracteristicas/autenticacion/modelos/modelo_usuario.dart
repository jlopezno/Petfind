// Modela perfiles de usuario almacenados en la tabla profiles.
enum RolUsuario {
  dueno,
  refugio;

  static RolUsuario fromString(String valor) => valor == 'shelter' ? refugio : dueno;

  String toJson() => switch (this) { dueno => 'owner', refugio => 'shelter' };
}

class ModeloUsuario {
  const ModeloUsuario({
    required this.id,
    required this.rol,
    required this.nombreCompleto,
    this.telefono,
    this.avatarUrl,
    this.ciudad,
    this.nombreRefugio,
    this.rucRefugio,
    this.bioRefugio,
    this.verificado = false,
    this.esAdmin = false,
    this.latitud,
    this.longitud,
    this.puntajeRating = 0,
    this.cantidadRating = 0,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final RolUsuario rol;
  final String nombreCompleto;
  final String? telefono;
  final String? avatarUrl;
  final String? ciudad;
  final String? nombreRefugio;
  final String? rucRefugio;
  final String? bioRefugio;
  final bool verificado;
  final bool esAdmin;
  final double? latitud;
  final double? longitud;
  final int puntajeRating;
  final int cantidadRating;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory ModeloUsuario.fromJson(Map<String, dynamic> json) => ModeloUsuario(
        id: json['id'] as String,
        rol: RolUsuario.fromString(json['role'] as String? ?? 'owner'),
        nombreCompleto: json['full_name'] as String? ?? '',
        telefono: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        ciudad: json['city'] as String?,
        nombreRefugio: json['shelter_name'] as String?,
        rucRefugio: json['shelter_ruc'] as String?,
        bioRefugio: json['shelter_bio'] as String?,
        verificado: json['verified'] as bool? ?? false,
        esAdmin: json['is_admin'] as bool? ?? false,
        latitud: (json['lat'] as num?)?.toDouble(),
        longitud: (json['lon'] as num?)?.toDouble(),
        puntajeRating: json['rating_score'] as int? ?? 0,
        cantidadRating: json['rating_count'] as int? ?? 0,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        actualizadoEn: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': rol.toJson(),
        'full_name': nombreCompleto,
        'phone': telefono,
        'avatar_url': avatarUrl,
        'city': ciudad,
        'shelter_name': nombreRefugio,
        'shelter_ruc': rucRefugio,
        'shelter_bio': bioRefugio,
        'verified': verificado,
        'is_admin': esAdmin,
        'rating_score': puntajeRating,
        'rating_count': cantidadRating,
        'created_at': creadoEn.toIso8601String(),
        'updated_at': actualizadoEn.toIso8601String(),
      };

  ModeloUsuario copyWith({
    String? id,
    RolUsuario? rol,
    String? nombreCompleto,
    String? telefono,
    String? avatarUrl,
    String? ciudad,
    String? nombreRefugio,
    String? rucRefugio,
    String? bioRefugio,
    bool? verificado,
    bool? esAdmin,
    double? latitud,
    double? longitud,
    int? puntajeRating,
    int? cantidadRating,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) =>
      ModeloUsuario(
        id: id ?? this.id,
        rol: rol ?? this.rol,
        nombreCompleto: nombreCompleto ?? this.nombreCompleto,
        telefono: telefono ?? this.telefono,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        ciudad: ciudad ?? this.ciudad,
        nombreRefugio: nombreRefugio ?? this.nombreRefugio,
        rucRefugio: rucRefugio ?? this.rucRefugio,
        bioRefugio: bioRefugio ?? this.bioRefugio,
        verificado: verificado ?? this.verificado,
        esAdmin: esAdmin ?? this.esAdmin,
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
        puntajeRating: puntajeRating ?? this.puntajeRating,
        cantidadRating: cantidadRating ?? this.cantidadRating,
        creadoEn: creadoEn ?? this.creadoEn,
        actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      );
}
