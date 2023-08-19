import 'package:flutter/material.dart';

class WidgetObserver extends WidgetsBindingObserver {
  late VoidCallback onPostFrameCallback;

  @override
  void didChangeMetrics() {
    // Este método se llama cuando ocurre un cambio en las métricas (por ejemplo, cuando el teclado se muestra/oculta).
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Este método se llama cuando cambia el estado de la aplicación (ejemplo: la aplicación entra en segundo plano).
  }

  @override
  void didHaveMemoryPressure() {
    // Este método se llama cuando hay presión de memoria en el dispositivo.
  }

  @override
  void didChangeAccessibilityFeatures() {
    // Este método se llama cuando cambian las características de accesibilidad.
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // Este método se llama cuando cambian los locales.
  }

  @override
  void didChangeTextScaleFactor() {
    // Este método se llama cuando cambia el factor de escala del texto.
  }

  @override
  void didChangePlatformBrightness() {
    // Este método se llama cuando cambia el brillo del dispositivo.
  }

  @override
  void didChangeMetricsBinding() {
    // Este método se llama cuando cambian las métricas de renderizado.
    if (onPostFrameCallback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onPostFrameCallback();
      });
    }
  }
}
