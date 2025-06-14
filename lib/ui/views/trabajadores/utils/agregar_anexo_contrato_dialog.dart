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

class AgregarAnexoContratoDialog extends StatefulWidget {
  final dynamic idContrato;
  final String idTrabajador;
  final Trabajador trabajador;
  const AgregarAnexoContratoDialog({
    super.key,
    required this.idContrato,
    required this.idTrabajador,
    required this.trabajador,
  });
  @override
  State<AgregarAnexoContratoDialog> createState() => _AgregarAnexoContratoDialogState();
}

class _AgregarAnexoContratoDialogState extends State<AgregarAnexoContratoDialog> {
  final TextEditingController _tipoAnexoController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _parametrosController = TextEditingController();
  final TextEditingController _comentarioControler = TextEditingController();

  @override
  void dispose() {
    _tipoAnexoController.dispose();
    _duracionController.dispose();
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ID Contrato (solo visualización)
            Center(child: Text('Anexo asociado a contrato activo')),
            SizedBox(height: 8),
            // Duración
            TextField(
              controller: _duracionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Duración',
                hintText: 'Ingrese la duración',
              ),
            ),
            SizedBox(height: 8),
            // Tipo (Dropdown)
            DropdownButtonFormField<String>(
              value: null,
              decoration: InputDecoration(
                labelText: 'Tipo de Anexo',
              ),
              items: [
                'Anexo de salida o traslado',
                'Anexo de Horas extras',
                'Anexo de jornada laboral o pacto de obra',
                'Anexo de sueldo',
                'Anexo de cargo',
                'Documento de vacaciones'
              ].map((tipo) => DropdownMenuItem(
                value: tipo,
                child: Text(tipo),
              )).toList(),
              onChanged: (value) {
                _tipoAnexoController.text = value ?? '';
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Map<String, String> data = {
              'id_trabajador' : widget.idTrabajador,
              'id_contrato' : widget.idContrato,
              'tipo': _tipoAnexoController.text,
              'duracion': _duracionController.text,
              'parametros': _parametrosController.text,
              'comentario': _comentarioControler.text,
            };
            if (await createAnexoSupabase(data)) {
              Map<String, String> data = {
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
              'id_contrato': widget.idContrato,
              'tipo' : _tipoAnexoController.text,
              'duracion' : _duracionController.text,
              'parametros': _parametrosController.text,
              'comentario': _comentarioControler.text,
              };
              //createAnexoMongo(data);
            }
            if (mounted) {
              Navigator.of(this.context).pop();
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}