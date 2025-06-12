import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/ui/widgets/checkbox.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/ui/widgets/expansion_tile.dart';
import 'package:sistema_acviis/ui/views/trabajadores/editar_trabajador_dialog.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_estado_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/contratos/actualizar_contrato.dart';
import 'package:sistema_acviis/backend/controllers/contratos/actualizar_estado_contrato.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';
import 'package:sistema_acviis/backend/controllers/contratos/create_contrato.dart';

class ListaTrabajadores extends StatefulWidget {
  const ListaTrabajadores({super.key});
  @override
  State<ListaTrabajadores> createState() => _ListaTrabajadoresState();
}

class _ListaTrabajadoresState extends State<ListaTrabajadores> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);
      trabajadoresProvider.fetchTrabajadores().then((_) {
        if (!mounted) return; // <-- Agregado
        Provider.of<CheckboxProvider>(context, listen: false)
            .setCheckBoxes(trabajadoresProvider.trabajadores.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrabajadoresProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();

    // --- SINCRONIZA LOS CHECKBOXES ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkboxProvider.checkBoxes.length != provider.trabajadores.length + 1) {
        checkboxProvider.setCheckBoxes(provider.trabajadores.length);
      }
    });

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.trabajadores.isEmpty) {
      return const Center(child: Text('No hay trabajadores para mostrar.'));
    }
    if (checkboxProvider.checkBoxes.length != (provider.trabajadores.length + 1)) {
      return const Center(child: CircularProgressIndicator());
    }
    final double tableWidth = MediaQuery.of(context).size.width > 600
        ? MediaQuery.of(context).size.width
        : 600;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: tableWidth - normalPadding * 2,
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0])),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                      'Lista de Trabajadores Registrados',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 0,
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Opciones', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const Divider(),
              // ExpansionTiles para cada trabajador usando PersonalizedExpansionTile
              ...List.generate(provider.trabajadores.length, (i) {
                final trabajador = provider.trabajadores[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[i + 1]),
                      Expanded(
                        child: PersonalizedExpansionTile(
                          trabajador: trabajador,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                                if (value == 'Eliminar') {
                                final comentarioController = TextEditingController();
                                bool comentarioInvalido = false;
                                /*
                                muestra un diálogo para confirmar la eliminación del trabajador
                                y solicita un comentario obligatorio sobre la eliminación
                                si el comentario es inválido, muestra un mensaje de error
                                */
                                final confirmacion = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) => AlertDialog(
                                    title: const Text('Eliminar trabajador'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      const Text(
                                        'Esta acción eliminará al trabajador del sistema.\n\n'
                                        'Por favor, ingresa un comentario obligatorio sobre la eliminación:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: comentarioController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                        labelText: 'Comentario acerca de la eliminación',
                                        errorText: comentarioInvalido ? 'El comentario es obligatorio' : null,
                                        border: const OutlineInputBorder(),
                                        ),
                                        onChanged: (_) {
                                        if (comentarioInvalido) {
                                          setState(() => comentarioInvalido = false);
                                        }
                                        },
                                      ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                      onPressed: () {
                                        if (comentarioController.text.trim().isEmpty) {
                                        setState(() => comentarioInvalido = true);
                                        return;
                                        }
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Eliminar'),
                                      ),
                                    ],
                                    ),
                                  );
                                  },
                                );
                                /*
                                aquí se confirma la eliminación del trabajador
                                y se muestra un diálogo de confirmación final
                                con los detalles del trabajador
                                a eliminar
                                */
                                if (confirmacion == true) {
                                  final confirmacionFinal = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '¿Está seguro que desea eliminar al siguiente trabajador del sistema?',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Table(
                                          columnWidths: const {
                                            0: IntrinsicColumnWidth(),
                                            1: FlexColumnWidth(),
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 4),
                                                  child: Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Text(trabajador.nombreCompleto ?? ''),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 4),
                                                  child: Text('RUT:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                                  child: Text(trabajador.rut ?? ''),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Comentario: ${comentarioController.text.trim()}',
                                          style: const TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Esta acción no se puede deshacer.',
                                        ),
                                      ],
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

                                  if (confirmacionFinal == true) {
                                    try {
                                      // Crea el comentario asociado al trabajador
                                      await crearComentario(
                                        idTrabajador: trabajador.id,
                                        comentario: comentarioController.text.trim(),
                                        fecha: DateTime.now(),
                                        idContrato: null,
                                      );
                                      // Actualiza el estado del trabajador a "Eliminado"
                                      await actualizarEstadoTrabajador(trabajador.id, 'Eliminado');
                                      await provider.fetchTrabajadores();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Trabajador eliminado correctamente')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al eliminar: $e')),
                                        );
                                      }
                                    }
                                  }
                                }
                              } else if (value == 'Modificar') {
                                final resultado = await showDialog(
                                  context: context,
                                  builder: (context) => EditarTrabajadorDialog(trabajador: trabajador),
                                );
                                if (resultado is Map<String, dynamic>) {
                                  final cambios = <String, Map<String, dynamic>>{};
                                  final nuevosDatos = resultado['trabajador'] as Map<String, dynamic>;
                                  final contratosNuevos = resultado['contratos'] as List<dynamic>? ?? [];

                                  // Compara datos del trabajador
                                  nuevosDatos.forEach((key, value) {
                                    final original = trabajador.toJson()[key];
                                    if (original != value) {
                                      cambios[key] = {'antes': original, 'despues': value};
                                    }
                                  });

                                  // Compara contratos
                                  for (int i = 0; i < contratosNuevos.length; i++) {
                                    final contratoOriginal = trabajador.contratos[i];
                                    final contratoNuevo = contratosNuevos[i];
                                    contratoNuevo.forEach((key, value) {
                                      if (key == 'id') return;
                                      final original = contratoOriginal[key];
                                      if (original != value) {
                                        cambios['Contrato ${contratoNuevo['id']} - $key'] = {'antes': original, 'despues': value};
                                      }
                                    });
                                  }

                                  if (cambios.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No se realizaron cambios')),
                                    );
                                    return;
                                  }

                                  // Muestra el resumen de cambios
                                  final confirmacion = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar cambios'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: cambios.entries.map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Text(
                                                '${e.key}:\n  Antes: ${e.value['antes']}\n  Después: ${e.value['despues']}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          )).toList(),
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
                                      // Actualiza trabajador
                                      await actualizarTrabajador(trabajador.id, nuevosDatos);
                                      // Actualiza contratos
                                      for (final contrato in contratosNuevos) {
                                        await actualizarContrato(
                                          contrato['id'].toString(),
                                          plazo: contrato['plazo_de_contrato'],
                                          comentario: contrato['comentario_adicional_acerca_del_trabajador'],
                                          documento: contrato['documento_de_vacaciones_del_trabajador'],
                                          estado: contrato['estado'],
                                        );
                                      }
                                      await provider.fetchTrabajadores();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Datos actualizados correctamente')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al actualizar: $e')),
                                        );
                                      }
                                    }
                                  }
                                }
                              } else if (value == 'EliminarContrato') {
                                // Solo permite eliminar si hay al menos un contrato NO "Reemplazado"
                                final contratos = (trabajador.contratos ?? [])
                                    .where((contrato) => contrato['estado'] != 'Reemplazado')
                                    .toList();

                                if (contratos.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('El trabajador no tiene contratos activos para eliminar.')),
                                  );
                                  return;
                                }

                                // Selecciona el contrato a eliminar
                                final contratoSeleccionado = await showDialog<Map<String, dynamic>?>(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    title: const Text('Selecciona un contrato a eliminar'),
                                    children: contratos.map<Widget>((contrato) {
                                      return SimpleDialogOption(
                                        onPressed: () => Navigator.pop(context, contrato),
                                        child: Text('Contrato ID: ${contrato['id']} - Estado: ${contrato['estado']}'),
                                      );
                                    }).toList(),
                                  ),
                                );

                                if (contratoSeleccionado != null) {
                                  // Pide comentario antes de eliminar
                                  final comentarioController = TextEditingController();
                                  bool comentarioInvalido = false;
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) => AlertDialog(
                                          title: const Text('Confirmar eliminación de contrato'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '¿Estás seguro que deseas eliminar el contrato ID: ${contratoSeleccionado['id']} del trabajador ${trabajador.nombreCompleto}?\n\nEsta acción no se puede deshacer.',
                                              ),
                                              const SizedBox(height: 16),
                                              TextField(
                                                controller: comentarioController,
                                                maxLines: 3,
                                                decoration: InputDecoration(
                                                  labelText: 'Comentario obligatorio',
                                                  errorText: comentarioInvalido ? 'El comentario es obligatorio' : null,
                                                  border: const OutlineInputBorder(),
                                                ),
                                                onChanged: (_) {
                                                  if (comentarioInvalido) setState(() => comentarioInvalido = false);
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (comentarioController.text.trim().isEmpty) {
                                                  setState(() => comentarioInvalido = true);
                                                  return;
                                                }
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  if (confirmar == true) {
                                    try {
                                      await actualizarEstadoContrato(
                                        contratoSeleccionado['id'].toString(),
                                        'Reemplazado',
                                      );
                                      await crearComentario(
                                        idTrabajador: trabajador.id,
                                        idContrato: contratoSeleccionado['id'].toString(),
                                        comentario: comentarioController.text.trim(),
                                        fecha: DateTime.now(),
                                      );
                                      await provider.fetchTrabajadores();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Contrato actualizado a "Reemplazado" y comentario guardado')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al eliminar contrato: $e')),
                                        );
                                      }
                                    }
                                  }
                                }
                              } else if (value == 'CrearContrato') {
                                final plazoController = TextEditingController();
                                String estadoSeleccionado = 'Activo';
                                bool camposInvalidos = false;

                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) => AlertDialog(
                                        title: const Text('Crear nuevo contrato'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: plazoController,
                                              decoration: InputDecoration(
                                                labelText: 'Plazo del contrato',
                                                errorText: camposInvalidos && plazoController.text.trim().isEmpty
                                                    ? 'Campo obligatorio'
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            DropdownButtonFormField<String>(
                                              value: estadoSeleccionado,
                                              decoration: const InputDecoration(
                                                labelText: 'Estado',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'Activo',
                                                  child: Text('Activo'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Reemplazado',
                                                  child: Text('Reemplazado'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Finalizado',
                                                  child: Text('Finalizado'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) setState(() => estadoSeleccionado = value);
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (plazoController.text.trim().isEmpty) {
                                                setState(() => camposInvalidos = true);
                                                return;
                                              }
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text('Crear'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (confirmar == true) {
                                  try {
                                    await createContratoSupabase({
                                      'plazo_de_contrato': plazoController.text.trim(),
                                      'estado': estadoSeleccionado,
                                      'fecha_de_contratacion': DateTime.now().toIso8601String().substring(0, 10),
                                      'id_trabajadores': trabajador.id.toString(),
                                    }, trabajador.id.toString());
                                    await provider.fetchTrabajadores();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Contrato creado correctamente')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al crear contrato: $e')),
                                      );
                                    }
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Modificar',
                                child: Text('Modificar'),
                              ),
                              const PopupMenuItem(
                                value: 'Eliminar',
                                child: Text('Eliminar'),
                              ),
                              const PopupMenuItem(
                                value: 'EliminarContrato',
                                child: Text('Eliminar Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'CrearContrato',
                                child: Text('Crear Contrato'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}