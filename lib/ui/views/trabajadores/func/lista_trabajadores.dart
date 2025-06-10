import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/ui/widgets/checkbox.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/actualizar_estado_trabajador.dart';
import 'package:sistema_acviis/ui/widgets/expansion_tile.dart';
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
                          // Puedes agregar más parámetros si tu widget los acepta
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'eliminar',
                                child: Text('Eliminar'),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'eliminar') {
                                String estadoSeleccionado = 'despedido'; // Valor por defecto

                                final resultado = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Cambiar estado del trabajador'),
                                      content: StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Nombre: ${trabajador.nombreCompleto}'),
                                              Text('RUT: ${trabajador.rut}'),
                                              const SizedBox(height: 16),
                                              const Text('Seleccione el nuevo estado:'),
                                              DropdownButton<String>(
                                                value: estadoSeleccionado,
                                                items: [
                                                  DropdownMenuItem(
                                                    value: 'despedido',
                                                    child: Text('Despedido'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'renuncio',
                                                    child: Text('Renunció'),
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      estadoSeleccionado = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, null),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, estadoSeleccionado),
                                          child: const Text('Confirmar'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (resultado != null) {
                                  await actualizarEstadoTrabajador(trabajador.id, resultado);
                                  await provider.fetchTrabajadores();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Se a actualizado el estado de activo a "$resultado" con exito')),
                                    );
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
      ),
    );
  }
}