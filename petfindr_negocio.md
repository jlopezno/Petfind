# PetFindr — Requerimientos de Negocio: Módulo de Publicaciones

> **Propósito de este documento:** Definir con precisión la lógica de negocio del módulo de publicaciones de PetFindr para que un agente de IA pueda implementarlo sin ambigüedades. Este documento complementa al prompt técnico `petfindr_codex_prompt.md`.

---

## 1. Tipos de Publicación

Existen **3 tipos de publicación** en la plataforma. No más, no menos.

| Tipo | Nombre en UI | Descripción |
|---|---|---|
| `perdido` | "Mascota perdida" | El autor reporta que una mascota se extravió |
| `rescatado` | "Mascota rescatada / en refugio" | El autor encontró o alberga una mascota y necesita apoyo |
| `adopcion` | "En adopción" | El autor ofrece una mascota para ser adoptada |

> **Importante:** El apoyo económico **NO es un tipo de publicación**. Es una **acción disponible dentro** de las publicaciones de tipo `rescatado`. Cualquier publicación de tipo `rescatado` puede recibir aportes económicos voluntarios de otros usuarios.

---

## 2. ¿Quién puede publicar?

- Cualquier usuario registrado (dueño o refugio) puede crear publicaciones de **cualquier tipo**.
- No existe restricción de tipo por rol.
- Las publicaciones anónimas **no están permitidas** — se requiere sesión activa.
- **Toda publicación debe ser aprobada por un administrador** antes de ser visible en el feed o el mapa. Ver sección 7.

---

## 3. Registro de Mascota en Publicaciones

- La mascota **no necesita estar registrada previamente** en la app para poder publicar.
- Los datos de la mascota (nombre, especie, descripción, fotos) se ingresan directamente en el formulario de la publicación.
- Si el usuario tiene mascotas registradas en su perfil, puede opcionalmente **vincular** la publicación a una de ellas para autocompletar los datos.
- Si no la vincula, los datos quedan solo en la publicación.

---

## 4. Detalle de Cada Tipo de Publicación

### 4.1 Mascota Perdida (`perdido`)

**¿Quién publica?** El dueño o cualquier persona que sepa de la pérdida.

**Campos del formulario:**

| Campo | Tipo | Obligatorio | Notas |
|---|---|---|---|
| Nombre de la mascota | Texto | No | Puede ser "desconocido" |
| Especie | Selector | Sí | Perro, Gato, Ave, Conejo, Otro |
| Raza | Texto | No | |
| Color / características | Texto | Sí | Para identificarla |
| Descripción | Texto largo | Sí | Detalles del animal |
| Fotos | Imágenes | No | Mínimo 0, máximo 5 |
| Ubicación donde se perdió | Mapa con pin | Sí | El usuario arrastra el pin al lugar exacto |
| Fecha y hora que se perdió | Fecha + hora | Sí | |
| Circunstancias | Texto | No | "Se escapó por la puerta", etc. |
| Recompensa | Numérico (S/.) | No | Opcional, visible en la publicación |
| Teléfono de contacto | Texto | Sí | Para que quien la encuentre pueda llamar |

**Ciclo de vida:**

```
borrador → pendiente_aprobacion → activo → resuelto / cerrado
```

- El autor puede marcar la publicación como **"Mascota encontrada"** mediante un botón en su propio post.
- Al hacerlo, el estado cambia a `resuelto` y el post se cierra para nuevos reportes.
- El cierre es **manual** para evitar falsos positivos de avistamientos.
- Los avistamientos reportados por otros usuarios **no cierran** la publicación automáticamente — solo notifican al autor.

**Acciones disponibles para otros usuarios:**
- Reportar avistamiento (ver sección 5).
- Compartir la publicación.
- Calificar al autor (una vez resuelta).

---

### 4.2 Mascota Rescatada / En Refugio (`rescatado`)

**¿Quién publica?** Cualquier usuario que haya encontrado una mascota o la tenga en su cuidado temporal.

**Campos del formulario:**

| Campo | Tipo | Obligatorio | Notas |
|---|---|---|---|
| Nombre de la mascota | Texto | No | Puede ser un nombre temporal |
| Especie | Selector | Sí | |
| Raza | Texto | No | |
| Color / características | Texto | Sí | |
| Descripción del caso | Texto largo | Sí | Contar la historia del rescate |
| Fotos | Imágenes | Sí | Mínimo 1, máximo 5 |
| Gravedad del caso | Selector | Sí | Leve / Moderado / Urgente |
| Ubicación actual del animal | Mapa con pin | Sí | Donde está siendo cuidado |
| Teléfono de contacto | Texto | Sí | |
| Meta de apoyo económico | Numérico (S/.) | No | Si se define, muestra barra de progreso |

**Sobre la meta de apoyo económico:**
- El autor puede definir un monto objetivo (ej. S/. 500 para una operación).
- Si define una meta, la publicación muestra una **barra de progreso** con el total acumulado vs la meta.
- Si no define meta, el apoyo sigue siendo posible — se muestra solo el total acumulado.
- Los aportes son **libres y voluntarios** — cualquier monto mayor a S/. 1.00.

**Ciclo de vida:**

```
borrador → pendiente_aprobacion → activo → resuelto / cerrado
```

- El autor cierra la publicación manualmente con el botón **"Caso resuelto"**.
- Al cerrarse, se deja de recibir aportes económicos nuevos.
- Los aportes ya procesados **no se reembolsan** al cerrar (lógica de pasarela de pago externa).

**Acciones disponibles para otros usuarios:**
- **Apoyar económicamente** (donación voluntaria, ver sección 6).
- Reportar "Encontré al dueño" — notifica al autor pero no cierra la publicación.
- Calificar al autor (una vez resuelta).

---

### 4.3 En Adopción (`adopcion`)

**¿Quién publica?** Cualquier usuario registrado (dueño o refugio).

**Campos del formulario:**

| Campo | Tipo | Obligatorio | Notas |
|---|---|---|---|
| Nombre de la mascota | Texto | Sí | |
| Especie | Selector | Sí | |
| Raza | Texto | No | |
| Color / características | Texto | Sí | |
| Edad aproximada | Texto | No | "2 años", "cachorro", etc. |
| Género | Selector | No | Macho / Hembra |
| Tamaño | Selector | No | Pequeño / Mediano / Grande |
| Descripción del animal | Texto largo | Sí | Personalidad, hábitos, etc. |
| Fotos | Imágenes | Sí | Mínimo 1, máximo 8 |
| Ubicación de entrega | Mapa con pin | Sí | Dónde se puede ir a conocer al animal |
| Requisitos del adoptante | Texto | No | "Necesita patio", "No niños menores", etc. |
| Teléfono de contacto | Texto | Sí | |

**Ciclo de vida:**

```
borrador → pendiente_aprobacion → activo → adoptado / cerrado
```

- Cuando el autor confirma que el animal fue adoptado, presiona el botón **"Marcar como adoptado"**.
- El estado cambia a `adoptado` (equivalente a `resuelto`) y el post se cierra para nuevas solicitudes.
- El cierre es **manual** — el autor decide cuándo confirmar la adopción.

**Flujo de solicitud de adopción:**

```
Usuario ve el post
    ↓
Presiona botón "Quiero adoptarlo"
    ↓
Completa formulario de solicitud (mensaje, por qué quiere adoptarlo)
    ↓
Se crea registro en tabla `adoptions` con estado `pendiente`
    ↓
El autor recibe notificación push + notificación en app
    ↓
El autor revisa la solicitud y puede: Aprobar o Rechazar
    ↓
El solicitante recibe notificación push + notificación en app con la decisión
    ↓
Si aprobada → el autor marca el post como "Adoptado" para cerrarlo
```

- Un mismo usuario puede enviar solicitud a múltiples publicaciones de adopción.
- Una publicación puede tener múltiples solicitudes simultáneas.
- El autor ve todas las solicitudes recibidas en una lista dentro de su publicación.
- Solo el **autor de la publicación** puede aprobar o rechazar solicitudes.
- Al aprobar una solicitud, las demás quedan en estado `pendiente` hasta que el autor cierre el post.

**Acciones disponibles para otros usuarios:**
- **Solicitar adopción** (botón "Quiero adoptarlo").
- Calificar al autor (una vez resuelta).
- El adoptante puede ser calificado por el autor tras completar la adopción.

---

## 5. Avistamientos

Un avistamiento es un reporte que cualquier usuario registrado puede hacer sobre una mascota de una publicación de tipo `perdido`.

**¿Cuándo se puede reportar un avistamiento?**
- Solo en publicaciones de tipo `perdido` con estado `activo`.
- No se pueden reportar avistamientos en publicaciones cerradas o en revisión.

**Campos del formulario de avistamiento:**

| Campo | Tipo | Obligatorio |
|---|---|---|
| Fecha y hora en que la vio | Fecha + hora | Sí |
| Ubicación donde la vio | Mapa con pin | Sí |
| Descripción | Texto | No |
| Foto | Imagen | No |

**Notificaciones al reportar un avistamiento:**
- El autor de la publicación recibe una **notificación push** con el texto: *"Alguien reportó un avistamiento de [nombre de la mascota]"*.
- Dentro de la app, aparece una **notificación en el centro de notificaciones** con enlace directo al avistamiento.

**Visibilidad de avistamientos:**
- Los avistamientos son visibles para todos los usuarios dentro del detalle de la publicación.
- Se muestran en orden cronológico descendente (el más reciente primero).
- Cada avistamiento muestra: foto del reportante, fecha, ubicación en mini mapa, descripción y foto adjunta si la hay.

---

## 6. Apoyo Económico (Donaciones)

El apoyo económico es una **acción**, no un tipo de publicación. Solo está disponible en publicaciones de tipo `rescatado`.

**Flujo de donación:**

```
Usuario ve publicación de tipo rescatado
    ↓
Presiona botón "Apoyar"
    ↓
Ve el monto acumulado (y barra de progreso si hay meta definida)
    ↓
Ingresa el monto que desea donar (mínimo S/. 1.00, libre)
    ↓
Es redirigido a la pasarela de pago (Stripe o Culqi)
    ↓
Completa el pago en la pasarela
    ↓
La pasarela envía webhook a Supabase Edge Function
    ↓
Se actualiza el registro en tabla `sponsorships` con estado `completado`
    ↓
El autor recibe notificación push + notificación en app
    ↓
El monto acumulado se actualiza en tiempo real (Supabase Realtime)
```

**Reglas del apoyo económico:**
- El monto es **libre y voluntario** — el usuario decide cuánto donar.
- Si el autor definió una **meta**, se muestra barra de progreso. La barra no bloquea nuevas donaciones al llegar al 100%.
- Si no hay meta, se muestra solo el total acumulado con el número de aportantes.
- Un mismo usuario puede donar **múltiples veces** a la misma publicación.
- Las donaciones **no se reembolsan** desde la app.
- Al cerrar la publicación, el botón "Apoyar" desaparece pero el historial de donaciones permanece visible.
- El monto individual de cada donante es **privado** — solo lo ve el autor. El total y número de aportantes son públicos.
- La integración de pasarela (Stripe o Culqi) va en fase posterior. El botón "Apoyar" lleva un `// TODO: integrar pasarela de pago`.

---

## 7. Flujo de Aprobación por Administrador

**Toda publicación creada pasa por revisión antes de ser visible.**

```
Usuario crea publicación
    ↓
Estado: pendiente_aprobacion
    ↓
El autor ve su publicación con badge "En revisión"
    ↓
Administrador revisa en panel externo (web)
    ↓
         ┌─────────────┬─────────────┐
      Aprueba        Rechaza     Solicita cambios
         ↓              ↓              ↓
    Estado: activo  Estado: rechazado  Estado: observado
    Visible en feed  Solo visible      Solo visible
    y mapa           para el autor     para el autor
                     con motivo        con comentario
                     de rechazo        del admin
```

**Estados de la tabla `posts`:**

| Estado | Descripción |
|---|---|
| `pendiente_aprobacion` | Recién creada, esperando revisión del admin |
| `activo` | Aprobada y visible para todos |
| `observado` | Admin solicitó cambios al autor |
| `rechazado` | Admin rechazó la publicación |
| `resuelto` | Cerrada exitosamente por el autor |
| `cerrado` | Cerrada por el autor sin resolución |
| `eliminado` | Eliminada lógicamente (soft delete) |

> **Nota para el agente:** El panel de administración es una interfaz web separada que interactúa directamente con Supabase. La app Flutter solo maneja los estados desde la perspectiva del usuario final — no implementa el panel admin.

---

## 8. Sistema de Notificaciones

Todas las notificaciones tienen **dos canales simultáneos:**
1. **Push notification** — aparece en la barra del sistema operativo (FCM).
2. **Notificación en app** — aparece en el centro de notificaciones dentro de PetFindr (ícono de campana en el header).

### Tabla completa de eventos

| Evento | Quién recibe | Mensaje |
|---|---|---|
| Publicación aprobada | Autor | "Tu publicación fue aprobada y ya es visible" |
| Publicación rechazada | Autor | "Tu publicación fue rechazada: [motivo]" |
| Publicación observada | Autor | "Tu publicación necesita cambios: [comentario]" |
| Nuevo avistamiento | Autor del post perdido | "Alguien reportó un avistamiento de [nombre]" |
| Nueva donación recibida | Autor del post rescatado | "[Usuario] apoyó tu publicación con S/. [monto]" |
| Nueva solicitud de adopción | Autor del post adopción | "[Usuario] quiere adoptar a [nombre]" |
| Solicitud aprobada | Solicitante | "¡Tu solicitud para adoptar a [nombre] fue aprobada!" |
| Solicitud rechazada | Solicitante | "Tu solicitud para adoptar a [nombre] fue rechazada: [motivo]" |
| Reporte "encontré al dueño" | Autor del post rescatado | "[Usuario] dice haber encontrado al dueño de [nombre]" |

---

## 9. Calificaciones (Rating)

El sistema de rating es **thumbs up (+1) / thumbs down (-1)**.

### ¿Cuándo se puede calificar?

| Situación | Quién califica | A quién |
|---|---|---|
| Post de pérdida resuelto | Comunidad | Al autor que publicó |
| Avistamiento reportado | Autor del post | Al reportante del avistamiento |
| Adopción completada | Autor del post | Al adoptante |
| Adopción completada | Adoptante | Al autor del post |
| Post de rescate cerrado | Comunidad | Al autor que publicó |

### Reglas del rating
- Un usuario **no puede calificarse a sí mismo**.
- Un usuario solo puede emitir **una calificación por contexto**.
- El `rating_score` se calcula automáticamente por trigger en Supabase — **nunca modificar desde Flutter**.
- El porcentaje positivo se calcula como: `(votos positivos / total votos) * 100`.
- Un comentario es **opcional** al calificar.
- Las calificaciones son **públicas**.

---

## 10. Reglas de Negocio Críticas (resumen para el agente)

1. Existen exactamente **3 tipos de publicación**: `perdido`, `rescatado`, `adopcion`.
2. El apoyo económico es una **acción dentro de `rescatado`**, no un tipo separado.
3. Toda publicación requiere **aprobación del administrador** antes de ser visible.
4. La mascota **no necesita estar registrada** en la app para crear una publicación.
5. El cierre de publicaciones es siempre **manual por el autor**.
6. Los avistamientos solo aplican a publicaciones de tipo **`perdido`** en estado **`activo`**.
7. Las donaciones se procesan en pasarela externa — la app solo registra el resultado del **webhook**.
8. Si hay meta de apoyo definida → mostrar **barra de progreso**. Si no → mostrar solo total acumulado.
9. Al cerrar una publicación `rescatado`, el botón "Apoyar" desaparece pero el historial de donaciones queda visible.
10. Todas las notificaciones van por **dos canales**: push + centro de notificaciones en app.
11. El **panel de administración** es externo a la app Flutter — no se implementa en este proyecto.
12. Un usuario puede tener **múltiples publicaciones activas** de cualquier tipo simultáneamente.
