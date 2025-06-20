import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/ui/views/trabajadores/utils/agregar_anexo_contrato_dialog.dart';
import 'package:sistema_acviis/ui/widgets/checkbox.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/ui/widgets/expansion_tile.dart';
import 'package:sistema_acviis/ui/views/trabajadores/editar_trabajador_dialog.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_estado_trabajador.dart';
import 'package:sistema_acviis/backend/controllers/contratos/actualizar_estado_contrato.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';
import 'package:sistema_acviis/backend/controllers/contratos/create_contrato.dart';
import 'package:sistema_acviis/providers/comentarios_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

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

  //  función para descargar y abrir el PDF:
  Future<void> descargarFichaPDF(BuildContext context, String trabajadorId, String rut) async {
    try {
      final url = Uri.parse('http://localhost:3000/trabajadores/$trabajadorId/ficha-pdf');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/ficha_trabajador_${rut ?? trabajadorId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF descargado. Abriendo...')),
        );
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar la ficha PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrabajadoresProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();
    final listaDeComentarios = Provider.of<ComentariosProvider>(context).comentarios;

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
                                if (value == 'Eliminar') { // ===================== ELIMINAR TRABAJADOR
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
                              } else if (value == 'Modificar') {// ===================== MODIFICAR TRABAJADOR
                                final resultado = await showDialog(
                                  context: context,
                                  builder: (context) => EditarTrabajadorDialog(trabajador: trabajador),
                                );
                                if (resultado is Map<String, dynamic>) {
                                  final cambios = <String, Map<String, dynamic>>{};
                                  final nuevosDatos = resultado['trabajador'] as Map<String, dynamic>;
                                  // Compara datos del trabajador
                                  nuevosDatos.forEach((key, value) {
                                    final original = trabajador.toJson()[key];
                                    if (original != value) {
                                      cambios[key] = {'antes': original, 'despues': value};
                                    }
                                  });

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
                              } else if (value == 'Eliminar Contrato') { // ===================== ELIMINAR CONTRATO
                                // Solo permite eliminar si hay al menos un contrato NO "Reemplazado"
                                // Se podria modificar para mas filtros en caso de mas estados)?
                                final contratos = (trabajador.contratos ?? [])
                                    .where((contrato) => contrato['estado'] != 'Reemplazado')
                                    .toList();

                                // Si no hay ningún contrato activo ni finalizado, muestra mensaje
                                
                                final tieneContratoAsociado = (trabajador.contratos ?? [])
                                    .any((contrato) => contrato['estado'] == 'Activo' || contrato['estado'] == 'Finalizado');
                                if (!tieneContratoAsociado) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No hay contrato asociado para eliminar.')),
                                  );
                                  return;
                                }

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
                                  final confirmarComentario = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) => AlertDialog(
                                          title: const Text('Comentario para eliminar contrato'),
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
                                              child: const Text('Siguiente'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  if (confirmarComentario == true) {
                                    // Pantalla de confirmación final
                                    final confirmarFinal = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar eliminación de contrato'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('¿Deseas eliminar el siguiente contrato?'),
                                            const SizedBox(height: 12),
                                            Text('Trabajador: ${trabajador.nombreCompleto ?? ''}'),
                                            Text('RUT: ${trabajador.rut ?? ''}'),
                                            Text('Contrato ID: ${contratoSeleccionado['id']}'),
                                            Text('Estado: ${contratoSeleccionado['estado']}'),
                                            Text('Plazo: ${contratoSeleccionado['plazo_de_contrato']}'),
                                            const SizedBox(height: 12),
                                            const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(comentarioController.text.trim(), style: const TextStyle(fontStyle: FontStyle.italic)),
                                            const SizedBox(height: 12),
                                            const Text('Esta acción no se puede deshacer.'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmarFinal == true) {
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
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Se canceló la eliminación del contrato')),
                                      );
                                    }
                                  }
                                }
                              } else if (value == 'Crear Contrato') { // ===================== CREAR CONTRATO
                                // Solo permite crear si NO tiene ningún contrato vinculado
                                if ((trabajador.contratos ?? []).any((contrato) => contrato['estado'] == 'Activo')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('El trabajador ya tiene un contrato activo vinculado.')),
                                  );
                                  return;
                                }

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
                                            // se crea siempre como activo
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                                child: Text(
                                                  'Estado: Activo',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            /*
                                            cambiar lo de arriba por un dropdown si se quiere
                                            con mas opciones de estado

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
                                            ),*/
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
                                            child: const Text('Siguiente'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (confirmar == true) {
                                  // Mostrar resumen antes de crear
                                  final confirmarFinal = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar creación de contrato'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Se creará el siguiente contrato para el trabajador:'),
                                          const SizedBox(height: 12),
                                          Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
                                          Text('RUT: ${trabajador.rut ?? ''}'),
                                          const SizedBox(height: 12),
                                          const Text('Datos del contrato:', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Plazo: ${plazoController.text.trim()}'),
                                          Text('Estado: $estadoSeleccionado'),
                                          Text('Fecha de contratación: ${DateTime.now().toIso8601String().substring(0, 10)}'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Confirmar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmarFinal == true) {
                                    try {
                                      final contratoData = {
                                        'plazo_de_contrato': plazoController.text.trim(),
                                        'estado': estadoSeleccionado,
                                        'fecha_de_contratacion': DateTime.now().toIso8601String().substring(0, 10),
                                        'id_trabajadores': trabajador.id.toString(),
                                      };

                                      final trabajadorId = trabajador.id.toString();

                                      final idContrato = await createContratoSupabase(contratoData, trabajadorId);
                                      if (idContrato.isNotEmpty) {
                                        await createContratoMongo(contratoData, trabajadorId, idContrato);
                                      }

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
                              } else if (value == 'Agregar Comentario') { // ===================== AGREGAR COMENTARIO
                                final comentarioController = TextEditingController();
                                bool comentarioInvalido = false;

                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) => AlertDialog(
                                        title: const Text('Agregar comentario'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Por favor, ingresa un comentario acerca del trabajador:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: comentarioController,
                                              maxLines: 3,
                                              decoration: InputDecoration(
                                                labelText: 'Comentario',
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
                                            child: const Text('Siguiente'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (confirmar == true) {
                                  // Mostrar resumen antes de agregar
                                  final confirmarFinal = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar comentario'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('¿Deseas agregar el siguiente comentario al trabajador?'),
                                          const SizedBox(height: 12),
                                          Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
                                          Text('RUT: ${trabajador.rut ?? ''}'),
                                          const SizedBox(height: 12),
                                          const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(comentarioController.text.trim(), style: const TextStyle(fontStyle: FontStyle.italic)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Confirmar'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmarFinal == true) {
                                    try {
                                      await crearComentario(
                                        idTrabajador: trabajador.id,
                                        comentario: comentarioController.text.trim(),
                                        fecha: DateTime.now(),
                                        idContrato: null,
                                      );
                                      
                                      await provider.fetchTrabajadores();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Comentario agregado correctamente')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al agregar comentario: $e')),
                                        );
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Se canceló el comentario al trabajador')),
                                    );
                                  }
                                }
                              } else if (value == 'Agregar Comentario a Contrato') { // ===================== AGREGAR COMENTARIO A CONTRATO
                                  final contratosActivos = (trabajador.contratos ?? [])
                                      .where((contrato) => contrato['estado'] == 'Activo')
                                      .toList();

                                  if (contratosActivos.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No hay contrato activo para agregar comentario.')),
                                    );
                                    return;
                                  }

                                  final contrato = contratosActivos.first;
                                  final comentarioController = TextEditingController();
                                  bool comentarioInvalido = false;

                                  final confirmarComentario = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) => AlertDialog(
                                          title: const Text('Agregar comentario a contrato'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Trabajador: ${trabajador.nombreCompleto ?? ''}'),
                                              Text('RUT: ${trabajador.rut ?? ''}'),
                                              const SizedBox(height: 8),
                                              Text('Contrato ID: ${contrato['id']}'),
                                              Text('Estado: ${contrato['estado']}'),
                                              Text('Plazo: ${contrato['plazo_de_contrato']}'),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: comentarioController,
                                                maxLines: 3,
                                                decoration: InputDecoration(
                                                  labelText: 'Comentario',
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
                                              child: const Text('Siguiente'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  if (confirmarComentario == true) {
                                    // Pantalla de confirmación final
                                    final confirmarFinal = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar comentario'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('¿Deseas agregar el siguiente comentario al contrato?'),
                                            const SizedBox(height: 12),
                                            Text('Trabajador: ${trabajador.nombreCompleto ?? ''}'),
                                            Text('RUT: ${trabajador.rut ?? ''}'),
                                            Text('Contrato ID: ${contrato['id']}'),
                                            Text('Estado: ${contrato['estado']}'),
                                            Text('Plazo: ${contrato['plazo_de_contrato']}'),
                                            const SizedBox(height: 12),
                                            const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(comentarioController.text.trim(), style: const TextStyle(fontStyle: FontStyle.italic)),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Confirmar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmarFinal == true) {
                                      try {
                                        await crearComentario(
                                          idTrabajador: trabajador.id,
                                          idContrato: contrato['id'].toString(),
                                          comentario: comentarioController.text.trim(),
                                          fecha: DateTime.now(),
                                        );
                                        await Provider.of<ComentariosProvider>(context, listen: false).fetchComentarios();
                                        await provider.fetchTrabajadores();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Comentario agregado al contrato con éxito')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al agregar comentario: $e')),
                                          );
                                        }
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Se canceló el comentario al contrato')),
                                      );
                                    }
                                  }
                              } else if (value == 'Agregar anexo a contrato') { // ===================== AGREGAR ANEXO A CONTRATO
                                showDialog(
                                  context: context,
                                    builder: (context) {
                                    // Busca el contrato activo del trabajador
                                    final contratos = trabajador.contratos ?? [];
                                    final contratoActivo = contratos.firstWhere(
                                      (c) => c['estado'] == 'Activo',
                                      orElse: () => null,
                                    );
                                    final idContrato = contratoActivo != null ? contratoActivo['id'] : null;
                                    final idTrabajador = trabajador.id;
                                    return AgregarAnexoContratoDialog(
                                      idContrato: idContrato, 
                                      idTrabajador: idTrabajador,
                                      trabajador: trabajador,
                                    );
                                    },
                                );
                                
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
                                value: 'Eliminar Contrato',
                                child: Text('Eliminar Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'Crear Contrato',
                                child: Text('Crear Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'Agregar Comentario',
                                child: Text('Agregar Comentario al Trabajador'),
                              ),
                              const PopupMenuItem(
                                value: 'Agregar Comentario a Contrato',
                                child: Text('Agregar Comentario a Contrato'),
                              ),
                              const PopupMenuItem(
                                value: 'Agregar anexo a contrato',
                                child: Text('Agregar anexo a contrato'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                          // callback al botón para generar PDF:
                          pdfCallback: () {
                            descargarFichaPDF(context, trabajador.id, trabajador.rut);
                          },
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