import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/vehiculos/update_vehiculo.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/models/vehiculo.dart';

class ModificarVehiculosView extends StatefulWidget {
  final Object? vehiculos; 
  const ModificarVehiculosView({
    super.key,
    required this.vehiculos,
  });

  @override
  State<ModificarVehiculosView> createState() => _ModificarVehiculosViewState();
}

class _ModificarVehiculosViewState extends State<ModificarVehiculosView> {
  @override
  Widget build(BuildContext context) {
    final List<Vehiculo> vehiculos = (widget.vehiculos as List).cast<Vehiculo>();


    final List<Map<String, TextEditingController>> controllers = List.generate(
      vehiculos.length,
      (i) {
        final h = vehiculos[i];
        return {
          'patente': TextEditingController(text: h.patente),
          'permiso_circ': TextEditingController(text: h.permisoCirc),
          'revision_tecnica': TextEditingController(text: h.revisionTecnica.toIso8601String().split('T').first),
          'revision_gases': TextEditingController(text: h.revisionGases.toIso8601String().split('T').first),
          'ultima_mantencion': TextEditingController(text: h.ultimaMantencion.toIso8601String().split('T').first),
          'descripcion_mant': TextEditingController(text: h.descripcionMant ?? ''),
          'capacidad_kg': TextEditingController(text: h.capacidadKg.toString()),
          'neumaticos': TextEditingController(text: h.neumaticos),
          'rueda_repuesto': TextEditingController(text: h.ruedaRepuesto.toString()),
          'observaciones': TextEditingController(text: h.observaciones ?? ''),
          'proxima_mantencion': TextEditingController(text: h.proximaMantencion.toIso8601String().split('T').first),
          'tipo': TextEditingController(text: h.tipo),
        };
      },
    );


    return PrimaryScaffold(
      title: 'Modificar vehiculos',
      body: ListView.builder(
        itemCount: vehiculos.length,
        itemBuilder: (context, index) {
          final h = vehiculos[index];
          final c = controllers[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text(h.patente),
              subtitle: Text('ID: ${h.id}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['patente'],
                          decoration: const InputDecoration(labelText: 'Patente'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['permiso_circ'],
                          decoration: const InputDecoration(labelText: 'Permiso de Circulación'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['revision_tecnica'],
                          decoration: const InputDecoration(labelText: 'Revisión Técnica (AAAA-MM-DD)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['revision_gases'],
                          decoration: const InputDecoration(labelText: 'Revisión de Gases (AAAA-MM-DD)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['ultima_mantencion'],
                          decoration: const InputDecoration(labelText: 'Última Mantención (AAAA-MM-DD)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['descripcion_mant'],
                          decoration: const InputDecoration(labelText: 'Descripción Mantención'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['capacidad_kg'],
                          decoration: const InputDecoration(labelText: 'Capacidad (Kg)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['neumaticos'],
                          decoration: const InputDecoration(labelText: 'Neumáticos'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['rueda_repuesto'],
                          decoration: const InputDecoration(labelText: 'Rueda de Repuesto (true/false)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['observaciones'],
                          decoration: const InputDecoration(labelText: 'Observaciones'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['proxima_mantencion'],
                          decoration: const InputDecoration(labelText: 'Próxima Mantención (AAAA-MM-DD)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['tipo'],
                          decoration: const InputDecoration(labelText: 'Tipo de Vehículo'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final camposObligatorios = [
                            c['patente']!,
                            c['permiso_circ']!,
                            c['revision_tecnica']!,
                            c['revision_gases']!,
                            c['ultima_mantencion']!,
                            c['capacidad_kg']!,
                            c['neumaticos']!,
                            c['rueda_repuesto']!,
                            c['proxima_mantencion']!,
                            c['tipo']!,
                          ];
                          final algunoVacio = camposObligatorios.any((ctrl) => ctrl.text.isEmpty);
                          if (algunoVacio) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Completa los campos obligatorios')),
                            );
                            return;
                          }
                          if (int.tryParse(c['capacidad_kg']!.text) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Capacidad debe ser un número')),
                            );
                            return;
                          }
                          // Validar fechas
                          if (c['revision_tecnica']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(c['revision_tecnica']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Revisión técnica: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                          }
                          if (c['revision_gases']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(c['revision_gases']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Revisión de gases: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                          }
                          if (c['ultima_mantencion']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(c['ultima_mantencion']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Última mantención: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                          }
                          if (c['proxima_mantencion']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(c['proxima_mantencion']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Próxima mantención: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                          }
                          final vehiculoData = {
                            'id': h.id,
                            'patente': c['patente']!.text,
                            'permiso_circ': c['permiso_circ']!.text,
                            'revision_tecnica': c['revision_tecnica']!.text,
                            'revision_gases': c['revision_gases']!.text,
                            'ultima_mantencion': c['ultima_mantencion']!.text,
                            'descripcion_mant': c['descripcion_mant']!.text,
                            'capacidad_kg': int.parse(c['capacidad_kg']!.text),
                            'neumaticos': c['neumaticos']!.text,
                            'rueda_repuesto': c['rueda_repuesto']!.text.toLowerCase() == 'true',
                            'observaciones': c['observaciones']!.text,
                            'proxima_mantencion': c['proxima_mantencion']!.text,
                            'tipo': c['tipo']!.text,
                          };

                          await updateVehiculo(vehiculoData); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vehículo actualizado exitosamente')),
                          );
                          setState(() {});
                        },
                        child: const Text('Guardar Cambios'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}