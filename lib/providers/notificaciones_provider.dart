import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/notificacion.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/get_notificaciones.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/actualizar_notificaciones.dart';


class NotificacionesProvider extends ChangeNotifier {
  NotificacionConfig? _configuracion;
  NotificacionConfig? get configuracion => _configuracion;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchConfiguracion() async {
    _isLoading = true;
    notifyListeners();
    try {
      final config = await getConfiguracionNotificaciones();
      _configuracion = config;
      _error = null;
    } catch (e) {
      _configuracion = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveConfiguracion(NotificacionConfig config) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await saveConfiguracionNotificaciones(config);
      if (success) {
        _configuracion = config;
        _error = null;
      } else {
        _error = "Error al guardar configuración";
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
