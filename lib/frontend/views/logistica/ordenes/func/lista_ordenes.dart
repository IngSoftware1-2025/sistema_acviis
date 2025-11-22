import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/widgets/checkbox.dart';
import 'package:sistema_acviis/frontend/widgets/expansion_tile_ordenes.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';

class ListaOrdenes extends StatefulWidget {
  const ListaOrdenes({super.key});

  @override
  State<ListaOrdenes> createState() => _ListaOrdenesState();
}

class _ListaOrdenesState extends State<ListaOrdenes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ordenesProvider =
          Provider.of<OrdenesProvider>(context, listen: false);
      await ordenesProvider.fetchOrdenes();
      if (!mounted) return;

      final checkboxProvider =
          Provider.of<CheckboxProvider>(context, listen: false);
      final ordenesActivas = ordenesProvider.ordenes
          .where((o) => o.estado != 'De baja')
          .toList();

      checkboxProvider.setCheckBoxes(ordenesActivas.length);
    });
  }

  bool get _tieneSeleccionadas {
    final checkboxProvider =
        Provider.of<CheckboxProvider>(context, listen: false);
    return checkboxProvider.checkBoxes.skip(1).any((cb) => cb.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final ordenesProvider = context.watch<OrdenesProvider>();
    final checkboxProvider = context.watch<CheckboxProvider>();

    final ordenesActivas =
        ordenesProvider.ordenes.where((o) => o.estado != 'De baja').toList();

    if (ordenesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 🔁 Aseguramos que SIEMPRE haya un checkbox por orden activa (+1 para el "select all")
    if (checkboxProvider.checkBoxes.length != ordenesActivas.length + 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cp =
            Provider.of<CheckboxProvider>(context, listen: false);
        cp.setCheckBoxes(ordenesActivas.length);
      });
    }

    return Column(
      children: [
        // HEADER
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            children: [
              if (checkboxProvider.checkBoxes.isNotEmpty)
                PrimaryCheckbox(customCheckbox: checkboxProvider.checkBoxes[0]),
              const SizedBox(width: 8),
              const Expanded(
                child: Center(
                  child: Text(
                    'Órdenes de Compra',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/home_page/logistica_view/ordenes_view/agregar_ordenes_view',
                  );
                },
                child: const Text('Agregar OC'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _tieneSeleccionadas
                    ? () {
                        final ordenesSeleccionadas = ordenesActivas
                            .asMap()
                            .entries
                            .where((entry) => checkboxProvider
                                .checkBoxes[entry.key + 1].isSelected)
                            .map((entry) => entry.value)
                            .toList();

                        if (ordenesSeleccionadas.isEmpty) return;

                        Navigator.pushNamed(
                          context,
                          '/home_page/logistica_view/modificar_ordenes_view',
                          arguments: ordenesSeleccionadas,
                        );
                      }
                    : null,
                child: const Text('Editar OC'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _tieneSeleccionadas
                    ? () async {
                        final checkboxProvider =
                            Provider.of<CheckboxProvider>(context,
                                listen: false);
                        final ordenesSeleccionadas =
                            ordenesActivas.asMap().entries
                                .where((entry) => checkboxProvider
                                    .checkBoxes[entry.key + 1].isSelected)
                                .map((entry) => entry.value)
                                .toList();

                        if (ordenesSeleccionadas.isEmpty) return;

                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar órdenes'),
                            content: const Text(
                              '¿Está seguro que desea eliminar las órdenes seleccionadas? Se marcarán como eliminadas.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar != true) return;

                        final idsSeleccionados =
                            ordenesSeleccionadas.map((o) => o.id).toList();

                        try {
                          await ordenesProvider.darDeBaja(idsSeleccionados);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Las órdenes seleccionadas fueron eliminadas correctamente.',
                              ),
                            ),
                          );
                          // volvemos a alinear la cantidad de checkboxes
                          checkboxProvider
                              .setCheckBoxes(ordenesProvider.ordenes
                                  .where(
                                      (o) => o.estado != 'De baja')
                                  .length);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Hubo un error al eliminar las órdenes.',
                              ),
                            ),
                          );
                          print("Error al eliminar las órdenes: $e");
                        }
                      }
                    : null,
                child: const Text('Eliminar órdenes'),
              ),
            ],
          ),
        ),
        const Divider(),

        // LISTA
        Expanded(
          child: ordenesActivas.isEmpty
              ? const Center(
                  child: Text('No hay órdenes activas para mostrar.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: ordenesActivas.length,
                  itemBuilder: (context, i) {
                    final orden = ordenesActivas[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        children: [
                          PrimaryCheckbox(
                            customCheckbox:
                                checkboxProvider.checkBoxes[i + 1],
                          ),
                          Expanded(
                            child: ExpansionTileOrdenes(orden: orden),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
