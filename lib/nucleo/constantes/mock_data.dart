// Provee datos mock para desarrollar la UI sin depender de Supabase.
import '../../caracteristicas/autenticacion/modelos/modelo_usuario.dart';
import '../../caracteristicas/avistamientos/modelos/modelo_avistamiento.dart';
import '../../caracteristicas/calificaciones/modelos/modelo_calificacion.dart';
import '../../caracteristicas/mascotas/modelos/modelo_mascota.dart';
import '../../caracteristicas/mascotas/modelos/modelo_vacuna.dart';
import '../../caracteristicas/publicaciones/modelos/modelo_publicacion.dart';

final ahoraMock = DateTime(2026, 6, 12, 10);

final usuariosMock = <ModeloUsuario>[
  ModeloUsuario(
    id: 'usuario-1',
    rol: RolUsuario.dueno,
    nombreCompleto: 'Valeria Quispe',
    telefono: '999111222',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    ciudad: 'Lima',
    latitud: -12.0464,
    longitud: -77.0428,
    puntajeRating: 9,
    cantidadRating: 11,
    creadoEn: ahoraMock.subtract(const Duration(days: 200)),
    actualizadoEn: ahoraMock,
  ),
  ModeloUsuario(
    id: 'usuario-2',
    rol: RolUsuario.dueno,
    nombreCompleto: 'Diego Ramos',
    telefono: '988777666',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    ciudad: 'Miraflores',
    latitud: -12.1211,
    longitud: -77.0297,
    puntajeRating: 4,
    cantidadRating: 6,
    creadoEn: ahoraMock.subtract(const Duration(days: 120)),
    actualizadoEn: ahoraMock,
  ),
  ModeloUsuario(
    id: 'usuario-3',
    rol: RolUsuario.refugio,
    nombreCompleto: 'Refugio Patitas Lima',
    ciudad: 'Surco',
    nombreRefugio: 'Patitas Lima',
    rucRefugio: '20601234567',
    bioRefugio: 'Rescatamos, curamos y buscamos hogares responsables.',
    verificado: true,
    latitud: -12.1456,
    longitud: -76.9919,
    puntajeRating: 18,
    cantidadRating: 20,
    creadoEn: ahoraMock.subtract(const Duration(days: 500)),
    actualizadoEn: ahoraMock,
  ),
];

final mascotasMock = <ModeloMascota>[
  ModeloMascota(
    id: 'mascota-1',
    duenoId: 'usuario-1',
    nombre: 'Luna',
    especie: EspecieMascota.perro,
    raza: 'Mestiza',
    color: 'Caramelo',
    tamanio: TamanioMascota.mediano,
    fechaNacimiento: DateTime(2021, 4, 10),
    genero: 'F',
    descripcion: 'Muy sociable, usa collar rojo.',
    fotoPrincipal: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
    fotos: const ['https://images.unsplash.com/photo-1552053831-71594a27632d?w=800'],
    creadoEn: ahoraMock.subtract(const Duration(days: 100)),
    actualizadoEn: ahoraMock,
  ),
  ModeloMascota(
    id: 'mascota-2',
    duenoId: 'usuario-1',
    nombre: 'Mishi',
    especie: EspecieMascota.gato,
    raza: 'Criollo',
    color: 'Gris',
    tamanio: TamanioMascota.pequenio,
    fechaNacimiento: DateTime(2023, 1, 8),
    genero: 'M',
    fotoPrincipal: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
    fotos: const ['https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800'],
    creadoEn: ahoraMock.subtract(const Duration(days: 90)),
    actualizadoEn: ahoraMock,
  ),
  ModeloMascota(
    id: 'mascota-3',
    duenoId: 'usuario-2',
    nombre: 'Rocky',
    especie: EspecieMascota.perro,
    raza: 'Beagle',
    color: 'Tricolor',
    tamanio: TamanioMascota.mediano,
    fechaNacimiento: DateTime(2020, 9, 2),
    genero: 'M',
    fotoPrincipal: 'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=800',
    fotos: const ['https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=800'],
    creadoEn: ahoraMock.subtract(const Duration(days: 80)),
    actualizadoEn: ahoraMock,
  ),
  ModeloMascota(
    id: 'mascota-4',
    duenoId: 'usuario-3',
    nombre: 'Nube',
    especie: EspecieMascota.conejo,
    color: 'Blanco',
    tamanio: TamanioMascota.pequenio,
    fechaNacimiento: DateTime(2024, 2, 1),
    genero: 'F',
    fotoPrincipal: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=800',
    fotos: const ['https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=800'],
    creadoEn: ahoraMock.subtract(const Duration(days: 60)),
    actualizadoEn: ahoraMock,
  ),
  ModeloMascota(
    id: 'mascota-5',
    duenoId: 'usuario-3',
    nombre: 'Kiwi',
    especie: EspecieMascota.pajaro,
    color: 'Verde',
    tamanio: TamanioMascota.pequenio,
    fechaNacimiento: DateTime(2022, 7, 20),
    genero: 'M',
    fotoPrincipal: 'https://images.unsplash.com/photo-1522926193341-e9ffd686c60f?w=800',
    fotos: const ['https://images.unsplash.com/photo-1522926193341-e9ffd686c60f?w=800'],
    creadoEn: ahoraMock.subtract(const Duration(days: 70)),
    actualizadoEn: ahoraMock,
  ),
];

final vacunasMock = <ModeloVacuna>[
  ModeloVacuna(id: 'vacuna-1', mascotaId: 'mascota-1', nombre: 'Rabia', administradaEn: DateTime(2025, 8, 1), proximaEn: DateTime(2026, 8, 1), veterinario: 'Dra. Salas', clinica: 'Vet Lima', creadoEn: ahoraMock),
  ModeloVacuna(id: 'vacuna-2', mascotaId: 'mascota-1', nombre: 'Quintuple', administradaEn: DateTime(2025, 7, 1), proximaEn: DateTime(2026, 6, 25), creadoEn: ahoraMock),
  ModeloVacuna(id: 'vacuna-3', mascotaId: 'mascota-2', nombre: 'Triple felina', administradaEn: DateTime(2025, 5, 1), proximaEn: DateTime(2026, 5, 1), creadoEn: ahoraMock),
  ModeloVacuna(id: 'vacuna-4', mascotaId: 'mascota-3', nombre: 'Rabia', administradaEn: DateTime(2025, 11, 10), proximaEn: DateTime(2026, 11, 10), creadoEn: ahoraMock),
  ModeloVacuna(id: 'vacuna-5', mascotaId: 'mascota-4', nombre: 'Mixomatosis', administradaEn: DateTime(2026, 1, 20), proximaEn: DateTime(2026, 7, 20), creadoEn: ahoraMock),
  ModeloVacuna(id: 'vacuna-6', mascotaId: 'mascota-5', nombre: 'Control anual', administradaEn: DateTime(2025, 6, 10), proximaEn: DateTime(2026, 6, 10), creadoEn: ahoraMock),
];

final publicacionesMock = <ModeloPublicacion>[
  ModeloPublicacion(id: 'post-1', autorId: 'usuario-1', mascotaId: 'mascota-1', tipo: TipoPublicacion.perdido, estado: EstadoPublicacion.activo, titulo: 'Luna se perdio en Barranco', cuerpo: 'Fue vista cerca al parque municipal.', fotos: const ['https://images.unsplash.com/photo-1552053831-71594a27632d?w=800'], latitud: -12.1441, longitud: -77.0215, direccion: 'Barranco, Lima', distanciaMetros: 1800, nombreMascota: 'Luna', especieMascota: EspecieMascota.perro, razaMascota: 'Mestiza', colorCaracteristicas: 'Caramelo, collar rojo', telefonoContacto: '999111222', creadoEn: ahoraMock.subtract(const Duration(hours: 2)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-2', autorId: 'usuario-2', mascotaId: 'mascota-3', tipo: TipoPublicacion.perdido, estado: EstadoPublicacion.activo, titulo: 'Buscamos a Rocky', cuerpo: 'Tiene placa azul y responde a su nombre.', fotos: const ['https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=800'], latitud: -12.1211, longitud: -77.0297, direccion: 'Miraflores', distanciaMetros: 2400, nombreMascota: 'Rocky', especieMascota: EspecieMascota.perro, razaMascota: 'Beagle', colorCaracteristicas: 'Tricolor', telefonoContacto: '988777666', creadoEn: ahoraMock.subtract(const Duration(days: 1)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-3', autorId: 'usuario-3', mascotaId: 'mascota-4', tipo: TipoPublicacion.adopcion, estado: EstadoPublicacion.activo, titulo: 'Nube busca hogar', cuerpo: 'Conejita tranquila, ideal para departamento.', fotos: const ['https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=800'], latitud: -12.1456, longitud: -76.9919, direccion: 'Surco', distanciaMetros: 5100, nombreMascota: 'Nube', especieMascota: EspecieMascota.conejo, colorCaracteristicas: 'Blanca', edadMascota: '1 anio', generoMascota: 'F', requisitosAdopcion: 'Familia responsable y espacio seguro.', telefonoContacto: '955333111', creadoEn: ahoraMock.subtract(const Duration(days: 2)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-4', autorId: 'usuario-3', mascotaId: 'mascota-5', tipo: TipoPublicacion.adopcion, estado: EstadoPublicacion.pendienteAprobacion, titulo: 'Kiwi necesita una familia', cuerpo: 'Ave joven, sana y curiosa.', fotos: const ['https://images.unsplash.com/photo-1522926193341-e9ffd686c60f?w=800'], latitud: -12.13, longitud: -76.99, direccion: 'Surco', distanciaMetros: 5600, nombreMascota: 'Kiwi', especieMascota: EspecieMascota.pajaro, colorCaracteristicas: 'Verde', edadMascota: '3 anios', telefonoContacto: '955333111', creadoEn: ahoraMock.subtract(const Duration(days: 3)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-5', autorId: 'usuario-1', tipo: TipoPublicacion.rescatado, estado: EstadoPublicacion.activo, titulo: 'Gatito gris rescatado', cuerpo: 'Encontrado cerca a una bodega en Jesus Maria. Necesita control veterinario.', fotos: const ['https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800'], latitud: -12.073, longitud: -77.05, direccion: 'Jesus Maria', distanciaMetros: 3200, nombreMascota: 'Grisito', especieMascota: EspecieMascota.gato, colorCaracteristicas: 'Gris, pequeno', gravedad: GravedadCaso.moderado, metaApoyo: 350, telefonoContacto: '999111222', creadoEn: ahoraMock.subtract(const Duration(days: 4)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-6', autorId: 'usuario-2', tipo: TipoPublicacion.rescatado, estado: EstadoPublicacion.activo, titulo: 'Perrito negro en hogar temporal', cuerpo: 'No se dejo agarrar al inicio, ahora esta a salvo y necesita alimento.', fotos: const ['https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?w=800'], latitud: -12.097, longitud: -77.036, direccion: 'San Isidro', distanciaMetros: 2700, nombreMascota: 'Negrito', especieMascota: EspecieMascota.perro, colorCaracteristicas: 'Negro, mediano', gravedad: GravedadCaso.leve, telefonoContacto: '988777666', creadoEn: ahoraMock.subtract(const Duration(days: 5)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-7', autorId: 'usuario-3', tipo: TipoPublicacion.rescatado, estado: EstadoPublicacion.activo, titulo: 'Ayuda para cirugia de Max', cuerpo: 'Necesitamos cubrir una operacion de emergencia.', fotos: const ['https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800'], latitud: -12.1456, longitud: -76.9919, direccion: 'Surco', distanciaMetros: 5200, nombreMascota: 'Max', especieMascota: EspecieMascota.perro, colorCaracteristicas: 'Marron, grande', gravedad: GravedadCaso.urgente, metaApoyo: 1200, telefonoContacto: '955333111', creadoEn: ahoraMock.subtract(const Duration(days: 6)), actualizadoEn: ahoraMock),
  ModeloPublicacion(id: 'post-8', autorId: 'usuario-1', tipo: TipoPublicacion.rescatado, estado: EstadoPublicacion.observado, titulo: 'Comida para camada rescatada', cuerpo: 'Buscamos apoyo para alimento y controles.', fotos: const ['https://images.unsplash.com/photo-1543852786-1cf6624b9987?w=800'], latitud: -12.07, longitud: -77.04, direccion: 'Lima Centro', distanciaMetros: 1600, nombreMascota: 'Camada rescatada', especieMascota: EspecieMascota.gato, colorCaracteristicas: 'Variados', gravedad: GravedadCaso.moderado, metaApoyo: 500, notaAdmin: 'Agrega una foto mas clara del caso.', telefonoContacto: '999111222', creadoEn: ahoraMock.subtract(const Duration(days: 7)), actualizadoEn: ahoraMock),
];

final avistamientosMock = <ModeloAvistamiento>[
  ModeloAvistamiento(id: 'avis-1', publicacionId: 'post-1', reportanteId: 'usuario-2', vistoEn: ahoraMock.subtract(const Duration(hours: 1)), latitud: -12.142, longitud: -77.02, direccion: 'Parque municipal', notas: 'La vi corriendo hacia la avenida.', creadoEn: ahoraMock),
  ModeloAvistamiento(id: 'avis-2', publicacionId: 'post-1', reportanteId: 'usuario-3', vistoEn: ahoraMock.subtract(const Duration(minutes: 30)), latitud: -12.141, longitud: -77.018, direccion: 'Jiron Union', notas: 'Parecia asustada.', creadoEn: ahoraMock),
  ModeloAvistamiento(id: 'avis-3', publicacionId: 'post-2', reportanteId: 'usuario-1', vistoEn: ahoraMock.subtract(const Duration(hours: 3)), latitud: -12.12, longitud: -77.03, direccion: 'Kennedy', notas: 'Tenia collar azul.', creadoEn: ahoraMock),
  ModeloAvistamiento(id: 'avis-4', publicacionId: 'post-2', reportanteId: 'usuario-3', vistoEn: ahoraMock.subtract(const Duration(days: 1)), latitud: -12.096, longitud: -77.035, direccion: 'Canaval y Moreyra', notas: 'Se fue hacia Javier Prado.', creadoEn: ahoraMock),
];

final calificacionesMock = <ModeloCalificacion>[
  ModeloCalificacion(id: 'cal-1', evaluadorId: 'usuario-1', objetivoId: 'usuario-3', tipoObjetivo: TipoCalificacion.refugio, valor: 1, comentario: 'Excelente seguimiento.', creadoEn: ahoraMock),
  ModeloCalificacion(id: 'cal-2', evaluadorId: 'usuario-2', objetivoId: 'usuario-3', tipoObjetivo: TipoCalificacion.refugio, valor: 1, creadoEn: ahoraMock),
  ModeloCalificacion(id: 'cal-3', evaluadorId: 'usuario-3', objetivoId: 'usuario-1', tipoObjetivo: TipoCalificacion.publicador, valor: 1, creadoEn: ahoraMock),
  ModeloCalificacion(id: 'cal-4', evaluadorId: 'usuario-1', objetivoId: 'usuario-2', tipoObjetivo: TipoCalificacion.reportante, valor: 1, creadoEn: ahoraMock),
  ModeloCalificacion(id: 'cal-5', evaluadorId: 'usuario-2', objetivoId: 'usuario-1', tipoObjetivo: TipoCalificacion.adoptante, valor: -1, comentario: 'Demoro en responder.', creadoEn: ahoraMock),
];
