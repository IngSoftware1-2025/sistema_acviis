import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_trabajador.dart';

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
  late TextEditingController direccionController;
  late TextEditingController correoController;
  late TextEditingController sistemaSaludController;
  late TextEditingController previsionAfpController;
  late TextEditingController obraController;
  late TextEditingController rolController;
  late TextEditingController estadoController;

  @override
  void initState() {
    super.initState();
    nombreCompletoController = TextEditingController(text: widget.trabajador.nombreCompleto);
    estadoCivilController = TextEditingController(text: widget.trabajador.estadoCivil);
    direccionController = TextEditingController(text: widget.trabajador.direccion);
    correoController = TextEditingController(text: widget.trabajador.correoElectronico);
    sistemaSaludController = TextEditingController(text: widget.trabajador.sistemaDeSalud);
    previsionAfpController = TextEditingController(text: widget.trabajador.previsionAfp);
    obraController = TextEditingController(text: widget.trabajador.obraEnLaQueTrabaja);
    rolController = TextEditingController(text: widget.trabajador.rolQueAsumeEnLaObra);
    estadoController = TextEditingController(text: widget.trabajador.estado);
  }

  @override
  void dispose() {
    nombreCompletoController.dispose();
    estadoCivilController.dispose();
    direccionController.dispose();
    correoController.dispose();
    sistemaSaludController.dispose();
    previsionAfpController.dispose();
    obraController.dispose();
    rolController.dispose();
    estadoController.dispose();
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
              DropdownButtonFormField<String>(
                value: estadoController.text.isNotEmpty ? estadoController.text : null,
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    estadoController.text = value;
                  }
                  setState(() {});
                },
                decoration: const InputDecoration(labelText: 'Estado'),
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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final trabajadorData = {
                'nombre_completo': nombreCompletoController.text,
                'estado_civil': estadoCivilController.text,
                'direccion': direccionController.text,
                'correo_electronico': correoController.text,
                'sistema_de_salud': sistemaSaludController.text,
                'prevision_afp': previsionAfpController.text,
                'obra_en_la_que_trabaja': obraController.text,
                'rol_que_asume_en_la_obra': rolController.text,
                'estado': estadoController.text,
              };

              final confirmacion = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Resumen de cambios'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Datos del trabajador:'),
                        ...trabajadorData.entries.map((e) => Text('${e.key}: ${e.value}')),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );

              if (confirmacion == true) {
                try {
                  await actualizarTrabajador(widget.trabajador.id, trabajadorData);
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar cambios: $e')),
                    );
                  }
                }
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}