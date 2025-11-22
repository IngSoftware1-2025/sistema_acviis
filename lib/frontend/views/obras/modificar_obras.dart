import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/models/obra.dart';
import 'package:sistema_acviis/backend/controllers/obras/update_obras.dart';

class ModificarObrasView extends StatefulWidget {
  final List<dynamic> obras;
  const ModificarObrasView({
    super.key,
    required this.obras,
    });

  @override
  State<ModificarObrasView> createState() => _ModificarObrasViewState();
}

class _ModificarObrasViewState extends State<ModificarObrasView> {
  @override
  Widget build(BuildContext context) {
    final List<dynamic> obras = (widget.obras).cast<Obra>();

    final List<Map<String, TextEditingController>> controllers = List.generate(
      obras.length,
      (i) {
        final h = obras[i];
        return {
          'nombre': TextEditingController(text: h.nombre),
          'descripcion': TextEditingController(text: h.descripcion ?? ''),
          'responsableEmail': TextEditingController(text: h.responsableEmail ?? ''),
          'direccion': TextEditingController(text: h.direccion),
          'obraInicio': TextEditingController(text: h.obraInicio?.toIso8601String() ?? ''),
          'obraFin': TextEditingController(text: h.obraFin?.toIso8601String() ?? ''),
          'jornada': TextEditingController(text: h.jornada ?? ''),
        };
      },
    );



    return PrimaryScaffold(
      title: 'Modificar Obras',
      body: ListView.builder(
        itemCount: obras.length,
        itemBuilder: (context, index) {
          final obra = obras[index];
          final obraControllers = controllers[index];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modificar Obra ID: ${obra.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: obraControllers['nombre'],
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: obraControllers['descripcion'],
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: obraControllers['responsableEmail'],
                    decoration: const InputDecoration(labelText: 'Responsable Email'),
                  ),
                  TextField(
                    controller: obraControllers['direccion'],
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  TextField(
                    controller: obraControllers['obraInicio'],
                    decoration: const InputDecoration(labelText: 'Obra Inicio (YYYY-MM-DD)'),
                  ),
                  TextField(
                    controller: obraControllers['obraFin'],
                    decoration: const InputDecoration(labelText: 'Obra Fin (YYYY-MM-DD)'),
                  ),
                  TextField(
                    controller: obraControllers['jornada'],
                    decoration: const InputDecoration(labelText: 'Jornada'),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final camposObligatorios = [
                        obraControllers['nombre']!,
                        obraControllers['direccion']!,
                      ];
                      final algunoVacio = camposObligatorios.any((c) => c.text.isEmpty);
                      if (algunoVacio) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, completa todos los campos obligatorios.')),
                        );
                        return;
                      }
                      if (obraControllers['obraInicio']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(obraControllers['obraInicio']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Obra Inicio: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                      }
                      if (obraControllers['obraFin']!.text.isNotEmpty) {
                            try {
                              DateTime.parse(obraControllers['obraFin']!.text);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Obra Fin: Formato de fecha inválido (YYYY-MM-DD)')),
                              );
                              return;
                            }
                      }
                      final obraData = {
                        'id': obra.id,  // Agregamos el ID de la obra
                        'nombre': obraControllers['nombre']!.text,
                        'descripcion': obraControllers['descripcion']!.text,
                        'responsable_email': obraControllers['responsableEmail']!.text,
                        'direccion': obraControllers['direccion']!.text,
                        'obraInicio': obraControllers['obraInicio']!.text,
                        'obraFin': obraControllers['obraFin']!.text,
                        'jornada': obraControllers['jornada']!.text,
                      };
                      await updateObras(obraData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Obra actualizada exitosamente')),
                      );
                      setState(() {});
                    },
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}