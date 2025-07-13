import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/backend/controllers/contratos/actualizar_estado_contrato.dart';

Future<void> actualizarContrato(String idContrato, {required String estado, String? comentario}) async {
  debugPrint('Contrato $idContrato actualizado a estado "$estado" con comentario: $comentario');
}

class EliminarContratosView extends StatefulWidget {
  final List<dynamic> trabajadoresSeleccionados;
  const EliminarContratosView({
    super.key,
    required this.trabajadoresSeleccionados,
  });

  @override
  State<EliminarContratosView> createState() => _EliminarContratosViewState();
}

class _EliminarContratosViewState extends State<EliminarContratosView> {
  final Set<int> seleccionados = {};
  final Map<int, TextEditingController> comentariosControllers = {};

  bool get comentariosValidos {
    for (final i in seleccionados) {
      if (comentariosControllers[i]?.text.trim().isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    for (final controller in comentariosControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  // Filtra solo los trabajadores que tienen al menos un contrato distinto a "Reemplazado"
  final List<dynamic> trabajadoresFiltrados = widget.trabajadoresSeleccionados.where((trabajador) {
    if (trabajador.contratos == null || trabajador.contratos.isEmpty) return false;
    return trabajador.contratos.any((contrato) => contrato['estado'] != 'Reemplazado');
  }).toList();

  return PrimaryScaffold(
    title: 'Eliminar Contratos',
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: trabajadoresFiltrados.length,
            itemBuilder: (context, index) {
              final trabajador = trabajadoresFiltrados[index];
              final bool isSelected = seleccionados.contains(index);
              comentariosControllers.putIfAbsent(index, () => TextEditingController());
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Trabajador: ${trabajador != null && trabajador.nombreCompleto != null ? trabajador.nombreCompleto : "-"}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  seleccionados.add(index);
                                } else {
                                  seleccionados.remove(index);
                                  comentariosControllers[index]?.clear();
                                }
                              });
                            },
                          ),
                          const Text('Marcar para eliminar'),
                        ],
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField(
                            controller: comentariosControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Comentario adicional acerca del trabajador',
                              errorText: (comentariosControllers[index]?.text.trim().isEmpty ?? true)
                                  ? 'El comentario es obligatorio'
                                  : null,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                            maxLines: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (seleccionados.isEmpty || !comentariosValidos)
                      ? null
                      : () async {
                          final seleccionadosList = [
                            for (var i in seleccionados) trabajadoresFiltrados[i]
                          ];
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar actualización'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Se marcarán como "Reemplazado" los contratos activos de los siguientes trabajadores:'),
                                  const SizedBox(height: 8),
                                  ...seleccionadosList.map(
                                    (t) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text('${t.nombreCompleto ?? "-"}'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    '¿Seguro quieres realizar los cambios?',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final seleccionadosCopia = List<int>.from(seleccionados);
                            setState(() {
                              seleccionados.clear();
                            });
                            for (final i in seleccionadosCopia) {
                              final trabajador = trabajadoresFiltrados[i];
                              final comentario = comentariosControllers[i]?.text ?? '';
                              // Recorre los contratos del trabajador y actualiza el estado si corresponde
                              if (trabajador.contratos != null) {
                                for (final contrato in trabajador.contratos) {
                                  if (contrato['estado'] != 'Reemplazado') {
                                    // Cambia el estado en memoria
                                    contrato['estado'] = 'Reemplazado';

                                    // Llama a la función para actualizar en backend
                                    await actualizarEstadoContrato(
                                      contrato['id'].toString(),
                                      'Reemplazado',
                                    );
                                    await crearComentario(
                                      idContrato: contrato['id'].toString(),
                                      comentario: comentario,
                                      idTrabajador: trabajador.id.toString(),
                                      fecha: DateTime.now(),
                                    );
                                    debugPrint('Contrato ${contrato['id']} del trabajador ${trabajador.nombreCompleto} actualizado a "Reemplazado"');
                                  } else {
                                    debugPrint('Contrato ${contrato['id']} del trabajador ${trabajador.nombreCompleto} ya estaba en estado "Reemplazado"');
                                  }
                                }
                              }
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contratos actualizados a "Reemplazado" con éxito')),
                              );
                              await Future.delayed(const Duration(seconds: 1));
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home_page/trabajadores_view',
                                (route) => false,
                              );
                            }
                          }
                        },
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}