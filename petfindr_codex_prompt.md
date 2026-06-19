# PetFindr — Prompt Maestro para Codex

> **Instrucción principal:** Eres un agente de desarrollo de software experto en Flutter, Dart y Supabase. Tu tarea es generar el proyecto completo **PetFindr** de una sola vez, siguiendo estrictamente todas las especificaciones de este documento. No omitas ningún archivo. No pidas confirmación entre pasos. Genera todo el código listo para ejecutar.

---

## 1. Contexto del Proyecto

**PetFindr** es una aplicación móvil Flutter para Perú cuyo propósito es:

1. Reportar y encontrar **mascotas perdidas** mediante geolocalización.
2. Publicar **mascotas rescatadas o en refugio** que necesitan cuidado o apoyo económico.
3. Gestionar **adopciones** de mascotas publicadas por cualquier usuario o refugio.
4. Permitir que cualquier usuario **reporte avistamientos** de mascotas perdidas cerca de su ubicación.
5. Recibir **donaciones voluntarias** dentro de publicaciones de mascotas rescatadas (no es un tipo separado — es una acción dentro del tipo `rescatado`).
6. Mantener un **perfil de mascota** con historial de vacunas y recordatorios.
7. Calificar a los usuarios mediante un sistema de **rating positivo/negativo** (thumbs up / thumbs down).
8. Toda publicación pasa por **aprobación de un administrador** antes de ser visible en el feed o el mapa.

---

## 2. Stack Tecnológico

| Capa | Tecnología |
|---|---|
| UI | Flutter 3.x — Material Design 3 |
| Lenguaje | Dart 3.x |
| Estado | flutter_riverpod 2.x (AsyncNotifier, StateNotifier) |
| Navegación | go_router 13.x |
| Backend | Supabase (Auth + PostgreSQL + PostGIS + Storage + Realtime) |
| Mapas | google_maps_flutter 2.x |
| Geolocalización | geolocator 11.x |
| Fotos | image_picker 1.x |
| Notificaciones | flutter_local_notifications 17.x |
| Imágenes en red | cached_network_image 3.x |
| Fechas | intl 0.19.x |

### 2.1 pubspec.yaml completo

```yaml
name: petfindr
description: Aplicación de adopción y encuentro de mascotas perdidas.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.0.0
  supabase_flutter: ^2.5.0
  google_maps_flutter: ^2.6.0
  geolocator: ^11.0.0
  image_picker: ^1.1.0
  flutter_local_notifications: ^17.0.0
  cached_network_image: ^3.3.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  flutter_lints: ^3.0.0
```

---

## 3. Idioma y Convenciones

- Todo el código, comentarios, nombres de variables, clases y archivos deben estar en **español peruano (es-PE)**.
- Excepción: palabras reservadas de Dart/Flutter permanecen en inglés (`class`, `final`, `return`, etc.).
- Nombrado de archivos: `snake_case`.
- Nombrado de clases: `PascalCase`.
- Nombrado de variables y métodos: `camelCase`.
- Cada archivo debe comenzar con un comentario de una línea que describa su propósito.
- Usa `//` para comentarios de línea y `///` para documentación de clases y métodos públicos.

---

## 4. Estructura de Carpetas

Genera exactamente esta estructura. No agregues ni omitas carpetas:

```
lib/
├── main.dart
├── app/
│   ├── enrutador.dart
│   └── tema.dart
├── nucleo/
│   ├── constantes/
│   │   ├── colores.dart
│   │   ├── rutas.dart
│   │   └── supabase_constantes.dart
│   ├── errores/
│   │   └── falla.dart
│   └── utilidades/
│       ├── ayudante_fecha.dart
│       └── validadores.dart
├── caracteristicas/
│   ├── autenticacion/
│   │   ├── modelos/
│   │   │   └── modelo_usuario.dart
│   │   ├── proveedores/
│   │   │   └── proveedor_autenticacion.dart
│   │   └── pantallas/
│   │       ├── pantalla_inicio_sesion.dart
│   │       └── pantalla_registro.dart
│   ├── mascotas/
│   │   ├── modelos/
│   │   │   ├── modelo_mascota.dart
│   │   │   └── modelo_vacuna.dart
│   │   ├── repositorios/
│   │   │   └── repositorio_mascota.dart
│   │   ├── proveedores/
│   │   │   └── proveedor_mascota.dart
│   │   └── pantallas/
│   │       ├── pantalla_detalle_mascota.dart
│   │       └── pantalla_agregar_mascota.dart
│   ├── publicaciones/
│   │   ├── modelos/
│   │   │   ├── modelo_publicacion.dart
│   │   │   ├── modelo_reporte_perdida.dart
│   │   │   ├── modelo_rescate.dart
│   │   │   ├── modelo_adopcion.dart
│   │   │   └── modelo_patrocinio.dart
│   │   ├── repositorios/
│   │   │   └── repositorio_publicacion.dart
│   │   ├── proveedores/
│   │   │   └── proveedor_publicacion.dart
│   │   └── pantallas/
│   │       ├── pantalla_feed.dart
│   │       ├── pantalla_crear_publicacion.dart
│   │       └── pantalla_detalle_publicacion.dart
│   ├── avistamientos/
│   │   ├── modelos/
│   │   │   └── modelo_avistamiento.dart
│   │   ├── repositorios/
│   │   │   └── repositorio_avistamiento.dart
│   │   ├── proveedores/
│   │   │   └── proveedor_avistamiento.dart
│   │   └── pantallas/
│   │       └── pantalla_reportar_avistamiento.dart
│   ├── mapa/
│   │   ├── proveedores/
│   │   │   └── proveedor_mapa.dart
│   │   └── pantallas/
│   │       └── pantalla_mapa.dart
│   ├── calificaciones/
│   │   ├── modelos/
│   │   │   └── modelo_calificacion.dart
│   │   ├── repositorios/
│   │   │   └── repositorio_calificacion.dart
│   │   └── widgets/
│   │       └── widget_calificacion.dart
│   ├── notificaciones/
│   │   ├── modelos/
│   │   │   └── modelo_notificacion.dart
│   │   ├── proveedores/
│   │   │   └── proveedor_notificacion.dart
│   │   └── pantallas/
│   │       └── pantalla_notificaciones.dart
│   └── perfil/
│       ├── proveedores/
│           └── proveedor_perfil.dart
│       └── pantallas/
│           └── pantalla_perfil.dart
└── compartido/
    ├── widgets/
    │   ├── widget_boton_primario.dart
    │   ├── widget_tarjeta_mascota.dart
    │   ├── widget_avatar_mascota.dart
    │   └── widget_cargando.dart
    └── servicios/
        ├── servicio_supabase.dart
        └── servicio_almacenamiento.dart
```

---

## 5. Base de Datos — Schema Supabase

El schema SQL ya está definido. El agente debe conocerlo para generar los modelos y repositorios correctamente.

### 5.1 Tipos enumerados

```sql
CREATE TYPE user_role       AS ENUM ('owner', 'shelter');
CREATE TYPE pet_species     AS ENUM ('dog', 'cat', 'bird', 'rabbit', 'other');
CREATE TYPE pet_size        AS ENUM ('small', 'medium', 'large');
CREATE TYPE post_type       AS ENUM ('lost', 'rescued', 'adoption');
CREATE TYPE post_status     AS ENUM ('pending_approval', 'active', 'observed', 'rejected', 'resolved', 'closed', 'deleted');
CREATE TYPE adoption_status AS ENUM ('pending', 'approved', 'rejected', 'completed');
CREATE TYPE payment_status  AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE rating_target   AS ENUM ('publisher', 'shelter', 'reporter', 'adopter');
```

**Descripción de `post_type`:**
- `lost` — mascota perdida
- `rescued` — mascota rescatada o en refugio (incluye la acción de apoyo económico)
- `adoption` — mascota en adopción

**Descripción de `post_status`:**
- `pending_approval` — recién creada, esperando revisión del administrador
- `active` — aprobada y visible para todos
- `observed` — el administrador solicitó cambios al autor
- `rejected` — el administrador rechazó la publicación
- `resolved` — cerrada exitosamente por el autor (mascota encontrada, adoptada o caso resuelto)
- `closed` — cerrada por el autor sin resolución
- `deleted` — eliminada lógicamente (soft delete)

### 5.2 Tablas principales

#### `profiles`
```
id              UUID  PK — referencia a auth.users
role            user_role  DEFAULT 'owner'
full_name       TEXT
phone           TEXT nullable
avatar_url      TEXT nullable
city            TEXT nullable
shelter_name    TEXT nullable  (solo refugios)
shelter_ruc     TEXT nullable  (solo refugios)
shelter_bio     TEXT nullable  (solo refugios)
verified        BOOLEAN DEFAULT false
location        GEOMETRY(Point, 4326) nullable
rating_score    INT DEFAULT 0  (suma de +1 y -1, actualizado por trigger)
rating_count    INT DEFAULT 0  (total de calificaciones, actualizado por trigger)
created_at      TIMESTAMPTZ
updated_at      TIMESTAMPTZ
```

#### `pets`
```
id              UUID  PK
owner_id        UUID  FK → profiles
name            TEXT
species         pet_species
breed           TEXT nullable
color           TEXT nullable
size            pet_size nullable
birth_date      DATE nullable
gender          CHAR(1) — 'M' | 'F'
description     TEXT nullable
photos          TEXT[]  DEFAULT '{}'
main_photo      TEXT nullable
microchip_id    TEXT nullable
created_at      TIMESTAMPTZ
updated_at      TIMESTAMPTZ
```

#### `vaccines`
```
id              UUID  PK
pet_id          UUID  FK → pets
name            TEXT
administered_at DATE
next_due_at     DATE nullable
veterinarian    TEXT nullable
clinic          TEXT nullable
notes           TEXT nullable
certificate_url TEXT nullable
created_at      TIMESTAMPTZ
```

#### `posts`
```
id              UUID  PK
author_id       UUID  FK → profiles
pet_id          UUID  FK → pets nullable  (opcional — la mascota no necesita estar registrada)
type            post_type
status          post_status DEFAULT 'pending_approval'
title           TEXT
body            TEXT nullable
photos          TEXT[]  DEFAULT '{}'
location        GEOMETRY(Point, 4326) nullable
address_hint    TEXT nullable
-- Campos exclusivos de tipo 'rescued'
severity        TEXT nullable       — 'mild' | 'moderate' | 'urgent'
sponsor_goal    NUMERIC(10,2) nullable  — meta de donación opcional
-- Campos de moderación (escritos solo por el administrador)
admin_note      TEXT nullable       — motivo de rechazo u observación
reviewed_at     TIMESTAMPTZ nullable
reviewed_by     UUID nullable FK → profiles
created_at      TIMESTAMPTZ
updated_at      TIMESTAMPTZ
```

#### `lost_reports`
```
id              UUID  PK
post_id         UUID  FK → posts (UNIQUE)
last_seen_at    TIMESTAMPTZ
last_seen_loc   GEOMETRY(Point, 4326) nullable
last_seen_addr  TEXT nullable
circumstances   TEXT nullable
reward          NUMERIC(10,2) nullable
contact_phone   TEXT nullable
resolved        BOOLEAN DEFAULT false
resolved_at     TIMESTAMPTZ nullable
created_at      TIMESTAMPTZ
```

#### `adoptions`
```
id              UUID  PK
post_id         UUID  FK → posts
applicant_id    UUID  FK → profiles
shelter_id      UUID  FK → profiles
status          adoption_status DEFAULT 'pending'
message         TEXT nullable
rejection_note  TEXT nullable
created_at      TIMESTAMPTZ
updated_at      TIMESTAMPTZ
UNIQUE (post_id, applicant_id)
```

#### `sponsorships`
```
id                UUID  PK
post_id           UUID  FK → posts
sponsor_id        UUID  FK → profiles
amount            NUMERIC(10,2)
currency          CHAR(3) DEFAULT 'PEN'
payment_status    payment_status DEFAULT 'pending'
payment_provider  TEXT nullable — 'stripe' | 'culqi'
provider_tx_id    TEXT nullable
provider_payload  JSONB nullable
created_at        TIMESTAMPTZ
updated_at        TIMESTAMPTZ
```

#### `sightings`
```
id            UUID  PK
post_id       UUID  FK → posts
reporter_id   UUID  FK → profiles
seen_at       TIMESTAMPTZ
location      GEOMETRY(Point, 4326)
address_hint  TEXT nullable
photo_url     TEXT nullable
notes         TEXT nullable
verified      BOOLEAN DEFAULT false
created_at    TIMESTAMPTZ
```

#### `ratings`
```
id            UUID  PK
reviewer_id   UUID  FK → profiles
target_id     UUID  FK → profiles
target_type   rating_target
value         SMALLINT — solo 1 o -1
comment       TEXT nullable
context_id    UUID nullable — ID del post, avistamiento o adopción
created_at    TIMESTAMPTZ
UNIQUE (reviewer_id, target_id, target_type, context_id)
```

### 5.3 Función geo principal

```sql
-- Devuelve publicaciones activas dentro de un radio en metros
-- filter_type = null devuelve todos los tipos (feed unificado)
posts_near_location(lon FLOAT, lat FLOAT, radius_m INT, filter_type TEXT)
```

Llámala desde Dart así:
```dart
await supabase.rpc('posts_near_location', params: {
  'lon': posicion.longitude,
  'lat': posicion.latitude,
  'radius_m': 5000,
  'filter_type': null, // o 'lost', 'adoption', 'sponsor', 'found'
});
```

### 5.4 Vistas de analytics (solo lectura)

- `shelter_stats` — estadísticas por refugio
- `recovery_stats` — mascotas perdidas vs recuperadas por mes
- `sponsorship_stats` — donaciones por mes
- `top_users` — usuarios con mejor rating

---

## 6. Modelos Dart

Genera un modelo Dart por cada tabla. Cada modelo debe:

- Tener constructor `const` con todos los campos.
- Implementar `fromJson(Map<String, dynamic> json)` compatible con la respuesta de Supabase.
- Implementar `toJson()` para enviar datos a Supabase.
- Implementar `copyWith()` para actualizaciones parciales.
- Usar los enums Dart correspondientes a los tipos SQL.

### Enums Dart equivalentes

```dart
// Genera estos enums en sus respectivos archivos de modelo

enum RolUsuario { dueno, refugio }
enum EspecieMascota { perro, gato, pajaro, conejo, otro }
enum TamanioMascota { pequenio, mediano, grande }

// 3 tipos de publicación — no más
enum TipoPublicacion { perdido, rescatado, adopcion }

// 7 estados posibles de una publicación
enum EstadoPublicacion {
  pendienteAprobacion,  // recién creada, en revisión del admin
  activo,               // aprobada y visible
  observado,            // admin solicitó cambios
  rechazado,            // admin rechazó
  resuelto,             // cerrada exitosamente por el autor
  cerrado,              // cerrada por el autor sin resolución
  eliminado,            // soft delete
}

enum GravedadCaso { leve, moderado, urgente }  // solo para tipo rescatado
enum EstadoAdopcion { pendiente, aprobado, rechazado, completado }
enum EstadoPago { pendiente, completado, fallido, reembolsado }
enum TipoCalificacion { publicador, refugio, reportante, adoptante }
```

Cada enum debe tener un método `fromString(String valor)` y `toJson()` para serialización.

---

## 7. Tipos de Usuario y Permisos

### 7.1 Dueño (`owner`)
- Puede registrar sus mascotas con fotos, vacunas y datos.
- Puede crear publicaciones de tipo: `perdido`, `encontrado`, `padrino`.
- Puede reportar avistamientos de mascotas perdidas de otros usuarios.
- Puede solicitar adoptar una mascota publicada por un refugio u otro usuario.
- Puede calificar a refugios, reportantes y adoptantes.
- Puede tener múltiples publicaciones activas simultáneamente.

### 7.2 Refugio (`shelter`)
- Tiene todos los permisos del dueño.
- Además puede crear publicaciones de tipo: `adopcion`.
- Puede aprobar, rechazar o completar solicitudes de adopción.
- Puede ser verificado por administradores (`verified = true`).
- Muestra `shelter_name` y `shelter_bio` en su perfil público.

---

## 8. Pantallas y Navegación

### 8.1 Rutas (go_router)

```
/                         → Redirige según estado de auth
/inicio-sesion            → PantallaInicioSesion
/registro                 → PantallaRegistro
/inicio                   → PantallaInicioDueno  (shell route con bottom nav)
  /feed                   → PantallaFeed
  /mapa                   → PantallaMapa
  /adoptar                → PantallaFeed (filtro: adopcion)
  /perfil                 → PantallaPerfil
/mascota/:id              → PantallaDetalleMascota
/mascota/agregar          → PantallaAgregarMascota
/publicacion/:id          → PantallaDetallePublicacion
/publicacion/crear        → PantallaCrearPublicacion
/avistamiento/:postId     → PantallaReportarAvistamiento
/vacunas/:mascotaId       → PantallaVacunas
/perfil/:usuarioId        → PantallaPerfil (otro usuario)
```

### 8.2 Descripción de cada pantalla

#### `PantallaInicioSesion`
- Campos: correo electrónico, contraseña.
- Botón de ingreso que llama a `supabase.auth.signInWithPassword`.
- Enlace a `PantallaRegistro`.
- Manejo de error con SnackBar.

#### `PantallaRegistro`
- Campos: nombre completo, correo, contraseña, confirmar contraseña.
- Selector de tipo de usuario: Dueño / Refugio.
- Si elige Refugio: campos adicionales nombre del refugio y RUC.
- Llama a `supabase.auth.signUp` pasando `raw_user_meta_data` con `full_name` y `role`.

#### `PantallaInicioDueno` (ShellRoute)
- Header con saludo dinámico (buenos días/tardes/noches) y nombre del usuario.
- Banner de alerta roja si hay mascotas perdidas cerca (radio 5 km).
- Acciones rápidas: Buscar, Adoptar, Vacunas, Código QR (placeholder).
- Sección "Mis mascotas" — scroll horizontal de tarjetas.
- Sección "Recordatorios de vacunas" — lista con colores: rojo=vencido, naranja=próximo ≤30 días, verde=al día.
- FAB: "Reportar pérdida".
- BottomNavigationBar con 4 destinos: Inicio, Mapa, Adoptar, Perfil.

#### `PantallaFeed`
- Lista de publicaciones con estado `activo` ordenadas por fecha descendente.
- Chips de filtro en la parte superior: **Todos | Perdidos | Rescatados | En adopción**.
- Cada tarjeta muestra: foto principal, badge de tipo con color, título, distancia al usuario, rating del autor y badge de gravedad si tipo = `rescatado`.
- Las publicaciones con estado `pending_approval`, `observed` o `rejected` solo son visibles para su propio autor con un badge de estado correspondiente.
- Pull-to-refresh.
- Paginación con scroll infinito (20 items por página).

#### `PantallaMapa`
- Mapa de Google Maps centrado en la ubicación actual del usuario.
- Solo muestra publicaciones con estado `activo`.
- Marcadores de colores por tipo: **rojo=perdido, naranja=rescatado, azul=adopción**.
- Al tocar un marcador muestra un bottom sheet con resumen de la publicación.
- Botón de filtro de radio: 1 km, 5 km, 10 km, 20 km.
- Llama a `posts_near_location` con el radio seleccionado.

#### `PantallaCrearPublicacion`
- Selector de tipo: **Mascota perdida | Mascota rescatada | En adopción**.
- Selector opcional de mascota del perfil del usuario para autocompletar datos. Si no selecciona, los campos se llenan manualmente.
- Campos comunes a todos los tipos: título, descripción, fotos, ubicación con pin arrastrable en mapa.
- **Si tipo = `perdido`:** campos adicionales: última vez visto (fecha/hora), circunstancias, recompensa (opcional), teléfono de contacto.
- **Si tipo = `rescatado`:** campos adicionales: gravedad del caso (Leve / Moderado / Urgente), teléfono de contacto, meta de apoyo económico (opcional — si se define, activa la barra de progreso).
- **Si tipo = `adopcion`:** campos adicionales: edad aproximada, género, tamaño, requisitos del adoptante, teléfono de contacto. Máximo 8 fotos (los otros tipos permiten máximo 5).
- Al guardar: estado inicial = `pending_approval`. Mostrar mensaje al usuario: *"Tu publicación está en revisión. Te notificaremos cuando sea aprobada."*
- Botón guardar: inserta en `posts` y en la tabla especializada según tipo.

#### `PantallaDetallePublicacion`
- Galería de fotos con PageView.
- Badge de estado visible siempre (En revisión / Activo / Observado / Rechazado / Resuelto).
- Datos de la mascota: nombre, especie, raza, color, tamaño.
- Mapa pequeño con la ubicación asociada a la publicación.
- **Si tipo = `perdido`:**
  - Sección de avistamientos reportados (lista cronológica descendente).
  - Botón "Reportar avistamiento" (visible solo si estado = `activo` y el usuario NO es el autor).
  - Botón "Mascota encontrada" (visible solo para el autor, cierra el post como `resuelto`).
- **Si tipo = `rescatado`:**
  - Badge de gravedad del caso (Leve / Moderado / Urgente).
  - Total acumulado de donaciones y número de aportantes (público).
  - Barra de progreso si hay `sponsor_goal` definido.
  - Botón "Apoyar" con `// TODO: integrar pasarela de pago (Stripe o Culqi)` (visible solo si estado = `activo` y el usuario NO es el autor).
  - Botón "Caso resuelto" (visible solo para el autor, cierra el post como `resuelto`).
- **Si tipo = `adopcion`:**
  - Botón "Quiero adoptarlo" → abre formulario de solicitud con campo de mensaje (visible si estado = `activo` y el usuario NO es el autor).
  - Lista de solicitudes recibidas (visible solo para el autor).
  - Botón "Marcar como adoptado" (visible solo para el autor, cierra el post como `resuelto`).
- Widget de calificación thumbs up / thumbs down (visible solo cuando el post está `resuelto`).
- Si el usuario es el autor y el estado es `observed`: mostrar nota del administrador y botón "Editar publicación".

#### `PantallaReportarAvistamiento`
- Campo de fecha y hora del avistamiento.
- Mapa con pin arrastrable para marcar la ubicación.
- Campo de descripción (texto libre).
- Opción de adjuntar foto.
- Botón guardar: inserta en `sightings`.

#### `PantallaPerfil`
- Avatar, nombre, ciudad, tipo de usuario.
- Si es refugio: nombre del refugio, bio, badge de verificado.
- Rating: muestra thumbs up count, thumbs down count y porcentaje positivo.
- Grilla de publicaciones activas del usuario.
- Botón de editar (solo si es el perfil propio).

#### `PantallaDetalleMascota`
- Galería de fotos.
- Datos completos de la mascota.
- Lista de vacunas con estado (al día / próxima / vencida).
- Botón "Agregar vacuna".
- Publicaciones activas relacionadas a esta mascota.

---

## 9. Proveedores Riverpod

Genera estos proveedores usando `AsyncNotifier` para operaciones asíncronas:

### `ProveedorAutenticacion`
```dart
// Maneja el estado de sesión de Supabase Auth
// Expone: usuario actual, rol, método iniciarSesion(), cerrarSesion(), registrar()
```

### `ProveedorPublicaciones`
```dart
// Lista paginada de publicaciones con filtro por tipo
// Métodos: cargarMas(), refrescar(), crearPublicacion(), cerrarPublicacion()
```

### `ProveedorMascota`
```dart
// CRUD completo de mascotas del usuario actual
// Métodos: obtenerMiscotas(), agregarMascota(), actualizarMascota(), eliminarMascota()
```

### `ProveedorMapa`
```dart
// Publicaciones cercanas a la ubicación actual
// Métodos: cargarPublicacionesCercanas(radio), cambiarFiltro(tipo), actualizarUbicacion()
```

### `ProveedorAvistamiento`
```dart
// Avistamientos por publicación
// Métodos: cargarAvistamientos(postId), reportarAvistamiento()
```

### `ProveedorCalificacion`
```dart
// Sistema de rating thumbs up/down
// Métodos: calificar(targetId, tipo, valor, contextId), obtenerCalificacion()
// Previene auto-calificación y duplicados
```

### `ProveedorPerfil`
```dart
// Perfil del usuario actual y de otros usuarios
// Métodos: cargarPerfil(id), actualizarPerfil(), subirAvatar()
```

---

## 10. Servicios

### `ServicioSupabase`
Singleton que encapsula el cliente de Supabase. Todos los repositorios lo usan.

```dart
// Inicializado en main.dart con:
await Supabase.initialize(
  url: 'TU_SUPABASE_URL',        // reemplazar con variable de entorno
  anonKey: 'TU_SUPABASE_ANON_KEY', // reemplazar con variable de entorno
);
```

### `ServicioAlmacenamiento`
Maneja subida y eliminación de fotos en Supabase Storage.

```dart
// Buckets:
// - 'fotos-mascotas'    → fotos del perfil de mascota
// - 'fotos-publicaciones' → fotos adjuntas a publicaciones
// - 'fotos-avistamientos' → fotos de avistamientos
// - 'avatares'          → fotos de perfil de usuarios

// Métodos:
// subirFoto(bucket, archivo) → String URL pública
// eliminarFoto(bucket, ruta) → void
```

---

## 11. Tema Visual

### Paleta de colores principal

```dart
// Colores principales (Material 3)
const colorPrimario        = Color(0xFF1D9E75);  // verde esmeralda
const colorSecundario      = Color(0xFF378ADD);  // azul
const colorError           = Color(0xFFD85A30);  // naranja-rojo
const colorFondo           = Color(0xFFF8F9FA);  // gris muy claro

// Colores por tipo de publicación
const colorPerdido         = Color(0xFFD32F2F);  // rojo
const colorEncontrado      = Color(0xFF388E3C);  // verde
const colorAdopcion        = Color(0xFF1976D2);  // azul
const colorPadrino         = Color(0xFFF57C00);  // naranja
```

Genera el tema completo usando `ThemeData` con `colorSchemeSeed` y `useMaterial3: true`.

---

## 12. Mock Data

Para las pantallas de UI genera datos mock en `nucleo/constantes/mock_data.dart`:

```dart
// Incluir al menos:
// - 3 perfiles de usuario (2 dueños, 1 refugio verificado)
// - 5 mascotas (variedad de especies y tamaños)
// - 8 publicaciones (al menos 2 de cada tipo)
// - 4 avistamientos
// - 6 vacunas distribuidas entre las mascotas
// - 5 calificaciones entre usuarios
```

Los proveedores deben tener un parámetro o variable `usarMock` que cuando es `true` devuelve los datos mock en lugar de llamar a Supabase. En producción `usarMock = false`.

---

## 13. Manejo de Errores

- Crea una clase `Falla` en `nucleo/errores/falla.dart` con subclases:
  - `FallaRed` — error de conexión
  - `FallaServidor` — error de Supabase (código HTTP ≥ 400)
  - `FallaAutenticacion` — sesión expirada o no autorizado
  - `FallaValidacion` — datos del formulario inválidos
- Todos los repositorios devuelven `Either<Falla, T>` o usan `AsyncValue` de Riverpod.
- Los errores se muestran al usuario mediante `SnackBar` con mensaje en español.

---

## 14. Reglas de Negocio Importantes

1. Un usuario **no puede calificarse a sí mismo** (`reviewer_id != target_id`).
2. Un usuario solo puede tener **una calificación por contexto** (UNIQUE en ratings).
3. Un usuario puede tener **múltiples publicaciones activas** de cualquier tipo simultáneamente.
4. Solo el **refugio** puede aprobar o rechazar solicitudes de adopción.
5. Los avistamientos solo pueden reportarse en publicaciones de tipo `perdido` o `encontrado`.
6. El campo `rating_score` en `profiles` es calculado automáticamente por un trigger de Supabase — **nunca lo actualices manualmente desde Flutter**.
7. Las fotos se suben a Supabase Storage **antes** de insertar el registro en la base de datos. Si la subida falla, no se inserta nada.
8. Las donaciones de tipo `padrino` registran el pago con `payment_status = 'pending'` al crear la solicitud. El estado se actualiza cuando llega el webhook del proveedor de pago (Stripe o Culqi). Por ahora el botón "Donar" es un **placeholder** con un `TODO` comentado.

---

## 15. Instrucciones Finales para el Agente

1. Genera **todos los archivos** listados en la estructura de carpetas del punto 4.
2. Cada archivo debe ser **autocontenido y compilable** — no dejes imports sin resolver.
3. Usa `const` donde sea posible para optimizar el rendimiento.
4. Implementa **null safety** estricto en todos los modelos.
5. No uses `setState` — todo el estado va en Riverpod.
6. No uses `Navigator.push` — toda la navegación va en go_router.
7. No generes tests.
8. Donde la integración de pago esté pendiente, deja un comentario `// TODO: integrar pasarela de pago (Stripe o Culqi)`.
9. Donde las variables de entorno sean necesarias (URL de Supabase, API keys de Google Maps), usa placeholders con el formato `'TU_SUPABASE_URL'`, `'TU_SUPABASE_ANON_KEY'`, `'TU_GOOGLE_MAPS_API_KEY'` y agrega un comentario explicando cómo obtenerlas.
10. Al final de la generación, muestra un resumen de archivos creados y los pasos para ejecutar el proyecto por primera vez.
