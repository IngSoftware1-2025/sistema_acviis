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
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/ui/views/trabajadores/func/descargar_anexo_pdf.dart';

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ID Contrato (solo visualización)
                  Center(child: Text('Anexo asociado a contrato activo')),
                  SizedBox(height: 8),
                  // Duración
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: _fechaInicio == null ? '' : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'),
                          decoration: InputDecoration(
                            labelText: 'Fecha Inicio',
                            hintText: 'dd/mm/yyyy',
                          ),
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaInicio ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (fecha != null) {
                              setState(() {
                                _fechaInicio = fecha;
                                _showDuracionError = !_validarDuracionVacaciones(_duracionFormateada);
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: _fechaFin == null ? '' : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'),
                          decoration: InputDecoration(
                            labelText: 'Fecha Fin',
                            hintText: 'dd/mm/yyyy',
                          ),
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaFin ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (fecha != null) {
                              setState(() {
                                _fechaFin = fecha;
                                _showDuracionError = !_validarDuracionVacaciones(_duracionFormateada);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Tipo (dropdown si no es vacaciones, fijo si es vacaciones)
                  widget.tipoVacaciones
                    ? TextFormField(
                        controller: _tipoAnexoController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Anexo',
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _tipoAnexoController.text.isNotEmpty ? _tipoAnexoController.text : null,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Anexo',
                        ),
                        items: [
                          'Anexo de salida o traslado',
                          'Anexo de Horas extras',
                          'Anexo de jornada laboral o pacto de obra',
                          'Anexo de sueldo',
                          'Anexo de cargo',
                        ].map((tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoAnexoController.text = value ?? '';
                          });
                        },
                      ),
                  SizedBox(height: 8),
                  // Parámetros (deshabilitado)
                  TextField(
                    controller: _parametrosController..text = "Desconocidos",
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Parámetros',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _comentarioControler,
                    decoration: InputDecoration(
                      labelText: 'Comentario',
                    ),
                  ),
                ],
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
                  setState(() {
                    _isLoading = true;
                  });
                  Map<String, String> data = {
                    'id_trabajador': widget.idTrabajador,
                    'id_contrato': widget.idContrato,
                    'tipo': _tipoAnexoController.text,
                    'duracion': _duracionFormateada,
                    'parametros': _parametrosController.text,
                    'comentario': _comentarioControler.text,
                  };
                  try {
                    final idAnexo = await createAnexoSupabase(data);
                    if (idAnexo.isNotEmpty) {
                      Map<String, String> dataMongo = {
                        // Datos del trabajador
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
                        // Datos del anexo
                        'id_anexo': idAnexo,
                        'id_contrato': widget.idContrato,
                        'tipo': _tipoAnexoController.text,
                        'duracion': _duracionFormateada,
                        'parametros': _parametrosController.text,
                        'comentario': _comentarioControler.text,
                      };
                      await createAnexoMongo(dataMongo);
                      // Si es Documento de vacaciones, descargar y abrir PDF
                      if (widget.tipoVacaciones && idAnexo.isNotEmpty) {
                        await Future.delayed(const Duration(milliseconds: 500)); // IMPORTANTE PARA LA VISUALIZACIÓN DEL PDF: Espera para GridFS
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
                    });
                  }
                },
                child: Text('Guardar'),
              ),
            ],
    );
  }
}