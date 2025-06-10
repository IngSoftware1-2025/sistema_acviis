import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/ui/widgets/checkbox.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_estado_trabajador.dart';
import 'package:sistema_acviis/ui/views/trabajadores/editar_trabajador_dialog.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_trabajador.dart';

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
        Provider.of<CheckboxProvider>(context, listen: false)
        .setCheckBoxes(trabajadoresProvider.trabajadores.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrabajadoresProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Espera a que los checkboxes estén listos
    if (checkboxProvider.checkBoxes.length != (provider.trabajadores.length + 1)) {
      return const Center(child: CircularProgressIndicator());
    }
    // Define un ancho mínimo para la tabla
    final double tableWidth = MediaQuery.of(context).size.width > 600
        ? MediaQuery.of(context).size.width
        : 600;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: tableWidth - normalPadding * 2,
        child: Column(
          children: [
            // Header
            Row(
              children: [
                PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0]),
                Flexible(flex: 4, fit: FlexFit.tight, child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                Flexible(flex: 3, fit: FlexFit.tight, child: Text('Cargo', style: TextStyle(fontWeight: FontWeight.bold))),
                Flexible(flex: 3, fit: FlexFit.tight, child: Text('Obra', style: TextStyle(fontWeight: FontWeight.bold))),
                /* Estado se puede eliminar si no es necesario, pero sirve para mostrar el estado del trabajador
                   ademas de de que se puede ver si el trabajador está despedido o renunció y si se actualizo correctamente
                */
                Flexible(flex: 3, fit: FlexFit.tight, child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Opciones', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const Divider(),
            // Rows
            ...List.generate(provider.trabajadores.length, (i) {
              final trabajador = provider.trabajadores[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Row(
                  children: [
                    PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[i + 1],),
                    Flexible(flex: 4, fit: FlexFit.tight, child: Text(trabajador.nombreCompleto)),
                    Flexible(flex: 3, fit: FlexFit.tight, child: Text(trabajador.rolQueAsumeEnLaObra)),
                    Flexible(flex: 3, fit: FlexFit.tight, child: Text(trabajador.obraEnLaQueTrabaja)),
                    /*
                    aqui lo mismo que el de arriba, se puede eliminar si no es necesario
                    */
                    Flexible(flex: 3, fit: FlexFit.tight, child: Text(trabajador.estadoTrabajador)),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'Modificar',
                              child: Text('Modificar'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'eliminar',
                              child: Text('Eliminar'),
                            ),
                          ],
                          /*
                          aquí se maneja eliminando o editando al trabajador
                          de mamera individual
                          */
                          onSelected: (value) async {
                            /*
                            opcion eliminar
                            tecnicamente no se elimina, sino que se cambia el estado del trabajador
                            a despedido o renunció, pero se puede considerar como una eliminación
                            */
                            if (value == 'eliminar') {
                              String estadoSeleccionado = 'Despedido'; // Valor por defecto
                              final resultado = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Cambiar estado del trabajador'),
                                    //aqui lo puse en una tabla por estetica
                                    content: StatefulBuilder(
                                      builder: (context, setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 70, // Ajusta el ancho según lo que necesites
                                                  child: Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                Expanded(child: Text(trabajador.nombreCompleto)),
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 70,
                                                  child: Text('RUT:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                Expanded(child: Text(trabajador.rut)),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('Seleccione el nuevo estado:'),

                                            Center(
                                              child: DropdownButton<String>(
                                                value: estadoSeleccionado,
                                                items: [
                                                  DropdownMenuItem(
                                                    value: 'Despedido',
                                                    child: Text('Despedido'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Renunció',
                                                    child: Text('Renunció'),
                                                  ),
                                                  
                                                  /*
                                                  aquí se agregan más estados
                                                  quizas "Suspendido"? o algo similar
                                                  DropdownMenuItem(
                                                    value: 'Otro Estado',
                                                    child: Text('Otro Estado'),
                                                  ),*/
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      estadoSeleccionado = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, null),
                                            child: const Text('Cancelar'),
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Mostrar alerta de confirmación antes de realizar el cambio
                                        final confirmacion = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar cambio'),
                                            //aqui lo puse en una tabla por estetica x2
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('¿Está seguro que desea modificar el estado del trabajador?\n'),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      width: 70, // Puedes ajustar el ancho según lo que necesites
                                                      child: Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ),
                                                    Expanded(child: Text(trabajador.nombreCompleto)),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      width: 70,
                                                      child: Text('RUT:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ),
                                                    Expanded(child: Text(trabajador.rut)),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text('De "$estadoSeleccionado" a "$estadoSeleccionado".'),
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
                                        if (confirmacion == true) {
                                          Navigator.pop(context, estadoSeleccionado);
                                        }
                                      },
                                      child: const Text('Confirmar'),
                                    ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (resultado != null) {
                                final estadoAnterior = trabajador.estadoTrabajador;
                                await actualizarEstadoTrabajador(trabajador.id, resultado);
                                await provider.fetchTrabajadores();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'El trabajador con RUT ${trabajador.rut} cambió de estado "$estadoAnterior" a "$resultado".'
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            /*
                            opcion editar
                            aqui se abre un dialogo para editar los datos del trabajador
                            modificando todos los campos
                            pero manteniendo su PK (id)
                            */
                            if (value == 'Modificar') {
                              final nuevosDatos = await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) => EditarTrabajadorDialog(trabajador: trabajador),
                              );
                              if (nuevosDatos != null) {
                                final confirmacion = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar modificación'),
                                    //aqui lo puse en una tabla por estetica x3
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('¿Está seguro que desea modificar los datos del trabajador?\n'),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              width: 70, // Ajusta el ancho según lo que necesites
                                              child: Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Expanded(child: Text(trabajador.nombreCompleto)),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              width: 70,
                                              child: Text('RUT:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Expanded(child: Text(trabajador.rut)),
                                          ],
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
                                if (confirmacion == true) {
                                  try {
                                    await actualizarTrabajador(trabajador.id, nuevosDatos);
                                    await provider.fetchTrabajadores();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Datos modificados con éxito')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al modificar trabajador: $e')),
                                      );
                                    }
                                  }
                                }
                              }
                            }
                          },
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
    );
  }
}