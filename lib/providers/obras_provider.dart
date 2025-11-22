import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/obra.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/backend/controllers/obras/get_obras.dart';
import 'package:sistema_acviis/backend/controllers/obras/create_charla.dart';
import 'package:sistema_acviis/backend/controllers/obras/upload_asistencia.dart';
import 'package:sistema_acviis/backend/controllers/obras/delete_asistencia.dart';
import 'package:sistema_acviis/backend/controllers/obras/asignar_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/obras/quitar_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/obras/get_trabajadores_obra.dart';
import 'package:sistema_acviis/main.dart'; // Importamos para acceder a la GlobalKey
import 'package:http/http.dart' as http;

class ObrasProvider extends ChangeNotifier {
  List<Obra> _todasLasObras = []; // Almacena todas las obras sin filtrar
  List<Obra> _obras = []; // Almacena las obras filtradas (o todas si no hay filtro)
  List<Obra> get obras => _obras; 

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Future<void> fetchObras() async {
    // Usamos addPostFrameCallback para evitar errores de rebuild durante un build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = true;
      notifyListeners();
    });
    
    try {
      final data = await fetchObrasFromApi();
      _todasLasObras = data;
      _obras = List.from(_todasLasObras); // Inicialmente, la lista filtrada es igual a la completa
    } catch (e) {
      print('Error en ObrasProvider: $e');
      _todasLasObras = [];
      _obras = [];
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<bool> programarCharla({
    required String obraId,
    required DateTime fechaProgramada,
    String? tipoProgramacion,
    int? intervaloDias,
  }) async {
    try {
      final success = await createCharla(
        obraId: obraId,
        fechaProgramada: fechaProgramada,
        tipoProgramacion: tipoProgramacion,
        intervaloDias: intervaloDias,
      );
      if (success) await fetchObras(); // Recargar la lista si fue exitoso
      return success;
    } catch (e) {
      print('Error en ObrasProvider al programar charla: $e');
      return false;
    }
  }

  Future<bool> subirAsistencia({
    required String charlaId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      final success = await uploadAsistencia(
        charlaId: charlaId,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      if (success) {
        await fetchObras(); // Recargar la lista si fue exitoso
      }

      // Mostramos el SnackBar de forma segura usando la GlobalKey
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(success ? 'Archivo subido con éxito.' : 'Error al subir el archivo.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      return success; // Devolvemos el resultado por si la UI necesita reaccionar
    } catch (e) {
      print('Error en ObrasProvider al subir asistencia: $e');
      return false;
    } finally {
      _isUploading = false;
      // No es necesario notificar aquí si fetchObras ya lo hace, pero es más seguro
      notifyListeners(); 
    }
  }

  Future<Obra?> fetchObraById(String obraId) async {
    try {
      // Asumimos que tienes un endpoint GET /obras/:id en tu backend
      const String apiBaseUrl = 'http://localhost:3000';
      final response = await http.get(Uri.parse('$apiBaseUrl/obras/$obraId'));

      if (response.statusCode == 200) {
        final obraActualizada = Obra.fromJson(json.decode(response.body));
        
        // Actualizamos la obra en ambas listas para mantener la consistencia
        final indexObras = _obras.indexWhere((o) => o.id == obraId);
        if (indexObras != -1) {
          _obras[indexObras] = obraActualizada;
        }

        final indexTodas = _todasLasObras.indexWhere((o) => o.id == obraId);
        if (indexTodas != -1) {
          _todasLasObras[indexTodas] = obraActualizada;
        }

        notifyListeners();
        return obraActualizada;
      }
    } catch (e) {
      print('Error al cargar la obra $obraId: $e');
    }
    return null;
  }

  Future<bool> eliminarAsistencia(String asistenciaId) async {
    try {
      final success = await deleteAsistenciaFromApi(asistenciaId);

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(success ? 'Archivo eliminado con éxito.' : 'Error al eliminar el archivo.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      // No es necesario recargar toda la lista, solo devolvemos el estado
      return success;

    } catch (e) {
      print('Error en ObrasProvider al eliminar asistencia: $e');
      return false;
    }
  }

  // Método para asignar un trabajador a una obra
  Future<bool> asignarTrabajadorAObra(String obraId, String trabajadorId, {String? rolEnObra}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Usamos el controlador dedicado para asignar trabajadores
      final success = await asignarTrabajador(
        obraId: obraId,
        trabajadorId: trabajadorId,
        rolEnObra: rolEnObra,
      );
      
      if (success) { 
        // Actualizar datos locales
        await fetchObras(); // Recargar datos para reflejar cambios
        return true;
      }
      return false;
    } catch (e) {
      print('Error en asignarTrabajadorAObra: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para quitar un trabajador de una obra
  Future<bool> quitarTrabajadorDeObra(String obraId, String trabajadorId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Usamos el controlador dedicado para quitar trabajadores
      final success = await quitarTrabajador(
        obraId: obraId,
        trabajadorId: trabajadorId,
      );
      
      if (success) {
        // Actualizar datos locales
        await fetchObras(); // Recargar datos para reflejar cambios
        return true;
      }
      return false;
    } catch (e) {
      print('Error en quitarTrabajadorDeObra: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para obtener trabajadores de una obra específica
  Future<List<Trabajador>> getTrabajadoresDeObra(String obraId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Usamos el controlador dedicado para obtener los trabajadores
      // Renombramos la llamada para evitar recursión
      final trabajadores = await obtenerTrabajadoresDeObra(obraId);
      return trabajadores;
    } catch (e) {
      print('Error en getTrabajadoresDeObra: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error al obtener trabajadores: ${e.toString()}')),
      );
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
