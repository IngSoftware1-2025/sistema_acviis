import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/get_trabajadores.dart';

class TrabajadoresProvider extends ChangeNotifier {
  List<Trabajador> _todos = [];
  List<Trabajador> _trabajadores = [];
  List<Trabajador> get trabajadores => _trabajadores;

  // Filtros
  String? obraAsignada;
  String? cargo;
  int? tiempoContrato; // en años
  String? estadoCivil;
  RangeValues? rangoSueldo;
  RangeValues? rangoEdad;
  String? sistemaSalud;
  String? estadoEmpresa;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTrabajadores() async {
    _isLoading = true;
    notifyListeners();

    _todos = await fetchTrabajadoresFromApi();
    _trabajadores = List.from(_todos);

    _isLoading = false;
    notifyListeners();
  }

  void actualizarFiltros({
    String? obraAsignada,
    String? cargo,
    int? tiempoContrato, // en años
    String? estadoCivil,
    RangeValues? rangoSueldo,
    RangeValues? rangoEdad,
    String? sistemaSalud,
    String? estadoEmpresa,
  }) {
    this.obraAsignada = obraAsignada ?? this.obraAsignada;
    this.cargo = cargo ?? this.cargo;
    this.tiempoContrato = tiempoContrato ?? this.tiempoContrato;
    this.estadoCivil = estadoCivil ?? this.estadoCivil;
    this.rangoSueldo = rangoSueldo ?? this.rangoSueldo;
    this.rangoEdad = rangoEdad ?? this.rangoEdad;
    this.sistemaSalud = sistemaSalud ?? this.sistemaSalud;
    this.estadoEmpresa = estadoEmpresa ?? this.estadoEmpresa;
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
      if (estadoEmpresa != null && estadoEmpresa!.isNotEmpty) {
        // Busca el contrato activo (o el más reciente si no hay activo)
        final contrato = t.contratos.firstWhere(
          (c) => c['estado'] == estadoEmpresa,
          orElse: () => null,
        );
        if (contrato == null) return false;
      }
      // Edad
      if (rangoEdad != null) {
        final edad = _calcularEdad(t.fechaDeNacimiento);
        if (edad < rangoEdad!.start || edad > rangoEdad!.end) return false;
      }
      // Sueldo (si tienes el campo sueldo en tu modelo, descomenta y ajusta)
      // if (rangoSueldo != null && t.sueldo != null) {
      //   if (t.sueldo < rangoSueldo!.start * 1000000 || t.sueldo > rangoSueldo!.end * 1000000) return false;
      // }
      // Tiempo de contrato (calcula el tiempo restante del contrato activo en años)
      if (tiempoContrato != null && t.contratos.isNotEmpty) {
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
        }
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void reiniciarFiltros() {
    obraAsignada = null;
    cargo = null;
    tiempoContrato = null;
    estadoCivil = null;
    rangoSueldo = null;
    rangoEdad = null;
    sistemaSalud = null;
    estadoEmpresa = null;
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