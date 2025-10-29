import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sistema_acviis/backend/controllers/epp/subir_certificado.dart';
import 'package:sistema_acviis/backend/controllers/epp/descargar_certificado.dart';
import '../models/epp.dart';

class EppProvider extends ChangeNotifier {
  List<EPP> _epps = [];
  List<EPP> _eppsFiltrados = []; // ← Nueva lista filtrada
  String _searchQuery = ''; // ← Búsqueda actual
  
  // Estados de filtros activos
  List<String> _filtroTipos = [];
  List<String> _filtroObras = [];
  int? _filtroCantidadMin;
  int? _filtroCantidadMax;
  bool? _filtroTieneCertificado;
  
  // Getters
  List<EPP> get epps => _eppsFiltrados; // ← Ahora devuelve la lista filtrada
  List<EPP> get eppsCompletos => _epps; // ← Para acceso a la lista completa
  String get searchQuery => _searchQuery;
  
  // Getters de filtros activos
  List<String> get filtroTipos => _filtroTipos;
  List<String> get filtroObras => _filtroObras;
  int? get filtroCantidadMin => _filtroCantidadMin;
  int? get filtroCantidadMax => _filtroCantidadMax;
  bool? get filtroTieneCertificado => _filtroTieneCertificado;
  
  bool get hayFiltrosActivos => 
      _filtroTipos.isNotEmpty || 
      _filtroObras.isNotEmpty || 
      _filtroCantidadMin != null || 
      _filtroCantidadMax != null || 
      _filtroTieneCertificado != null ||
      _searchQuery.isNotEmpty;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Método para obtener todos los EPPs
  Future<void> fetchEpps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/epp'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _epps = data.map((json) => EPP.fromJson(json)).toList();
        _aplicarFiltrosYBusqueda(); // ← Aplicar filtros después de cargar
        _error = null;
      } else {
        throw Exception("Error al obtener EPPs: ${response.statusCode}");
      }
    } catch (e) {
      _error = e.toString();
      _epps = [];
      _eppsFiltrados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================== NUEVOS MÉTODOS DE FILTRADO ==================

  /// Aplica filtros múltiples
  void aplicarFiltrosMultiples({
    List<String>? tipos,
    List<String>? obras,
    int? cantidadMinima,
    int? cantidadMaxima,
    bool? tieneCertificado,
  }) {
    _filtroTipos = tipos ?? [];
    _filtroObras = obras ?? [];
    _filtroCantidadMin = cantidadMinima;
    _filtroCantidadMax = cantidadMaxima;
    _filtroTieneCertificado = tieneCertificado;
    
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  /// Aplica filtros específicos (mantener compatibilidad)
  void aplicarFiltros({
    String? tipo,
    String? obra,
    int? cantidadMinima,
    int? cantidadMaxima,
    bool? tieneCertificado,
  }) {
    _filtroTipos = tipo != null ? [tipo] : [];
    _filtroObras = obra != null ? [obra] : [];
    _filtroCantidadMin = cantidadMinima;
    _filtroCantidadMax = cantidadMaxima;
    _filtroTieneCertificado = tieneCertificado;
    
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  /// Limpia todos los filtros
  void limpiarFiltros() {
    _filtroTipos = [];
    _filtroObras = [];
    _filtroCantidadMin = null;
    _filtroCantidadMax = null;
    _filtroTieneCertificado = null;
    
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  /// Aplica búsqueda por texto
  void buscarEpps(String query) {
    _searchQuery = query.trim();
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  /// Limpia la búsqueda
  void limpiarBusqueda() {
    _searchQuery = '';
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  /// Método interno que aplica todos los filtros y búsqueda
  void _aplicarFiltrosYBusqueda() {
    try {
      List<EPP> resultado = List.from(_epps);

      // 1. Aplicar búsqueda por texto
      if (_searchQuery.isNotEmpty) {
        resultado = resultado.where((epp) {
          try {
            return epp.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   epp.obrasAsignadas.any((obra) => 
                     obra.toLowerCase().contains(_searchQuery.toLowerCase())
                   );
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // 2. Aplicar filtro de tipos (múltiples)
      if (_filtroTipos.isNotEmpty) {
        resultado = resultado.where((epp) {
          try {
            return _filtroTipos.any((tipo) => 
              epp.tipo.toLowerCase().trim() == tipo.toLowerCase().trim()
            );
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // 3. Aplicar filtro de obras (múltiples)
      if (_filtroObras.isNotEmpty) {
        resultado = resultado.where((epp) {
          try {
            return _filtroObras.any((obra) {
              if (obra == 'Sin asignar') {
                return epp.obrasAsignadas.isEmpty;
              } else {
                return epp.obrasAsignadas.any((obraEpp) => 
                  obraEpp.toLowerCase().trim() == obra.toLowerCase().trim()
                );
              }
            });
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // 4. Aplicar filtro de cantidad mínima
      if (_filtroCantidadMin != null) {
        resultado = resultado.where((epp) {
          try {
            return epp.cantidad >= _filtroCantidadMin!;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // 5. Aplicar filtro de cantidad máxima
      if (_filtroCantidadMax != null) {
        resultado = resultado.where((epp) {
          try {
            return epp.cantidad <= _filtroCantidadMax!;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      // 6. Aplicar filtro de certificado
      if (_filtroTieneCertificado != null) {
        resultado = resultado.where((epp) {
          try {
            return _filtroTieneCertificado! 
              ? epp.certificadoId != null && epp.certificadoId!.isNotEmpty
              : epp.certificadoId == null || epp.certificadoId!.isEmpty;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      _eppsFiltrados = resultado;
    } catch (e) {
      print('Error aplicando filtros: $e');
      _eppsFiltrados = List.from(_epps); // Fallback a lista completa
    }
  }

  // ================== MÉTODOS EXISTENTES (sin cambios) ==================

    // Actualizar el método registrarEPP en EppProvider:
  Future<bool> registrarEPP({
    required BuildContext context, // ⚡ AGREGAR CONTEXT COMO PARÁMETRO
    required String tipo,
    required List<String> obrasAsignadas,
    required int cantidad,
    required File certificadoPdf,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Subir certificado a MongoDB
      String? certificadoId = await subirCertificadoEpp(certificadoPdf, context);
      
      if (certificadoId == null) {
        throw Exception("Error al subir certificado");
      }

      // 2. Registrar datos en PostgreSQL
      EPP nuevoEpp = EPP(
        tipo: tipo,
        obrasAsignadas: obrasAsignadas,
        cantidad: cantidad,
        certificadoId: certificadoId,
      );

      var response = await http.post(
        Uri.parse('http://localhost:3000/api/epp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(nuevoEpp.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error al registrar en PostgreSQL");
      }

      // 3. Actualizar lista local
      await fetchEpps();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Método para descargar certificado
Future<void> descargarCertificado(BuildContext context, String certificadoId) async {
  await descargarCertificadoEpp(context, certificadoId);
}

  // Método para registrar EPP sin certificado (opcional)
  Future<bool> registrarEPPSinCertificado({
    required String tipo,
    required List<String> obrasAsignadas,
    required int cantidad,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      EPP nuevoEpp = EPP(
        tipo: tipo,
        obrasAsignadas: obrasAsignadas,
        cantidad: cantidad,
        certificadoId: null, // Sin certificado
      );

      var response = await http.post(
        Uri.parse('http://localhost:3000/api/epp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(nuevoEpp.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error al registrar EPP: ${response.statusCode}");
      }

      // Actualizar lista local
      await fetchEpps();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para modificar EPP
  Future<bool> modificarEPP({
  required BuildContext context, // ⚡ AGREGAR CONTEXT
  required int id,
  required String tipo,
  required List<String> obrasAsignadas,
  required int cantidad,
  File? nuevoCertificado,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    String? certificadoId;

    // Si hay nuevo certificado, subirlo primero
    if (nuevoCertificado != null) {
      certificadoId = await subirCertificadoEpp(nuevoCertificado, context);
      
      if (certificadoId == null) {
        throw Exception("Error al subir certificado");
      }
    }

    // Preparar datos de actualización
    Map<String, dynamic> updateData = {
      'tipo': tipo,
      'obrasAsignadas': obrasAsignadas,
      'cantidad': cantidad,
    };

    if (certificadoId != null) {
      updateData['certificadoId'] = certificadoId;
    }

    // Actualizar en PostgreSQL
    var response = await http.put(
      Uri.parse('http://localhost:3000/api/epp/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(updateData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al modificar EPP: ${response.statusCode}");
    }

    // Actualizar lista local
    await fetchEpps();

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  // Método para eliminar EPP individual
  Future<bool> eliminarEpp(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/epp/$id'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception("Error al eliminar EPP: ${response.statusCode}");
      }

      // Actualizar lista local
      await fetchEpps();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para eliminar múltiples EPPs
    Future<bool> eliminarEppsMultiples(List<int> ids) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ⚡ ELIMINAR UNO POR UNO:
      for (int id in ids) {
        final response = await http.delete(
          Uri.parse('http://localhost:3000/api/epp/$id'),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode != 200) {
          throw Exception("Error al eliminar EPP ID $id: ${response.statusCode}");
        }
      }

      // Actualizar lista local
      await fetchEpps();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para obtener EPP por ID
  EPP? obtenerEppPorId(int id) {
    try {
      return _epps.firstWhere((epp) => epp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para obtener estadísticas (basado en datos filtrados)
  Map<String, dynamic> obtenerEstadisticas() {
    if (_eppsFiltrados.isEmpty) {
      return {
        'total': 0,
        'porTipo': <String, int>{},
        'totalCantidad': 0,
        'conCertificado': 0,
        'sinCertificado': 0,
      };
    }

    Map<String, int> porTipo = {};
    int totalCantidad = 0;
    int conCertificado = 0;
    int sinCertificado = 0;

    for (var epp in _eppsFiltrados) {
      // Contar por tipo
      porTipo[epp.tipo] = (porTipo[epp.tipo] ?? 0) + 1;
      
      // Sumar cantidades
      totalCantidad += epp.cantidad;
      
      // Contar certificados
      if (epp.certificadoId != null) {
        conCertificado++;
      } else {
        sinCertificado++;
      }
    }

    return {
      'total': _eppsFiltrados.length,
      'totalCompleto': _epps.length, // ← Total sin filtros
      'porTipo': porTipo,
      'totalCantidad': totalCantidad,
      'conCertificado': conCertificado,
      'sinCertificado': sinCertificado,
      'hayFiltros': hayFiltrosActivos,
    };
  }

  // Método para limpiar errores
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
