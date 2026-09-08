# PetFindr

Aplicación móvil y web desarrollada en Flutter para la comunidad peruana que facilita la **búsqueda de mascotas perdidas**, la **publicación de mascotas rescatadas** (con opción de apoyo económico voluntario) y la **gestión de adopciones**. Incluye geolocalización, notificaciones push, calificaciones entre usuarios y un flujo de moderación por administrador.

> **Versión actual:** `1.0.0+1`

---

## Tabla de contenidos

1. [Características principales](#características-principales)
2. [Stack tecnológico](#stack-tecnológico)
3. [Estructura del proyecto](#estructura-del-proyecto)
4. [Requisitos previos](#requisitos-previos)
5. [Instalación y configuración](#instalación-y-configuración)
6. [Configuración de Supabase](#configuración-de-supabase)
7. [Configuración de Firebase](#configuración-de-firebase)
8. [Google Maps](#google-maps)
9. [Ejecución local](#ejecución-local)
10. [Modo mock](#modo-mock)
11. [Despliegue](#despliegue)
12. [Convenciones de código](#convenciones-de-código)
13. [Roadmap / Pendientes](#roadmap--pendientes)
14. [Licencia](#licencia)

---

## Características principales

- **Autenticación y perfiles**
  - Registro e inicio de sesión con correo y contraseña.
  - Roles de usuario: **Dueño** y **Refugio**.
  - Perfiles verificados para refugios, con nombre del refugio, RUC y bio.
  - Sistema de calificaciones públicas con *thumbs up / thumbs down*.

- **Publicaciones**
  - Tres tipos de publicación: **Mascota perdida**, **Mascota rescatada / en refugio** y **En adopción**.
  - Toda publicación requiere aprobación de un administrador antes de ser visible.
  - Estados: pendiente de aprobación, activa, observada, rechazada, resuelta, cerrada o eliminada.
  - Galería de fotos, ubicación en mapa y detalles específicos según el tipo.

- **Mapa y geolocalización**
  - Mapa interactivo con publicaciones activas cercanas.
  - Filtro por radio: 1 km, 5 km, 10 km y 20 km.
  - Marcadores por tipo: rojo (perdido), naranja (rescatado), azul (adopción).

- **Avistamientos**
  - Cualquier usuario puede reportar avistamientos en publicaciones de mascotas perdidas activas.
  - El autor recibe notificación push y en el centro de notificaciones.

- **Adopciones**
  - Botón "Quiero adoptarlo" con formulario de solicitud.
  - El autor aprueba o rechaza solicitudes.
  - Notificaciones al solicitante con la decisión.

- **Apoyo económico**
  - Disponible dentro de publicaciones de mascotas rescatadas.
  - Meta de apoyo opcional con barra de progreso.
  - Preparado para integración con pasarela de pago (Stripe/Culqi).

- **Notificaciones**
  - Push notifications mediante Firebase Cloud Messaging (FCM).
  - Centro de notificaciones dentro de la app.

---

## Stack tecnológico

| Capa | Tecnología |
|------|------------|
| Framework | Flutter 3.x |
| Lenguaje | Dart 3.x |
| Gestión de estado | `flutter_riverpod` |
| Navegación | `go_router` |
| Backend | Supabase (Auth, PostgreSQL, PostGIS, Storage, Realtime, Edge Functions) |
| Mapas | `google_maps_flutter` / `flutter_map` |
| Geolocalización | `geolocator` |
| Notificaciones push | Firebase Cloud Messaging + `flutter_local_notifications` |
| Imágenes | `image_picker`, `cached_network_image` |
| Tipografía | `google_fonts` (Poppins) |
| Fechas e internacionalización | `intl` |
| Almacenamiento local | `shared_preferences` |
| Deep links | `app_links` |
| Compartir contenido | `share_plus` |

---

## Estructura del proyecto

```
flutter_application_1prueba/
├── android/                    # Configuración Android
├── ios/                        # Configuración iOS
├── lib/                        # Código fuente principal
│   ├── app/                    # Tema y enrutador global
│   ├── caracteristicas/        # Módulos funcionales
│   │   ├── autenticacion/      # Login, registro, onboarding
│   │   ├── avistamientos/      # Reporte de avistamientos
│   │   ├── calificaciones/     # Sistema de rating
│   │   ├── mapa/               # Mapa de publicaciones
│   │   ├── mascotas/           # Perfil y vacunas de mascotas
│   │   ├── perfil/             # Perfil de usuario
│   │   └── publicaciones/      # Feed, creación y detalle de publicaciones
│   ├── compartido/             # Servicios y widgets reutilizables
│   ├── nucleo/                 # Constantes, utilidades y manejo de errores
│   └── main.dart               # Punto de entrada
├── mockups/                    # Mockups de UI
├── supabase/
│   └── functions/              # Edge Functions de Supabase
├── deploy/petfindr/            # Configuración de despliegue web
├── test/                       # Tests (actualmente vacío)
├── analysis_options.yaml       # Reglas del analizador
├── pubspec.yaml                # Dependencias
└── README.md                   # Este archivo
```

### Archivos SQL de base de datos

En la raíz del proyecto se incluyen varios scripts SQL para configurar y poblar Supabase:

| Archivo | Propósito |
|---------|-----------|
| `supabase_schema.sql` | Esquema base completo (tablas, enums, índices, RLS, triggers, storage). |
| `supabase_schema_v2_reset.sql` | Reinicio del esquema a la versión 2. |
| `supabase_migracion_publicaciones_v2.sql` | Migración de publicaciones a la versión 2. |
| `supabase_migracion_avatares.sql` | Migración de avatares. |
| `supabase_migracion_solicitud_adopcion_idempotente.sql` | Solicitudes de adopción idempotentes. |
| `supabase_notificaciones_push.sql` | Configuración de notificaciones push. |
| `supabase_seed_20_adopciones.sql` | Datos semilla de 20 adopciones. |
| `supabase_activar_seed_20_adopciones.sql` | Activación de datos semilla. |

---

## Requisitos previos

- Flutter SDK `>=3.10.0 <4.0.0` (recomendado el canal estable).
- Dart SDK incluido con Flutter.
- Una cuenta y proyecto en [Supabase](https://supabase.com/).
- Un proyecto en [Firebase](https://firebase.google.com/) para FCM (Android/iOS).
- API key de [Google Maps Platform](https://mapsplatform.google.com/) (para mapas en Android/iOS/Web).
- (Opcional) Cuenta en Stripe o Culqi para pagos.

---

## Instalación y configuración

1. Clona o ubícate en el directorio del proyecto:

```bash
cd flutter_application_1prueba
```

2. Instala las dependencias:

```bash
flutter pub get
```

3. Configura las variables de entorno (ver siguiente sección).

4. Para compilar el código generado de Riverpod (si aplica):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Configuración de Supabase

### 1. Crear el proyecto

Crea un proyecto en Supabase y obtén la **URL** y la **anon key** en: `Project Settings > API`.

### 2. Ejecutar el esquema

Abre el **SQL Editor** de Supabase y ejecuta `supabase_schema.sql` (o el script más actualizado según la versión deseada). Este script crea:

- Tipos enumerados (`user_role`, `pet_species`, `post_type`, `post_status`, etc.).
- Tablas principales: `profiles`, `pets`, `vaccines`, `posts`, `lost_reports`, `adoptions`, `sponsorships`, `sightings`, `ratings`.
- Función geoespacial `posts_near_location(lon, lat, radius_m, filter_type)`.
- Triggers para `updated_at` y recálculo de rating.
- Políticas de seguridad a nivel de fila (RLS).
- Buckets de Storage: `fotos-mascotas`, `fotos-publicaciones`, `fotos-avistamientos`, `avatares`.

### 3. Edge Function de notificaciones push

Despliega la función ubicada en `supabase/functions/notificaciones-push/`:

```bash
supabase functions deploy notificaciones-push
```

> Asegúrate de configurar las variables de entorno necesarias en Supabase para FCM.

### 4. Credenciales en la app

Las credenciales pueden inyectarse mediante `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key \
  --dart-define=GOOGLE_MAPS_API_KEY=tu-api-key
```

O edita temporalmente `lib/nucleo/constantes/supabase_constantes.dart` (no recomendado para producción).

---

## Configuración de Firebase

1. Crea un proyecto en Firebase.
2. Registra las aplicaciones Android e iOS.
3. Descarga y coloca los archivos de configuración:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Habilita **Cloud Messaging** en la consola de Firebase.
5. Sube la cuenta de servicio (`firebase-service-account.json`) a Supabase para permitir el envío de notificaciones desde Edge Functions.

> El archivo `firebase-service-account.json` está excluido del control de versiones por seguridad.

---

## Google Maps

1. Habilita la API de Maps SDK en Google Cloud.
2. Restringe la API key por plataforma y paquete.
3. Configura la API key en cada plataforma:
   - **Android:** `android/app/src/main/AndroidManifest.xml`
   - **iOS:** `ios/Runner/AppDelegate.swift`
   - **Web:** parámetro `GOOGLE_MAPS_API_KEY` o configura `flutter_map` como alternativa.

---

## Ejecución local

```bash
# Android
flutter run

# Con variables de entorno
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key \
  --dart-define=GOOGLE_MAPS_API_KEY=tu-api-key

# Web
flutter run -d chrome

# iOS (requiere macOS + Xcode)
flutter run -d ios
```

---

## Modo mock

Para desarrollar o probar la UI sin conexión a Supabase, ejecuta la app con:

```bash
flutter run --dart-define=USAR_MOCK=true
```

Esto activa datos locales definidos en `lib/nucleo/constantes/mock_data.dart`.

---

## Despliegue

### Web

El proyecto incluye instrucciones de despliegue en `deploy/petfindr/README.md`:

```bash
flutter build web --release
```

Luego copia el contenido de `build/web/` al servidor y configura Nginx según `deploy/petfindr/nginx-location.conf`.

### Móvil

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Convenciones de código

- **Idioma:** español peruano (`es-PE`) para nombres de clases, variables, métodos y comentarios. Palabras reservadas de Dart permanecen en inglés.
- **Nombrado:**
  - Archivos: `snake_case.dart`
  - Clases: `PascalCase`
  - Variables y métodos: `camelCase`
- **Comentarios:**
  - `//` para comentarios de línea.
  - `///` para documentación de clases y métodos públicos.
- **Estado:** gestionado exclusivamente con `flutter_riverpod`. No se usa `setState`.
- **Navegación:** gestionada exclusivamente con `go_router`. No se usa `Navigator.push` directamente.
- **Linting:** reglas de `flutter_lints`. Ejecuta `flutter analyze` antes de subir cambios.

---

## Roadmap / Pendientes

- [ ] Integración completa de pasarela de pagos (Stripe/Culqi) para apoyos económicos.
- [ ] Panel de administración web para aprobación de publicaciones.
- [ ] Completar y automatizar tests unitarios y de widgets.
- [ ] Soporte multiidioma formal mediante `flutter_localizations`.
- [ ] Mejorar accesibilidad y pruebas en tablets.

---

## Licencia

Este proyecto es privado y se encuentra en desarrollo. Consulta con el equipo antes de distribuir o reutilizar el código.

---

## Recursos útiles

- [Documentación de Flutter](https://docs.flutter.dev/)
- [Documentación de Supabase](https://supabase.com/docs)
- [Documentación de Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Google Maps Platform](https://mapsplatform.google.com/)
