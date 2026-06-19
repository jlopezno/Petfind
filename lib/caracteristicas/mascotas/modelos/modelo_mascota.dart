// Modela mascotas registradas por usuarios.
enum EspecieMascota {
  perro,
  gato,
  pajaro,
  conejo,
  otro;

  static EspecieMascota fromString(String valor) => switch (valor) {
        'dog' => perro,
        'cat' => gato,
        'bird' => pajaro,
        'rabbit' => conejo,
        _ => otro,
      };

  String toJson() => switch (this) {
        perro => 'dog',
        gato => 'cat',
        pajaro => 'bird',
        conejo => 'rabbit',
        otro => 'other',
      };
}

enum TamanioMascota {
  pequenio,
  mediano,
  grande;

  static TamanioMascota fromString(String valor) => switch (valor) {
        'small' => pequenio,
        'large' => grande,
        _ => mediano,
      };

  String toJson() => switch (this) {
        pequenio => 'small',
        mediano => 'medium',
        grande => 'large',
      };
}

class ModeloMascota {
  const ModeloMascota({
    required this.id,
    required this.duenoId,
    required this.nombre,
    required this.especie,
    this.raza,
    this.color,
    this.tamanio,
    this.fechaNacimiento,
    required this.genero,
    this.descripcion,
    this.fotos = const [],
    this.fotoPrincipal,
    this.microchipId,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  final String id;
  final String duenoId;
  final String nombre;
  final EspecieMascota especie;
  final String? raza;
  final String? color;
  final TamanioMascota? tamanio;
  final DateTime? fechaNacimiento;
  final String genero;
  final String? descripcion;
  final List<String> fotos;
  final String? fotoPrincipal;
  final String? microchipId;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  factory ModeloMascota.fromJson(Map<String, dynamic> json) => ModeloMascota(
        id: json['id'] as String,
        duenoId: json['owner_id'] as String,
        nombre: json['name'] as String? ?? '',
        especie: EspecieMascota.fromString(json['species'] as String? ?? 'other'),
        raza: json['breed'] as String?,
        color: json['color'] as String?,
        tamanio: json['size'] == null ? null : TamanioMascota.fromString(json['size'] as String),
        fechaNacimiento: DateTime.tryParse(json['birth_date'] as String? ?? ''),
        genero: json['gender'] as String? ?? 'M',
        descripcion: json['description'] as String?,
        fotos: List<String>.from(json['photos'] as List? ?? const []),
        fotoPrincipal: json['main_photo'] as String?,
        microchipId: json['microchip_id'] as String?,
        creadoEn: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        actualizadoEn: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': duenoId,
        'name': nombre,
        'species': especie.toJson(),
        'breed': raza,
        'color': color,
        'size': tamanio?.toJson(),
        'birth_date': fechaNacimiento?.toIso8601String(),
        'gender': genero,
        'description': descripcion,
        'photos': fotos,
        'main_photo': fotoPrincipal,
        'microchip_id': microchipId,
        'created_at': creadoEn.toIso8601String(),
        'updated_at': actualizadoEn.toIso8601String(),
      };

  ModeloMascota copyWith({
    String? id,
    String? duenoId,
    String? nombre,
    EspecieMascota? especie,
    String? raza,
    String? color,
    TamanioMascota? tamanio,
    DateTime? fechaNacimiento,
    String? genero,
    String? descripcion,
    List<String>? fotos,
    String? fotoPrincipal,
    String? microchipId,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) =>
      ModeloMascota(
        id: id ?? this.id,
        duenoId: duenoId ?? this.duenoId,
        nombre: nombre ?? this.nombre,
        especie: especie ?? this.especie,
        raza: raza ?? this.raza,
        color: color ?? this.color,
        tamanio: tamanio ?? this.tamanio,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
        genero: genero ?? this.genero,
        descripcion: descripcion ?? this.descripcion,
        fotos: fotos ?? this.fotos,
        fotoPrincipal: fotoPrincipal ?? this.fotoPrincipal,
        microchipId: microchipId ?? this.microchipId,
        creadoEn: creadoEn ?? this.creadoEn,
        actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      );
}
