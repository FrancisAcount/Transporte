import 'package:flutter/foundation.dart';

/// Aplicación de configuración global (tema, alertas, frecuencia).
///
/// Vive en `theme/` porque afecta la apariencia de toda la app.
/// Usa [ChangeNotifier] para que las vistas se reconstruyan cuando cambia
/// algún ajuste (p. ej. el modo oscuro o la frecuencia del mapa).
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  /// Modo oscuro activado/desactivado.
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool v) {
    _isDarkMode = v;
    notifyListeners();
  }

  /// Alertas de proximidad para padres de familia.
  bool _proximityAlerts = false;
  bool get proximityAlerts => _proximityAlerts;
  set proximityAlerts(bool v) {
    _proximityAlerts = v;
    notifyListeners();
  }

  /// Frecuencia de actualización del mapa en segundos (5, 10 o 30).
  int _updateFrequencySeconds = 10;
  int get updateFrequencySeconds => _updateFrequencySeconds;
  set updateFrequencySeconds(int v) {
    _updateFrequencySeconds = v;
    notifyListeners();
  }
}