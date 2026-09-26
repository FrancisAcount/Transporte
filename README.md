# Transporte Escolar Maranata 🚌

Sistema de gestión de transporte escolar (**Web + APK Android**) construido con Flutter.
Interfaz institucional: sidebar azul oscuro, contenido claro y acentos guindo/carmesí.

## Estructura de carpetas

```
lib/
├── main.dart                          # Punto de entrada + MaterialApp
└── src/
    ├── theme/
    │   ├── app_colors.dart            # Paleta institucional
    │   └── app_theme.dart             # ThemeData global (cards, botones, tablas)
    ├── models/
    │   ├── menu_item.dart             # Catálogo de los 7 módulos
    │   ├── bus.dart                   # Autobús + enum BusStatus
    │   ├── driver.dart                # Conductor / asistente
    │   ├── student.dart               # Estudiante
    │   ├── route.dart                 # Ruta escolar
    │   └── safety_alert.dart          # Alerta + enum AlertLevel
    ├── data/
    │   └── mock_data.dart             # Datos simulados (sustituible por API)
    ├── widgets/
    │   ├── app_sidebar.dart           # Menú lateral azul (#0F172A)
    │   ├── common_widgets.dart        # SectionCard, StatCard, StatusChip
    │   ├── data_table.dart            # Tabla simulada reutilizable
    │   └── school_map_painter.dart    # Mapa escolar con CustomPainter
    ├── screens/
    │   └── home_screen.dart           # Sidebar + cabecera + contenido activo
    └── views/
        ├── dashboard_view.dart        # 🏠 Panel de Inicio
        ├── routes_view.dart           # 🗺️ Rutas y Monitoreo
        ├── fleet_view.dart            # 🚌 Gestión de Flota
        ├── drivers_view.dart          # 👨‍✈️ Conductores y Personal
        ├── students_view.dart         # 🧒 Registro de Estudiantes
        ├── alerts_view.dart           # 🚨 Alertas y Seguridad
        └── settings_view.dart         # ⚙️ Configuración
```

## Paleta

| Uso                | Color                    |
|--------------------|--------------------------|
| Sidebar            | `#0F172A` (azul oscuro)  |
| Fondo de pantalla  | `#F8FAFC` (gris claro)   |
| Acentos / alertas  | `#991B1B` (guindo)       |
| Texto principal    | `#0F172A`                |
| Texto secundario   | `#475569`                |

## Puesta en marcha

```bash
# 1) Instalar dependencias
flutter pub get

# 2) Generar las carpetas de plataforma (android/, ios/, web/, etc.)
flutter create .

# 3) Ejecutar
flutter run -d chrome     # Web
flutter run               # Android (APK)
flutter build apk --release   # Genera el APK en build/app/outputs/flutter-apk/
```

> Si prefieres el clásico `flutter create transporte_maranata`, crea la carpeta y luego
> copia aquí el contenido de `lib/`, `web/`, `test/` y `pubspec.yaml`.

## Pruebas

```bash
flutter test
```

## Notas de arquitectura

- `HomeScreen` es el único que conoce el estado del menú; cada vista es independiente.
- La navegación usa `AnimatedSwitcher` + `KeyedSubtree` para cambiar de módulo sin cortar el diseño.
- Layout responsivo: sidebar fijo en escritorio/web y `Drawer` en móvil (< 900 px).
- Todos los datos provienen de `MockData`; para conectar una API basta reemplazar ese archivo.
