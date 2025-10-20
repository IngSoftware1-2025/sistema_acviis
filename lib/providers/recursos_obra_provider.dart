import 'package:flutter/foundation.dart';
import 'package:sistema_acviis/backend/controllers/obra_recursos.dart';
import 'package:sistema_acviis/models/obra_recurso.dart';

class RecursosObraProvider with ChangeNotifier {
  List<ObraRecurso> _recursos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ObraRecurso> get recursos => _recursos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtrar recursos por tipo
  List<ObraRecurso> getRecursosPorTipo(String tipo) {
    // SOLUCIÓN: Simplemente filtrar por tipo, sin condición de estado para depuración
    final todosLosRecursos = _recursos.where((recurso) => 
      recurso.tipo == tipo
    ).toList();
    
    print('[SOLUCIÓN] Todos los recursos de tipo $tipo (sin filtrar por estado): ${todosLosRecursos.length}');
    todosLosRecursos.forEach((r) => print('- ID: ${r.id}, Tipo: ${r.tipo}, Estado: ${r.estado}'));
    
    // SOLUCIÓN: Ahora sí filtrar por estado activo
    final recursos = _recursos.where((recurso) => 
      recurso.tipo == tipo && recurso.estado == 'activo'
    ).toList();
    
    print('[SOLUCIÓN] Recursos activos de tipo $tipo: ${recursos.length}');
    recursos.forEach((r) => print('- ID: ${r.id}, Tipo: ${r.tipo}, Estado: ${r.estado}'));
    
    return recursos;
  }

  // Filtrar recursos activos (no retirados)
  List<ObraRecurso> get recursosActivos {
    return _recursos.where((recurso) => recurso.estado == 'activo').toList();
  }
  
  // Filtrar recursos retirados
  List<ObraRecurso> get recursosRetirados {
    return _recursos.where((recurso) => recurso.estado == 'retirado').toList();
  }

  // Cargar recursos de una obra
  Future<void> cargarRecursosObra(String obraId, {String? tipo, bool forceRefresh = false}) async {
    print('[RecursosObraProvider] Cargando recursos para obra ID: $obraId, forceRefresh: $forceRefresh');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recursos = await obtenerRecursosObra(
        obraId: obraId,
        tipo: tipo,
      );
      
      print('[RecursosObraProvider] Recursos cargados: ${_recursos.length}');
      // Verificar si hay recursos y su estado
      if (_recursos.isNotEmpty) {
        print('Muestra de recursos:');
        _recursos.take(3).forEach((r) => 
          print('- ID: ${r.id}, Tipo: ${r.tipo}, Estado: ${r.estado}')
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[RecursosObraProvider] Error al cargar recursos: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Asignar un nuevo recurso a la obra
  Future<void> asignarNuevoRecurso({
    required String obraId,
    required String recursoTipo,
    String? vehiculoId,
    String? herramientaId,
    int? eppId,
    int cantidad = 1,
    String? observaciones,
  }) async {
    print('[RecursosObraProvider] Iniciando asignación de recurso:');
    print('- Tipo: $recursoTipo');
    print('- Obra ID: $obraId');
    print('- Vehículo ID: $vehiculoId');
    print('- Herramienta ID: $herramientaId');
    print('- EPP ID: $eppId');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoRecurso = await asignarRecurso(
        obraId: obraId,
        recursoTipo: recursoTipo,
        vehiculoId: vehiculoId,
        herramientaId: herramientaId,
        eppId: eppId,
        cantidad: cantidad,
        observaciones: observaciones,
      );

      print('[RecursosObraProvider] Recurso asignado con éxito:');
      print('- ID del recurso asignado: ${nuevoRecurso.id}');
      print('- Estado: ${nuevoRecurso.estado}');
      print('- Tipo: ${nuevoRecurso.tipo}');
      if (nuevoRecurso.fechaRetiro != null) {
        print('- Fecha retiro: ${nuevoRecurso.fechaRetiro}');
      }
      
      // SOLUCIÓN MEJORADA: Verificar si ya existe el recurso en la lista (caso de reasignación)
      final existingIndex = _recursos.indexWhere((r) => r.id == nuevoRecurso.id);
      
      if (existingIndex >= 0) {
        // Es una reasignación - actualizar el recurso existente
        print('[RecursosObraProvider] Actualizando recurso existente (reasignación)');
        print('- Recurso anterior estado: ${_recursos[existingIndex].estado}');
        
        // Asegurarse que el estado se actualiza correctamente
        var recursoActualizado = nuevoRecurso;
        if (nuevoRecurso.estado != 'activo') {
          // Crear una nueva instancia con estado activo
          Map<String, dynamic>? detallesActualizados = nuevoRecurso.detalles;
          
          // Crear nueva instancia con estado activo
          recursoActualizado = ObraRecurso(
            id: nuevoRecurso.id,
            tipo: nuevoRecurso.tipo,
            fechaAsignacion: DateTime.now(), // Nueva fecha de asignación
            fechaRetiro: null, // Reset fecha de retiro
            cantidad: nuevoRecurso.cantidad,
            observaciones: nuevoRecurso.observaciones,
            estado: 'activo', // Forzar estado activo
            detalles: detallesActualizados,
          );
        }
        
        _recursos[existingIndex] = recursoActualizado;
        print('- Recurso actualizado estado: ${_recursos[existingIndex].estado}');
      } else {
        // Es una nueva asignación - añadir a la lista
        print('[RecursosObraProvider] Añadiendo nuevo recurso');
        // Verificar que el estado sea correcto
        if (nuevoRecurso.estado != 'activo') {
          print('[ALERTA] El nuevo recurso no tiene estado activo: ${nuevoRecurso.estado}');
          
          // Crear una nueva instancia con estado activo
          final recursoActivo = ObraRecurso(
            id: nuevoRecurso.id,
            tipo: nuevoRecurso.tipo,
            fechaAsignacion: DateTime.now(), // Nueva fecha de asignación
            fechaRetiro: null, // Reset fecha de retiro
            cantidad: nuevoRecurso.cantidad,
            observaciones: nuevoRecurso.observaciones,
            estado: 'activo', // Forzar estado activo
            detalles: nuevoRecurso.detalles,
          );
          
          _recursos.add(recursoActivo);
        } else {
          _recursos.add(nuevoRecurso);
        }
      }
      
      print('[RecursosObraProvider] Total recursos: ${_recursos.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Retirar un recurso de la obra
  Future<void> retirarRecursoObra(String id, {String? observaciones}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recursoActualizado = await retirarRecurso(
        id: id,
        observaciones: observaciones,
      );

      // Actualizar el recurso en la lista
      final index = _recursos.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recursos[index] = recursoActualizado;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Caché de recursos disponibles
  final Map<String, List<dynamic>> _recursosDisponiblesCache = {};
  
  // Cargar recursos disponibles por tipo
  Future<List<dynamic>> cargarRecursosDisponibles(String tipo, {bool forceRefresh = false}) async {
    print('[RecursosObraProvider] Cargando recursos disponibles de tipo: $tipo, forceRefresh: $forceRefresh');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Limpiar caché si se fuerza la actualización
      if (forceRefresh) {
        _recursosDisponiblesCache.remove(tipo);
        print('[RecursosObraProvider] Caché limpiado para tipo: $tipo');
      }
      
      // Usar caché si existe y no se fuerza actualización
      if (!forceRefresh && _recursosDisponiblesCache.containsKey(tipo)) {
        print('[RecursosObraProvider] Usando caché para tipo: $tipo, elementos: ${_recursosDisponiblesCache[tipo]!.length}');
        _isLoading = false;
        notifyListeners();
        return _recursosDisponiblesCache[tipo]!;
      }
      
      print('[RecursosObraProvider] Solicitando recursos disponibles del servidor');
      final disponibles = await obtenerRecursosDisponibles(tipo: tipo);
      print('[RecursosObraProvider] Recursos disponibles recibidos: ${disponibles.length}');
      
      // Guardar en caché
      _recursosDisponiblesCache[tipo] = disponibles;
      
      _isLoading = false;
      notifyListeners();
      return disponibles;
    } catch (e) {
      print('[RecursosObraProvider] Error al cargar recursos disponibles: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  // Limpiar caché de recursos disponibles
  Future<void> limpiarCacheRecursosDisponibles() async {
    _recursosDisponiblesCache.clear();
  }

  // Limpiar datos
  void clear() {
    _recursos = [];
    _error = null;
    notifyListeners();
  }
}