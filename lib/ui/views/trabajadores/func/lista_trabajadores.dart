import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/ui/widgets/checkbox.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/backend/controllers/contratos/actualizar_estado_contrato.dart';
import 'package:sistema_acviis/ui/widgets/expansion_tile.dart';

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
                              // Busca el contrato activo o el más reciente
                              final contrato = trabajador.contratos.isNotEmpty
                                  ? trabajador.contratos.last
                                  : null;
                              if (contrato == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No se encontró contrato asociado')),
                                );
                                return;
                              }
                              // Mostrar un SimpleDialog para elegir el nuevo estado
                              String? estadoSeleccionado = 'Despedido'; // Valor por defecto

                              final nuevoEstado = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Selecciona el nuevo estado'),
                                    content: StatefulBuilder(
                                      builder: (context, setState) {
                                        return DropdownButtonFormField<String>(
                                          value: estadoSeleccionado,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'Despedido',
                                              child: Text('Despedido'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Renuncio',
                                              child: Text('Renunció'),
                                            ),
                                            // aqui se agregan mas
                                            // DropdownMenuItem(
                                            //   value: 'Activo',
                                            //   child: Text('Activo'),
                                            // ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              estadoSeleccionado = value;
                                            });
                                          },
                                          decoration: const InputDecoration(labelText: 'Nuevo estado'),
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
                              if (nuevoEstado != null) {
                                final confirmacion = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar cambio de estado'),
                                    content: Text('¿Está seguro que desea cambiar el estado a "$nuevoEstado"?'),
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
                                    await actualizarEstadoContrato(contrato['id'].toString(), nuevoEstado);
                                    await provider.fetchTrabajadores();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Estado actualizado a "$nuevoEstado"')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al actualizar estado: $e')),
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
      ),
    );
  }
}