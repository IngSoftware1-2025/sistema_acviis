import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/ui/views/trabajadores/trabajadores_view.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_estado_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';

class EliminarTrabajadorView extends StatefulWidget {
  final Object? trabajadores;
  const EliminarTrabajadorView({
    super.key,
    required this.trabajadores
  });
  @override
  State<EliminarTrabajadorView> createState() => _EliminarTrabajadorViewState();
}

class _EliminarTrabajadorViewState extends State<EliminarTrabajadorView> {
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
    final List<Trabajador> trabajadores = (widget.trabajadores as List).cast<Trabajador>();

    return PrimaryScaffold(
      title: 'Eliminar Trabajadores',
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: trabajadores.length,
              itemBuilder: (context, index) {
                final t = trabajadores[index];
                final bool isSelected = seleccionados.contains(index);
                String estadoActual = t.contratos.isNotEmpty
                    ? (t.contratos.last['estado']?.toString() ?? 'Sin estado')
                    : 'Sin estado';
                comentariosControllers.putIfAbsent(index, () => TextEditingController());
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(t.nombreCompleto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RUT: ${t.rut}'),
                        Text('Estado del contrato: $estadoActual'),
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
                                    comentariosControllers[index]?.clear(); // Limpia el comentario al deseleccionar
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
                                setState(() {}); // Para actualizar la validación del botón
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
                            final seleccionadosList = {
                              for (var t in seleccionados.map((i) => trabajadores[i])) t.rut: t
                            }.values.toList();
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Se cambiará el estado a "Eliminado" para:'),
                                    const SizedBox(height: 8),
                                    Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(1.5),
                                      },
                                      children: [
                                        const TableRow(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4),
                                              child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4),
                                              child: Text('RUT', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        ...seleccionadosList.map(
                                          (t) => TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                child: Text(t.nombreCompleto),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                child: Text(t.rut),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Esta operación hará que los trabajadores ya no se muestren en el sistema.\n¿Seguro quieres realizar los cambios?',
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
                                final t = trabajadores[i];
                                final comentario = comentariosControllers[i]?.text ?? '';
                                try {
                                  await crearComentario(
                                    idTrabajador: t.id.toString(),
                                    comentario: comentario,
                                    fecha: DateTime.now(),
                                    idContrato: null,
                                  );
                                  await actualizarEstadoTrabajador(t.id, 'Eliminado');
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al eliminar: $e')),
                                    );
                                  }
                                }
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Los trabajadores han sido eliminados con éxito')),
                                );
                                await Future.delayed(const Duration(seconds: 1));
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => TrabajadoresView()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                    child: const Text('Aceptar'),
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