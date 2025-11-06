# BloodHero

Aplicación móvil Flutter orientada a gestionar donaciones de sangre, turnos y centros disponibles. El proyecto está organizado siguiendo una arquitectura por capas (presentation / domain / data) y hace uso de Riverpod para el manejo de estado.

---

## Visión general

La aplicación cubre el flujo de alta fidelidad para donadores:

- Onboarding y permisos iniciales con opción de diferir cada permiso.
- Home con navegación inferior hacia Centros, Citas, Impacto, Alertas y Perfil.
- Listado de centros de donación con detalle enriquecido y mapa interactivo basado en OpenStreetMap.
- Flujo completo de reserva de turnos (selección de centro, fecha, horario y confirmación).
- Gestión de citas: detalle con opciones para reprogramar o cancelar, historial y recordatorios.
- Logros e impacto del usuario con posibilidad de compartir mediante `share_plus`.

---

## Cronología de hitos implementados

1. **Unificación de componentes UI**: creación de `AppButton`, `InfoCard` y constantes en `layout_constants.dart` para mantener consistencia visual.
2. **Navegación y flujo de citas**: configuración de GoRouter y pantallas de reserva/confirmación; ajuste de retornos a Home o Mis Citas según la acción.
3. **Gestión de permisos**: pantalla paginada con alternativas "Permitir" y "No por ahora" tanto para ubicación como notificaciones.
4. **Integración de Riverpod**: providers para centros y turnos (`centersProvider`, `appointmentsProvider`, etc.) apuntando a un repositorio fake desacoplado.
5. **Mapas en detalle de centro**: reemplazo del placeholder por `flutter_map` + `latlong2`, utilizando tiles públicos de OpenStreetMap y un marcador sobre la posición del centro.
6. **Acciones en detalle de cita**: el botón **Reprogramar** redirige a selección de fecha, **Cancelar** despliega confirmación e informa vía _snackbar_, y la confirmación de turno ahora vuelve correctamente al Home.
7. **Mantenimiento de calidad**: limpieza de lints (`unnecessary_underscores`, `use_build_context_synchronously`) y configuración de `GoogleFonts.config.allowRuntimeFetching` para cargar Poppins en tiempo de ejecución.

---

## Stack tecnológico

- **Framework**: Flutter 3.8.x
- **Gestión de estado**: `flutter_riverpod`
- **Navegación**: `go_router`
- **Mapas**: `flutter_map` + `latlong2` (teselas OpenStreetMap)
- **UI/UX**: `google_fonts`, `smooth_page_indicator`, componentes personalizados
- **Compatibilidad**: Android, iOS, web y escritorio (estructura Flutter multi-plataforma generada)

---

## Requisitos previos

1. Flutter SDK \>= 3.8.1 instalado (incluye Dart SDK 3.8).
2. Android Studio 
3. Emulador configurado.
4. Acceso a internet para cargar fuentes de Google y teselas de OpenStreetMap.

---

## Puesta en marcha

```bash
# 1. Clonar el repositorio
git clone https://github.com/valentinfz/BloodHero.git
cd BloodHero

# 2. Obtener dependencias
flutter pub get

# 3. Verificar estado del proyecto
flutter analyze

# 4. Ejecutar la app en un dispositivo/emulador conectado
flutter run
```

> **Nota**: El proyecto usa `GoogleFonts.config.allowRuntimeFetching = true` y el permiso de internet en Android para descargar las fuentes y teselas. Asegurate de mantener la conexión activa durante la carga del detalle de centros.

---

## Estructura de carpetas relevante

```
lib/
├── config/
│   ├── router/            # GoRouter y definición de rutas
│   └── theme/             # Temas, colores, layout constants
├── data/
│   ├── repositories/      # Implementaciones Firebase (y fake para tests)
│   └── seeds/             # Scripts para poblar datos en Firestore emulado
├── domain/
│   ├── entities/          # Modelos inmutables
│   └── repositories/      # Contratos a implementar (ej. Firebase)
└── presentation/
    ├── providers/         # Providers Riverpod
    ├── screens/           # UI dividida por módulo
    └── widgets/           # Componentes reutilizables
```

---

## Funcionalidades destacadas

- **Detalle de centro con mapa**: marcador centrado en coordenadas reales; se maneja mediante un repositorio fake que proporciona `latitude` y `longitude`.
- **Reprogramación y cancelación de citas**: lógica alojada en providers/routers; cancelación confirma mediante `AlertDialog` y feedback con `SnackBar`.
- **Permisos opcionales**: botones secundarios que permiten posponer los permisos y un helper text que explica cómo reactivarlos desde ajustes.
- **Sharing de logros**: integrado previamente con `share_plus` para enviar mensajes al sistema operativo.

---

## Flujo recomendado de desarrollo

1. **Instalar dependencias**: `flutter pub get`
2. **Analizar lint**: `flutter analyze`
3. **Ejecutar pruebas**: `flutter test` (usa `FakeFirebaseFirestore` y seeds determinísticos)
4. **Lanzar la app**: `flutter run`

> Riverpod utiliza `ProviderScope` en `main.dart`. Cada provider debe mantener la lógica, dejando la UI lo más declarativa posible.

---

## Consideraciones y próximos pasos

- **Seeds para Firebase**: `FirestoreSeedService` permite poblar colecciones (`centers`, `alerts`, `tips`, `achievements`, `users/*/appointments`) tanto en tests como en un emulador local.
- **Permisos de ubicación / notificaciones**: la pantalla ya expone la UX; falta implementar la solicitud real mediante `geolocator` o `permission_handler` y `firebase_messaging`/`awesome_notifications`.
- **Google Fonts**: se está haciendo _runtime fetching_; si se quiere offline, agregar las fuentes `.ttf` en `assets/fonts` y declararlas en `pubspec.yaml`.
- **OpenStreetMap**: el manifiesto ya contempla `INTERNET`. Evitar uso intensivo de subdominios para respetar el _fair use_ de OSM.
- **Integración Firebase + Riverpod**: continuar extendiendo providers para manejar cancelaciones/verificaciones en tiempo real.
- **Permisos de ubicación / notificaciones**: la pantalla ya expone la UX; falta implementar la solicitud real mediante `geolocator` o `permission_handler` y `firebase_messaging`/`awesome_notifications`.
- **Google Fonts**: se está haciendo _runtime fetching_; si se quiere offline, agregar las fuentes `.ttf` en `assets/fonts` y declararlas en `pubspec.yaml`.
- **OpenStreetMap**: el manifiesto ya contempla `INTERNET`. Evitar uso intensivo de subdominios para respetar el _fair use_ de OSM.
- **Integración Firebase + Riverpod**: preparar providers para leer/escribir colecciones,  y reemplazar datos mock.

---

## Contacto

Para dudas o contribuciones, abrir un issue o contactarse con los responsables del proyecto.
