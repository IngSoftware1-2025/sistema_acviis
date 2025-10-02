/*
  id
  id_contrato
  fecha_de_creacion
  duracion
  tipo : (Anexo de salida o traslado
          Anexo de Horas extras
          Anexo de jornada laboral o pacto de obra
          Anexo de sueldo
          Anexo de cargo)
  Parametros: (Temportalmente: "Desconocidos" en una casilla de texto desabilitada)
    Pero seran un Json: { params : values }, el como se trabajaran mas adelante por controladores unicos
  comentario: COnexion con tabla comentario agregandole id_anexo posiblemente null (No deberia romper nada)
*/

import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/anexos/create_anexo.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/jornada_laboral.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/maestro_a_cargo.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/reajuste_de_sueldo.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/pacto_horas_extraordinarias.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/salida_de_la_obra.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/anexos/traslado.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/descargar_anexo_pdf.dart';

List<String> ANEXOS = [
  'Anexo Jornada Laboral',
  'Anexo Reajuste de Sueldo',
  'Anexo Maestro a cargo',
  'Anexo Salida de la obra',
  'Anexo Traslado',
  'Formulario Pacto Horas extraordinarias',
  'Documento de vacaciones'
];

// Nuevo: Mapa de controladores para campos dinámicos
final Map<String, TextEditingController> _camposControllers = {};

// Nuevo: Mapa de funciones que reciben trabajador y controladores
final Map<String, List<Widget> Function(Trabajador, Map<String, TextEditingController>)> camposPorTipo = {
  'Anexo Jornada Laboral': (trabajador, controllers) => camposJornadaLaboral(trabajador, controllers),
  'Anexo Reajuste de Sueldo': (trabajador, controllers) => camposReajusteDeSueldo(trabajador, controllers),
  'Anexo Maestro a cargo': (trabajador, controllers) => camposMaestroACargo(trabajador, controllers),
  'Anexo Salida de la obra': (trabajador, controllers) => camposSalidaDeLaObra(trabajador, controllers),
  'Anexo Traslado': (trabajador, controllers) => camposTraslado(trabajador, controllers),
  'Formulario Pacto Horas extraordinarias': (trabajador, controllers) => camposPactoHorasExtraordinarias(trabajador, controllers),
  'Documento de vacaciones': (trabajador, controllers) => [],
};

class AgregarAnexoContratoDialog extends StatefulWidget {
  final dynamic idContrato;
  final String idTrabajador;
  final Trabajador trabajador;
  final bool tipoVacaciones;
  const AgregarAnexoContratoDialog({
    super.key,
    required this.idContrato,
    required this.idTrabajador,
    required this.trabajador,
    this.tipoVacaciones = false,
  });
  @override
  State<AgregarAnexoContratoDialog> createState() => _AgregarAnexoContratoDialogState();
}

class _AgregarAnexoContratoDialogState extends State<AgregarAnexoContratoDialog> {
  // Key para el formulario dinámico
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _tipoAnexoController;
  final TextEditingController _parametrosController = TextEditingController();
  final TextEditingController _comentarioControler = TextEditingController();

  bool _isLoading = false;
  bool _showDuracionError = false;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;


  String get _duracionFormateada {
    if (_fechaInicio == null || _fechaFin == null) return '';
    String format(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${format(_fechaInicio!)} – ${format(_fechaFin!)}';
  }

  // Funcion que validara si las fechas de vacaciones son validas
  bool _validarDuracionVacaciones(String value) {
    // Formato: dd/mm/yyyy – dd/mm/yyyy 
    final regex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4}) – (\d{2})\/(\d{2})\/(\d{4})$');
    final match = regex.firstMatch(value.trim());
    if (match == null) return false;
    try {
      final d1 = int.parse(match.group(1)!);
      final m1 = int.parse(match.group(2)!);
      final y1 = int.parse(match.group(3)!);
      final d2 = int.parse(match.group(4)!);
      final m2 = int.parse(match.group(5)!);
      final y2 = int.parse(match.group(6)!);
      final fechaInicio = DateTime(y1, m1, d1);
      final fechaFin = DateTime(y2, m2, d2);
      // Verifica que las fechas sean válidas y que inicio <= fin
      if (fechaInicio.isAfter(fechaFin)) return false;
      // Verifica que los días y meses sean válidos (por si DateTime autocorrige)
      if (fechaInicio.day != d1 || fechaInicio.month != m1 || fechaFin.day != d2 || fechaFin.month != m2) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _tipoAnexoController = TextEditingController(
      text: widget.tipoVacaciones ? 'Documento de vacaciones' : '',
    );
  }

  @override
  void dispose() {
    _tipoAnexoController.dispose();
    _parametrosController.dispose();
    _comentarioControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Aqui se define si se PUEDE o no realizar un anexo a un contrato
    if (widget.idContrato == null) {
      return AlertDialog( // ===================== Sin contrato activo
        title: Text('Sin contrato activo'),
        content: Text('El trabajador no tiene un contrato activo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      );
    }
    // Aqui comienza la creacion de anexo
    return AlertDialog(
      title: Center(
        child: Text(
          'Agregar Anexo al Contrato',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      content: _isLoading
          ? SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipoAnexoController.text.isNotEmpty ? _tipoAnexoController.text : null,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Anexo',
                      ),
                      items: ANEXOS.map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoAnexoController.text = value ?? '';
                        });
                      },
                    ),
                    ...(_tipoAnexoController.text.isNotEmpty && camposPorTipo[_tipoAnexoController.text] != null
                      ? (camposPorTipo[_tipoAnexoController.text]!(widget.trabajador, _camposControllers).isNotEmpty
                          ? camposPorTipo[_tipoAnexoController.text]!(widget.trabajador, _camposControllers)
                          : [
                              TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'No se ha podido discutir el formato hasta el momento',
                                  hintText: 'No se ha podido discutir el formato hasta el momento',
                                ),
                              ),
                            ]
                        )
                      : []),
                  ],
                ),
              ),
            ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: (widget.tipoVacaciones && _showDuracionError)
                    ? null
                    : () async {
                  // Validar el formulario dinámico
                  if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor, completa correctamente todos los campos obligatorios.')),
                    );
                    return;
                  }
                  // Validación personalizada de 40 horas para jornada laboral
                  if (_tipoAnexoController.text == 'Anexo Jornada Laboral') {
                    final error = validar40HorasJornada(_camposControllers);
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                      return;
                    }
                  }
                  setState(() {
                    _isLoading = true;
                  });
                  // ...existing code for guardar...
                  Map<String, String> parametros = {
                    'tipo': _tipoAnexoController.text,
                  };
                  final camposExtras = _camposControllers.entries.where((e) => e.key != "comentario" && e.key != "tipo").toList();
                  if (camposExtras.isEmpty) {
                    parametros.addAll({
                      'id': widget.trabajador.id,
                      'nombre_completo': widget.trabajador.nombreCompleto,
                      'estado_civil': widget.trabajador.estadoCivil,
                      'rut': widget.trabajador.rut,
                      'fecha_de_nacimiento': widget.trabajador.fechaDeNacimiento.toIso8601String(),
                      'direccion': widget.trabajador.direccion,
                      'correo_electronico': widget.trabajador.correoElectronico,
                      'sistema_de_salud': widget.trabajador.sistemaDeSalud,
                      'prevision_afp': widget.trabajador.previsionAfp,
                      'obra_en_la_que_trabaja': widget.trabajador.obraEnLaQueTrabaja,
                      'rol_que_asume_en_la_obra': widget.trabajador.rolQueAsumeEnLaObra,
                      'estado': widget.trabajador.estado,
                    });
                  } else {
                    for (var entry in camposExtras) {
                      if (entry.value.text != '') parametros[entry.key] = entry.value.text;
                    }
                  }
                  try {
                    final idAnexo = await createAnexoSupabase(
                      _tipoAnexoController.text,
                      widget.idTrabajador,
                      widget.idContrato,
                      parametros,
                      _camposControllers['comentario']?.text ?? ''
                    );
                    if (idAnexo.isNotEmpty) {
                      Map<String, dynamic> dataMongo = {
                        'id_contrato': widget.idContrato,
                        'id_anexo': idAnexo,
                        'parametros': parametros,
                      };
                      await createAnexoMongo(dataMongo);
                      if (idAnexo.isNotEmpty) {
                        await Future.delayed(const Duration(milliseconds: 500));
                        await descargarAnexoPDF(context, idAnexo);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Anexo guardado correctamente.')),
                        );
                        Provider.of<TrabajadoresProvider>(this.context, listen: false).fetchTrabajadores();
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(this.context).pop();
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Error al guardar el anexo.')),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Ocurrió un error: $e')),
                      );
                    }
                  }
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      for (var controller in _camposControllers.values) {
                        controller.dispose();
                      }
                      _camposControllers.clear();
                      _comentarioControler.clear();
                    });
                  }
                },
                child: Text('Guardar'),
              ),
            ],
    );
  }
}