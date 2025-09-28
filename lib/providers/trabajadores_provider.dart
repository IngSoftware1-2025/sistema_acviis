import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/get_trabajadores.dart';

class TrabajadoresProvider extends ChangeNotifier {
  List<Trabajador> _todos = [];
  List<Trabajador> _trabajadores = [];
  List<Trabajador> get trabajadores => _trabajadores;

  // Filtros Trabajador
  String? obraAsignada;
  String? cargo;
  String? estadoCivil;
  RangeValues? rangoSueldo;
  RangeValues? rangoEdad;
  String? sistemaSalud;
  String? estadoEmpresa;
  String? textoBusqueda;
  
  // Filtros Contrato
  String? estadoContrato;
  int? tiempoContrato; // en años
  int? cantidadContratos;

  bool _isLoading = false;
  final Map<String, bool> _trabajadorIsLoading = {};
  bool get isLoading => _isLoading;
  bool trabajadorIsLoading(String id) => _trabajadorIsLoading[id] ?? false;

  Future<void> fetchTrabajadores() async {
    if (_todos.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    if (_todos.isEmpty) {
      _todos = await fetchTrabajadoresFromApi();
     
    }
    else {
      List<Trabajador> nuevos = await fetchTrabajadoresFromApi();
      for (var nuevo in nuevos) {
        final index = _todos.indexWhere((t) => t.id == nuevo.id);
        if (index != -1) {
          // Si el rut del existente NO es nulo
            if (_todos[index].rut != '') {
            continue;
          }
          _todos[index] = nuevo;
        } else {
          _todos.add(nuevo);
        }
      }
    }
    
    _trabajadores = List.from(_todos);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTrabajadorId(String id) async {
    final t = _todos.firstWhere(
      (e) => e.id == id,
      orElse: () => Trabajador(
        id: '',
        rut: '',
        nombreCompleto: '',
        fechaDeNacimiento: DateTime(1900),
        direccion: '',
        estadoCivil: '',
        sistemaDeSalud: '',
        estado: '',
        obraEnLaQueTrabaja: '',
        rolQueAsumeEnLaObra: '',
        contratos: [],
        correoElectronico: '',
        previsionAfp: '',
      ),
    );
    if (t.id == '' || t.rut != '') {
      return;
    }
    _trabajadorIsLoading[id] = true;
    notifyListeners();

    Trabajador trabajador = await fetchTrabajadorFromApi(id);

    final index = _todos.indexWhere((e) => e.id == trabajador.id);
    if (index != -1) {
      _todos[index] = trabajador;
      filtrar();
    }

    _trabajadorIsLoading[id] = false;
    notifyListeners();
  }

  void actualizarFiltros({
    // Filtros trabajador
    String? obraAsignada,
    String? cargo,
    String? estadoCivil,
    RangeValues? rangoSueldo,
    RangeValues? rangoEdad,
    String? sistemaSalud,
    String? estadoEmpresa,
    // Filtros Contrato
    String? estadoContrato,
    int? tiempoContrato, // en años
    int? cantidadContratos,
  }) {
    this.obraAsignada = obraAsignada ?? this.obraAsignada;
    this.cargo = cargo ?? this.cargo;
    this.estadoCivil = estadoCivil ?? this.estadoCivil;
    this.rangoSueldo = rangoSueldo ?? this.rangoSueldo;
    this.rangoEdad = rangoEdad ?? this.rangoEdad;
    this.sistemaSalud = sistemaSalud ?? this.sistemaSalud;
    this.estadoEmpresa = estadoEmpresa ?? this.estadoEmpresa;

    this.estadoContrato = estadoContrato ?? this.estadoContrato;
    this.tiempoContrato = tiempoContrato ?? this.tiempoContrato;
    this.cantidadContratos = cantidadContratos ?? this.cantidadContratos;
    filtrar();
  }

  void actualizarBusqueda(String? texto) {
    textoBusqueda = texto;
    filtrar();
  }

  void filtrar() {
    _trabajadores = _todos.where((t) {
      // Obra asignada
      if (obraAsignada != null && obraAsignada!.isNotEmpty && t.obraEnLaQueTrabaja != obraAsignada) return false;
      // Cargo
      if (cargo != null && cargo!.isNotEmpty && t.rolQueAsumeEnLaObra != cargo) return false;
      // Estado civil
      if (estadoCivil != null && estadoCivil!.isNotEmpty && t.estadoCivil != estadoCivil) return false;
      // Sistema de salud
      if (sistemaSalud != null && sistemaSalud!.isNotEmpty && t.sistemaDeSalud != sistemaSalud) return false;
      // Estado en la empresa
      if (estadoEmpresa != null && estadoEmpresa!.isNotEmpty && t.estado != estadoEmpresa) return false; 
      // Edad
      if (rangoEdad != null) {
        final edad = _calcularEdad(t.fechaDeNacimiento);
        if (edad < rangoEdad!.start || edad > rangoEdad!.end) return false;
      }
      // Sueldo (si tienes el campo sueldo en tu modelo, descomenta y ajusta)
      // if (rangoSueldo != null && t.sueldo != null) {
      //   if (t.sueldo < rangoSueldo!.start * 1000000 || t.sueldo > rangoSueldo!.end * 1000000) return false;
      // }
      
      // Estado Contrato
      if (estadoContrato != null) {
        if (t.contratos.isEmpty) return false;
        bool tieneContratoTipo = t.contratos.any((contrato) =>
          contrato['estado'] == estadoContrato
        );
        if (!tieneContratoTipo) return false;
      }
      // Tiempo de contrato (calcula el tiempo restante del contrato activo en años)
      if (tiempoContrato != null) {
        if (t.contratos.isEmpty) return false;
        final contratoActivo = t.contratos.firstWhere(
          (c) => c['estado'] == 'Activo',
          orElse: () => null,
        );
        if (contratoActivo != null) {
          final fechaContratacion = DateTime.tryParse(contratoActivo['fecha_de_contratacion'] ?? '');
          final plazoStr = contratoActivo['plazo_de_contrato'] ?? '';
          if (fechaContratacion != null && plazoStr.isNotEmpty) {
            // Extrae el número y la unidad del plazo (ej: "3 años")
            final match = RegExp(r'(\d+)\s*(\w+)').firstMatch(plazoStr);
            if (match != null) {
              final cantidad = int.tryParse(match.group(1) ?? '');
              final unidad = match.group(2)?.toLowerCase();
              Duration duracion;
              if (unidad == 'año' || unidad == 'años') {
                duracion = Duration(days: 365 * (cantidad ?? 0));
              } else if (unidad == 'mes' || unidad == 'meses') {
                duracion = Duration(days: 30 * (cantidad ?? 0));
              } else if (unidad == 'día' || unidad == 'días') {
                duracion = Duration(days: cantidad ?? 0);
              } else {
                duracion = Duration.zero;
              }
              final fechaFin = fechaContratacion.add(duracion);
              final hoy = DateTime.now();
              final tiempoRestanteAnios = fechaFin.difference(hoy).inDays / 365.0; // en años
              if (tiempoRestanteAnios < tiempoContrato!) return false;
            }
          }
        } else {
          return false;
        }
      }
      
      if (cantidadContratos != null) {
        if (t.contratos.length != cantidadContratos) return false;
      }

      // Filtro por nombre
      if (textoBusqueda != null && textoBusqueda!.isNotEmpty) {
        if (!t.nombreCompleto.toLowerCase().contains(textoBusqueda!.toLowerCase())) return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void reiniciarFiltros() {
    obraAsignada = null;
    cargo = null;
    estadoCivil = null;
    rangoSueldo = null;
    rangoEdad = null;
    sistemaSalud = null;
    estadoEmpresa = null;
    textoBusqueda = null;

    estadoContrato = null;
    tiempoContrato = null;
    cantidadContratos = null;
    filtrar();
  }

  int _calcularEdad(DateTime fechaNacimiento) {
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }
}