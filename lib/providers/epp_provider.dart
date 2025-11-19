import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sistema_acviis/backend/controllers/epp/subir_certificado.dart';
import 'package:sistema_acviis/backend/controllers/epp/descargar_certificado.dart';
import '../models/epp.dart';

class EppProvider extends ChangeNotifier {
  List<EPP> _epps = [];
  List<EPP> _eppsFiltrados = [];
  String _searchQuery = '';
  
  // Estados de filtros activos
  List<String> _filtroTipos = [];
  List<String> _filtroObras = [];
  int? _filtroCantidadMin;
  int? _filtroCantidadMax;
  bool? _filtroTieneCertificado;
  
  // Getters
  List<EPP> get epps => _eppsFiltrados;
  List<EPP> get eppsCompletos => _epps;
  String get searchQuery => _searchQuery;

  // Getter de estado de filtros
  bool get hayFiltrosActivos => 
      _filtroTipos.isNotEmpty || 
      _filtroObras.isNotEmpty || 
      _filtroCantidadMin != null || 
      _filtroCantidadMax != null || 
      _filtroTieneCertificado != null ||
      _searchQuery.isNotEmpty;
  
  // Getters de filtros
  List<String> get filtroTipos => _filtroTipos;
  List<String> get filtroObras => _filtroObras;
  int? get filtroCantidadMin => _filtroCantidadMin;
  int? get filtroCantidadMax => _filtroCantidadMax;
  bool? get filtroTieneCertificado => _filtroTieneCertificado;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ================== 1. FETCH ULTRA ROBUSTO ==================
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
        
        _epps = data.map((jsonItem) {
          Map<String, dynamic> fixedJson = Map<String, dynamic>.from(jsonItem);
          
          // A. TRADUCCIÓN DE CERTIFICADO
          fixedJson['certificadoId'] ??= jsonItem['certificado_id'] ?? jsonItem['fileId'];
          
          // B. TRADUCCIÓN DE OBRAS
          if (fixedJson['obrasAsignadas'] == null) {
             var obraRaw = jsonItem['obras_asignadas'] ?? jsonItem['obra_asignada'] ?? jsonItem['ubicacion'];
             if (obraRaw != null) {
               if (obraRaw is List) {
                 fixedJson['obrasAsignadas'] = obraRaw;
               } else {
                 fixedJson['obrasAsignadas'] = [obraRaw.toString()];
               }
             } else {
               fixedJson['obrasAsignadas'] = [];
             }
          }

          // C. TRADUCCIÓN DE TIPO Y CANTIDAD
          fixedJson['tipo'] ??= jsonItem['tipo_equipamiento'] ?? jsonItem['tipoEpp'];
          fixedJson['cantidad'] ??= jsonItem['cantidad_disponible'];

          return EPP.fromJson(fixedJson);
        }).toList();

        _aplicarFiltrosYBusqueda();
        _error = null;
      } else {
        throw Exception("Error al obtener EPPs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error FETCH: $e");
      _error = e.toString();
      _epps = [];
      _eppsFiltrados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================== 2. REGISTRO CON CERTIFICADO ==================
  Future<bool> registrarEPP({
    required BuildContext context,
    required String tipo,
    required List<String> obrasAsignadas,
    required int cantidad,
    required File certificadoPdf,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? certificadoId = await subirCertificadoEpp(certificadoPdf, context);
      if (certificadoId == null) throw Exception("Falló la subida del PDF");

      final Map<String, dynamic> bodyData = {
        'tipo': tipo,
        'obrasAsignadas': obrasAsignadas, 
        'cantidad': cantidad,
        'certificadoId': certificadoId,
        'fechaRegistro': DateTime.now().toIso8601String(),
        // Formato Legacy / BD
        'tipo_equipamiento': tipo,
        'obra_asignada': obrasAsignadas.isNotEmpty ? obrasAsignadas.first : "Sin Asignar",
        'obras_asignadas': obrasAsignadas,
        'cantidad_disponible': cantidad,
        'certificado_id': certificadoId,
        'fileId': certificadoId,
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      var response = await http.post(
        Uri.parse('http://localhost:3000/api/epp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bodyData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error Backend (${response.statusCode}): ${response.body}");
      }

      await fetchEpps();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error REGISTRO: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ================== 3. REGISTRO SIN CERTIFICADO (CORREGIDO) ==================
  Future<bool> registrarEPPSinCertificado({
    required String tipo,
    required List<String> obrasAsignadas,
    required int cantidad,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> bodyData = {
        // Formato moderno
        'tipo': tipo,
        'obrasAsignadas': obrasAsignadas,
        'cantidad': cantidad,
        'certificadoId': null,
        'fechaRegistro': DateTime.now().toIso8601String(),

        // Formato Legacy / Base de Datos
        'tipo_equipamiento': tipo,
        'obra_asignada': obrasAsignadas.isNotEmpty ? obrasAsignadas.first : "Sin Asignar",
        'obras_asignadas': obrasAsignadas, // ✅ CORRECCIÓN: Agregado para asegurar compatibilidad
        'cantidad_disponible': cantidad,
        'certificado_id': null,
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      var response = await http.post(
        Uri.parse('http://localhost:3000/api/epp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bodyData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error Backend: ${response.statusCode}");
      }

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

  // ================== 4. MÉTODOS DE FILTRADO ==================
  
  void aplicarFiltrosMultiples({List<String>? tipos, List<String>? obras, int? cantidadMinima, int? cantidadMaxima, bool? tieneCertificado}) {
    _filtroTipos = tipos ?? []; 
    _filtroObras = obras ?? [];
    _filtroCantidadMin = cantidadMinima; 
    _filtroCantidadMax = cantidadMaxima;
    _filtroTieneCertificado = tieneCertificado;
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }
  
  void aplicarFiltros({String? tipo, String? obra, int? cantidadMinima, int? cantidadMaxima, bool? tieneCertificado}) {
    _filtroTipos = tipo != null ? [tipo] : []; 
    _filtroObras = obra != null ? [obra] : [];
    _filtroCantidadMin = cantidadMinima; 
    _filtroCantidadMax = cantidadMaxima;
    _filtroTieneCertificado = tieneCertificado;
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTipos = []; 
    _filtroObras = []; 
    _filtroCantidadMin = null;
    _filtroCantidadMax = null; 
    _filtroTieneCertificado = null;
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

  void buscarEpps(String query) {
    _searchQuery = query.trim();
    _aplicarFiltrosYBusqueda();
    notifyListeners();
  }

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

      // 2. Aplicar filtro de tipos (múltiples) - CORREGIDO PARA TALLAS
      if (_filtroTipos.isNotEmpty) {
        resultado = resultado.where((epp) {
          try {
            return _filtroTipos.any((tipoFiltro) {
              // ⚡ CORRECCIÓN: Usamos 'startsWith' o 'contains' para que coincida
              // aunque el EPP tenga talla. Ej: Filtro "Zapato" coincide con "Zapato (42)"
              return epp.tipo.toLowerCase().trim().startsWith(tipoFiltro.toLowerCase().trim());
            });
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
        resultado = resultado.where((epp) => epp.cantidad >= _filtroCantidadMin!).toList();
      }

      // 5. Aplicar filtro de cantidad máxima
      if (_filtroCantidadMax != null) {
        resultado = resultado.where((epp) => epp.cantidad <= _filtroCantidadMax!).toList();
      }

      // 6. Aplicar filtro de certificado
      if (_filtroTieneCertificado != null) {
        resultado = resultado.where((epp) {
          return _filtroTieneCertificado! 
              ? epp.certificadoId != null && epp.certificadoId!.isNotEmpty
              : epp.certificadoId == null || epp.certificadoId!.isEmpty;
        }).toList();
      }

      _eppsFiltrados = resultado;
    } catch (e) {
      print('Error aplicando filtros: $e');
      _eppsFiltrados = List.from(_epps);
    }
  }

  // ================== 5. OTROS MÉTODOS ==================

  Future<void> descargarCertificado(BuildContext context, String certificadoId) async {
    await descargarCertificadoEpp(context, certificadoId);
  }

  Future<bool> modificarEPP({
    required BuildContext context,
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
      if (nuevoCertificado != null) {
        certificadoId = await subirCertificadoEpp(nuevoCertificado, context);
        if (certificadoId == null) throw Exception("Error al subir nuevo certificado");
      }

      Map<String, dynamic> updateData = {
        'tipo': tipo, 'tipo_equipamiento': tipo,
        'obrasAsignadas': obrasAsignadas, 
        'obra_asignada': obrasAsignadas.isNotEmpty ? obrasAsignadas.first : "Sin Asignar",
        'obras_asignadas': obrasAsignadas, // También aquí por si acaso
        'cantidad': cantidad, 'cantidad_disponible': cantidad,
      };

      if (certificadoId != null) {
        updateData['certificadoId'] = certificadoId;
        updateData['certificado_id'] = certificadoId;
      }

      var response = await http.put(
        Uri.parse('http://localhost:3000/api/epp/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updateData),
      );

      if (response.statusCode != 200) throw Exception("Error update");
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

  Future<bool> eliminarEpp(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await http.delete(Uri.parse('http://localhost:3000/api/epp/$id'));
      if (response.statusCode != 200) throw Exception("Error delete");
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

  Future<bool> eliminarEppsMultiples(List<int> ids) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      for (int id in ids) {
        await http.delete(Uri.parse('http://localhost:3000/api/epp/$id'));
      }
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

  EPP? obtenerEppPorId(int id) {
    try { return _epps.firstWhere((epp) => epp.id == id); } catch (e) { return null; }
  }

  Map<String, dynamic> obtenerEstadisticas() {
    if (_eppsFiltrados.isEmpty) {
      return {'total': 0, 'porTipo': <String, int>{}, 'totalCantidad': 0, 'conCertificado': 0, 'sinCertificado': 0};
    }
    Map<String, int> porTipo = {};
    int totalCantidad = 0;
    int conCertificado = 0;
    int sinCertificado = 0;
    for (var epp in _eppsFiltrados) {
      porTipo[epp.tipo] = (porTipo[epp.tipo] ?? 0) + 1;
      totalCantidad += epp.cantidad;
      if (epp.certificadoId != null) conCertificado++; else sinCertificado++;
    }
    return {
      'total': _eppsFiltrados.length,
      'totalCompleto': _epps.length,
      'porTipo': porTipo,
      'totalCantidad': totalCantidad,
      'conCertificado': conCertificado,
      'sinCertificado': sinCertificado,
      'hayFiltros': hayFiltrosActivos,
    };
  }

  void limpiarError() { _error = null; notifyListeners(); }
}
