import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/herramienta.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/update_herramienta.dart';

class ModificarHerramientasView extends StatefulWidget {
  final Object? herramientas; // Debería ser List<Herramienta>
  const ModificarHerramientasView({
    super.key,
    required this.herramientas,
  });

  @override
  State<ModificarHerramientasView> createState() => _ModificarHerramientasViewState();
}

class _ModificarHerramientasViewState extends State<ModificarHerramientasView> {
  @override
  Widget build(BuildContext context) {
    final List<Herramienta> herramientas = (widget.herramientas as List).cast<Herramienta>();

    // Controladores para cada herramienta y campo
    final List<Map<String, TextEditingController>> controllers = List.generate(
      herramientas.length,
      (i) {
        final h = herramientas[i];
        return {
          'tipo': TextEditingController(text: h.tipo),
          'garantia': TextEditingController(text: h.garantia != null ? h.garantia!.toIso8601String().split('T').first : ''),
          'cantidad_total': TextEditingController(text: h.cantidadTotal.toString()),
        };
      },
    );

    return PrimaryScaffold(
      title: 'Modificar Herramientas',
      body: ListView.builder(
        itemCount: herramientas.length,
        itemBuilder: (context, index) {
          final h = herramientas[index];
          final c = controllers[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text(h.tipo),
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
                          controller: c['tipo'],
                          decoration: const InputDecoration(labelText: 'Tipo'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['garantia'],
                          decoration: const InputDecoration(labelText: 'Garantía (YYYY-MM-DD)'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: c['cantidad_total'],
                          decoration: const InputDecoration(labelText: 'Cantidad Total'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          // Validación simple
                          if (c['tipo']!.text.isEmpty || c['cantidad_total']!.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Completa los campos obligatorios')),
                            );
                            return;
                          }
                          // Validar cantidad
                          if (int.tryParse(c['cantidad_total']!.text) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cantidad debe ser un número')),
                            );
                            return;
                          }
                          // Validar fechas (opcional)
                          if (c['garantia']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(c['garantia']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Garantía: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                          }
                          final herramientaData = {
                            'id': h.id,
                            'tipo': c['tipo']!.text,
                            'garantia': c['garantia']!.text.isNotEmpty 
                                ? DateTime.parse(c['garantia']!.text).toUtc().toIso8601String() 
                                : null,
                            'cantidad_total': int.parse(c['cantidad_total']!.text),
                          };

                          await updateHerramienta(herramientaData);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Herramienta actualizada')),
                          );
                          setState(() {});
                        },
                        child: const Text('Guardar cambios'),
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