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
    // Espera a que los checkboxes estén listos
    if (checkboxProvider.checkBoxes.length != (provider.trabajadores.length + 1)) {
      return const Center(child: CircularProgressIndicator());
    }
    // Define un ancho mínimo para la tabla
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
                  PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0]),
                  Flexible(flex: 4, fit: FlexFit.tight, child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                  Flexible(flex: 3, fit: FlexFit.tight, child: Text('Cargo', style: TextStyle(fontWeight: FontWeight.bold))),
                  Flexible(flex: 3, fit: FlexFit.tight, child: Text('Obra', style: TextStyle(fontWeight: FontWeight.bold))),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[i + 1],),
                      Flexible(flex: 4, fit: FlexFit.tight, child: Text(provider.trabajadores[i].nombreCompleto)),
                      Flexible(flex: 3, fit: FlexFit.tight, child: Text(provider.trabajadores[i].rolQueAsumeEnLaObra)), // Cargo real si lo tienes
                      Flexible(flex: 3, fit: FlexFit.tight, child: Text(provider.trabajadores[i].obraEnLaQueTrabaja)), // Obra real si lo tienes
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
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
                                final trabajador = provider.trabajadores[i];
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
                                                  // aqui se agregan mas estados
                                                  // DropdownMenuItem(
                                                  //   value: 'otro_estado',
                                                  //   child: Text('Otro Estado'),
                                                  // ),
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