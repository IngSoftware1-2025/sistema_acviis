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
  late TextEditingController direccionController;
  late TextEditingController correoController;
  late TextEditingController sistemaSaludController;
  late TextEditingController previsionAfpController;
  late TextEditingController obraController;
  late TextEditingController rolController;

  // Controladores para contratos
  late List<Map<String, TextEditingController>> contratosControllers;

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

    contratosControllers = widget.trabajador.contratos.map<Map<String, TextEditingController>>((contrato) {
      return {
        'plazo': TextEditingController(text: contrato['plazo_de_contrato'] ?? ''),
        'estado': TextEditingController(text: contrato['estado'] ?? ''),
        'comentario': TextEditingController(text: contrato['comentario_adicional_acerca_del_trabajador'] ?? ''),
        'documento': TextEditingController(text: contrato['documento_de_vacaciones_del_trabajador'] ?? ''),
      };
    }).toList();
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
    for (var map in contratosControllers) {
      for (var c in map.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar trabajador y contratos'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Datos del trabajador ---
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
              const SizedBox(height: 16),
              // --- Contratos vinculados ---
              const Text('Contratos vinculados', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(widget.trabajador.contratos.length, (i) {
                final contrato = widget.trabajador.contratos[i];
                final ctrls = contratosControllers[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${contrato['id'] ?? '-'}'),
                        TextFormField(
                          controller: ctrls['plazo'],
                          decoration: const InputDecoration(labelText: 'Plazo de contrato'),
                        ),
                        DropdownButtonFormField<String>(
                          value: (ctrls['estado']!.text == 'Activo' || ctrls['estado']!.text == 'Inactivo')
                              ? ctrls['estado']!.text
                              : null, // Si el estado actual no es válido, deja vacío
                          items: const [
                            DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                            DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                          ],
                          onChanged: (value) {
                            ctrls['estado']!.text = value ?? '';
                            setState(() {});
                          },
                          decoration: const InputDecoration(labelText: 'Estado'),
                        ),
                        TextFormField(
                          controller: ctrls['documento'],
                          decoration: const InputDecoration(labelText: 'Documento de vacaciones del trabajador'),
                        ),
                        TextFormField(
                          controller: ctrls['comentario'],
                          decoration: const InputDecoration(labelText: 'Comentario adicional'),
                        ),
                        
                      ],
                    ),
                  ),
                );
              }),
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
            // Retorna los datos editados, sin actualizar aún
            Navigator.pop(context, {
              'trabajador': {
                'nombre_completo': nombreCompletoController.text,
                'estado_civil': estadoCivilController.text,
                'direccion': direccionController.text,
                'correo_electronico': correoController.text,
                'sistema_de_salud': sistemaSaludController.text,
                'prevision_afp': previsionAfpController.text,
                'obra_en_la_que_trabaja': obraController.text,
                'rol_que_asume_en_la_obra': rolController.text,
              },
              'contratos': List.generate(widget.trabajador.contratos.length, (i) {
                final ctrls = contratosControllers[i];
                return {
                  'id': widget.trabajador.contratos[i]['id'],
                  'plazo_de_contrato': ctrls['plazo']!.text,
                  'estado': ctrls['estado']!.text,
                  'comentario_adicional_acerca_del_trabajador': ctrls['comentario']!.text,
                  'documento_de_vacaciones_del_trabajador': ctrls['documento']!.text,
                };
              }),
            });
          }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}