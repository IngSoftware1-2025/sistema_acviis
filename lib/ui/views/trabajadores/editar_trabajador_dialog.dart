import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

class EditarTrabajadorDialog extends StatefulWidget {
  final Trabajador trabajador;
  const EditarTrabajadorDialog({super.key, required this.trabajador});

  @override
  State<EditarTrabajadorDialog> createState() => _EditarTrabajadorDialogState();
}

class _EditarTrabajadorDialogState extends State<EditarTrabajadorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreCompletoController;
  late TextEditingController estadoCivilController;
  late TextEditingController rutController;
  late TextEditingController fechaNacimientoController;
  late TextEditingController direccionController;
  late TextEditingController correoController;
  late TextEditingController sistemaSaludController;
  late TextEditingController previsionAfpController;
  late TextEditingController obraController;
  late TextEditingController rolController;
  late TextEditingController estadoTrabajadorController;

  @override
  void initState() {
    super.initState();
    nombreCompletoController = TextEditingController(text: widget.trabajador.nombreCompleto);
    estadoCivilController = TextEditingController(text: widget.trabajador.estadoCivil);
    rutController = TextEditingController(text: widget.trabajador.rut);
    fechaNacimientoController = TextEditingController(text: widget.trabajador.fechaDeNacimiento.toIso8601String().split('T').first);
    direccionController = TextEditingController(text: widget.trabajador.direccion);
    correoController = TextEditingController(text: widget.trabajador.correoElectronico);
    sistemaSaludController = TextEditingController(text: widget.trabajador.sistemaDeSalud);
    previsionAfpController = TextEditingController(text: widget.trabajador.previsionAfp);
    obraController = TextEditingController(text: widget.trabajador.obraEnLaQueTrabaja);
    rolController = TextEditingController(text: widget.trabajador.rolQueAsumeEnLaObra);
    estadoTrabajadorController = TextEditingController(text: widget.trabajador.estadoTrabajador);
  }

  @override
  void dispose() {
    nombreCompletoController.dispose();
    estadoCivilController.dispose();
    rutController.dispose();
    fechaNacimientoController.dispose();
    direccionController.dispose();
    correoController.dispose();
    sistemaSaludController.dispose();
    previsionAfpController.dispose();
    obraController.dispose();
    rolController.dispose();
    estadoTrabajadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar trabajador'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCompletoController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: estadoCivilController,
                decoration: const InputDecoration(labelText: 'Estado civil'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: rutController,
                decoration: const InputDecoration(labelText: 'RUT'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: fechaNacimientoController,
                decoration: const InputDecoration(labelText: 'Fecha de nacimiento (YYYY-MM-DD)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obligatorio';
                  try {
                    DateTime.parse(v);
                  } catch (_) {
                    return 'Formato inválido (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: correoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: sistemaSaludController,
                decoration: const InputDecoration(labelText: 'Sistema de salud'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: previsionAfpController,
                decoration: const InputDecoration(labelText: 'Previsión AFP'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: obraController,
                decoration: const InputDecoration(labelText: 'Obra en la que trabaja'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: rolController,
                decoration: const InputDecoration(labelText: 'Rol que asume en la obra'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: estadoTrabajadorController,
                decoration: const InputDecoration(labelText: 'Estado trabajador'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nombre_completo': nombreCompletoController.text,
                'estado_civil': estadoCivilController.text,
                'rut': rutController.text,
                'fecha_de_nacimiento': fechaNacimientoController.text,
                'direccion': direccionController.text,
                'correo_electronico': correoController.text,
                'sistema_de_salud': sistemaSaludController.text,
                'prevision_afp': previsionAfpController.text,
                'obra_en_la_que_trabaja': obraController.text,
                'rol_que_asume_en_la_obra': rolController.text,
                'estado_trabajador': estadoTrabajadorController.text,
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}